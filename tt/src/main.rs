use std::io::{self, IsTerminal, Write};
use std::process::{Command, Stdio};

use std::sync::mpsc;

use block2::RcBlock;
use clap::{Parser, Subcommand};
use crossterm::cursor::{Hide, MoveToColumn, MoveUp, Show};
use crossterm::event::{self, Event, KeyCode, KeyEvent, KeyEventKind, KeyModifiers};
use crossterm::style::{Attribute, Print, SetAttribute};
use crossterm::terminal::{self, Clear, ClearType};
use crossterm::{execute, queue};
use objc2::rc::Retained;
use objc2_event_kit::{EKCalendar, EKEntityType, EKEventStore, EKReminder};
use objc2_foundation::{NSArray, NSError, NSString};

const REMIND_SCRIPT: &str = r#"on run argv
    tell application "Reminders"
        set listName to item 2 of argv
        set dueText to item 3 of argv
        if listName is "" then
            set targetList to default list
        else
            set targetList to list listName
        end if
        set props to {name:item 1 of argv}
        if dueText is not "" then set props to props & {due date:date dueText}
        make new reminder at end of targetList with properties props
    end tell
end run
"#;

#[derive(Parser)]
#[command(
    name = "tt",
    version,
    about = "Task tracker: add a reminder to macOS Reminders",
    args_conflicts_with_subcommands = true
)]
struct Cli {
    #[command(subcommand)]
    command: Option<Cmd>,
    /// Reminder title (multiple words allowed, no quotes needed)
    #[arg(required = true)]
    title: Vec<String>,
    /// Due date, in a format AppleScript understands (e.g. "2026-10-21")
    #[arg(short, long)]
    date: Option<String>,
    /// Due time (e.g. "14:30"); today if no date is given
    #[arg(short, long)]
    time: Option<String>,
    /// Add the reminder to this list (e.g. "management", "projects", "tasks")
    #[arg(short, long)]
    scope: Option<String>,
}

#[derive(Subcommand)]
enum Cmd {
    /// Browse open reminders and mark some as done
    List {
        /// Only show reminders from this list (e.g. "management", "projects", "tasks")
        #[arg(short, long)]
        scope: Option<String>,
        /// Just print the reminders, skip the interactive picker
        #[arg(long)]
        no_interactive: bool,
    },
}

struct Item {
    id: String,
    title: String,
    due: String,
}

fn osascript(script: &str, args: &[&str]) -> Result<String, String> {
    let mut cmd = Command::new("osascript");
    cmd.arg("-").args(args);
    let mut child = cmd
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .map_err(|e| format!("failed to run osascript: {e}"))?;

    child
        .stdin
        .take()
        .ok_or("failed to open osascript stdin")?
        .write_all(script.as_bytes())
        .map_err(|e| format!("failed to write script: {e}"))?;

    let out = child
        .wait_with_output()
        .map_err(|e| format!("osascript failed: {e}"))?;
    if out.status.success() {
        Ok(String::from_utf8_lossy(&out.stdout).into_owned())
    } else {
        Err(String::from_utf8_lossy(&out.stderr).trim().to_string())
    }
}

fn remind(title: &str, scope: Option<&str>, due: Option<&str>) -> Result<(), String> {
    osascript(REMIND_SCRIPT, &[title, scope.unwrap_or(""), due.unwrap_or("")]).map(|_| ())
}

fn open_store() -> Result<Retained<EKEventStore>, String> {
    let store = unsafe { EKEventStore::new() };
    let (tx, rx) = mpsc::channel();
    let block = RcBlock::new(move |granted: objc2::runtime::Bool, err: *mut NSError| {
        let msg = if granted.as_bool() {
            Ok(())
        } else if err.is_null() {
            Err("access to Reminders was denied".to_string())
        } else {
            Err(unsafe { &*err }.localizedDescription().to_string())
        };
        let _ = tx.send(msg);
    });
    unsafe { store.requestFullAccessToRemindersWithCompletion(&*block as *const _ as *mut _) };
    rx.recv().map_err(|e| e.to_string())??;
    Ok(store)
}

fn due_string(r: &EKReminder) -> String {
    let Some(c) = (unsafe { r.dueDateComponents() }) else {
        return String::new();
    };
    let (y, mo, d) = (c.year(), c.month(), c.day());
    let (h, mi) = (c.hour(), c.minute());
    if h >= 0 && h < 24 && mi >= 0 {
        format!("{y:04}-{mo:02}-{d:02} {h:02}:{mi:02}")
    } else {
        format!("{y:04}-{mo:02}-{d:02}")
    }
}

fn find_lists(store: &EKEventStore, scope: &str) -> Result<Retained<NSArray<EKCalendar>>, String> {
    let all = unsafe { store.calendarsForEntityType(EKEntityType::Reminder) };
    let matches: Vec<Retained<EKCalendar>> = all
        .iter()
        .filter(|c| unsafe { c.title() }.to_string().eq_ignore_ascii_case(scope))
        .collect();
    if matches.is_empty() {
        let names: Vec<String> = all.iter().map(|c| unsafe { c.title() }.to_string()).collect();
        return Err(format!("no list named \"{scope}\" (available: {})", names.join(", ")));
    }
    Ok(NSArray::from_retained_slice(&matches))
}

fn fetch_open(store: &EKEventStore, scope: Option<&str>) -> Result<Vec<Item>, String> {
    let calendars = scope.map(|s| find_lists(store, s)).transpose()?;
    let pred = unsafe {
        store.predicateForIncompleteRemindersWithDueDateStarting_ending_calendars(None, None, calendars.as_deref())
    };
    let (tx, rx) = mpsc::channel();
    let block = RcBlock::new(move |arr: *mut NSArray<EKReminder>| {
        let mut items = Vec::new();
        if let Some(arr) = unsafe { arr.as_ref() } {
            for r in arr.iter() {
                items.push(Item {
                    id: unsafe { r.calendarItemIdentifier() }.to_string(),
                    title: unsafe { r.title() }.to_string(),
                    due: due_string(&r),
                });
            }
        }
        let _ = tx.send(items);
    });
    unsafe { store.fetchRemindersMatchingPredicate_completion(&pred, &block) };
    let mut items = rx.recv().map_err(|e| e.to_string())?;
    items.sort_by(|a, b| match (a.due.is_empty(), b.due.is_empty()) {
        (false, false) => a.due.cmp(&b.due).then_with(|| a.title.cmp(&b.title)),
        (a_empty, b_empty) => a_empty.cmp(&b_empty).then_with(|| a.title.cmp(&b.title)),
    });
    Ok(items)
}

fn complete(store: &EKEventStore, id: &str) -> Result<(), String> {
    let item = unsafe { store.calendarItemWithIdentifier(&NSString::from_str(id)) }
        .ok_or_else(|| format!("reminder not found: {id}"))?;
    let reminder = item
        .downcast::<EKReminder>()
        .map_err(|_| "not a reminder".to_string())?;
    unsafe {
        reminder.setCompleted(true);
        store
            .saveReminder_commit_error(&reminder, true)
            .map_err(|e| e.localizedDescription().to_string())
    }
}

struct RawGuard;

impl RawGuard {
    fn new() -> io::Result<Self> {
        terminal::enable_raw_mode()?;
        execute!(io::stdout(), Hide)?;
        Ok(RawGuard)
    }
}

impl Drop for RawGuard {
    fn drop(&mut self) {
        let _ = execute!(io::stdout(), Show);
        let _ = terminal::disable_raw_mode();
    }
}

fn truncate(s: &str, width: usize) -> String {
    if s.chars().count() <= width {
        s.to_string()
    } else {
        let mut t: String = s.chars().take(width.saturating_sub(1)).collect();
        t.push('…');
        t
    }
}

fn draw(items: &[Item], marked: &[bool], cursor: usize, top: usize, rows: usize, first: bool) -> io::Result<()> {
    let mut out = io::stdout();
    let (cols, _) = terminal::size()?;
    let width = (cols as usize).saturating_sub(1);
    let shown = rows.min(items.len());
    if !first {
        queue!(out, MoveUp((shown + 1) as u16))?;
    }
    for i in top..top + shown {
        let it = &items[i];
        let due = if it.due.is_empty() { String::new() } else { format!("  ({})", it.due) };
        let line = format!(
            "{} [{}] {}{}",
            if i == cursor { ">" } else { " " },
            if marked[i] { "x" } else { " " },
            it.title,
            due
        );
        queue!(out, MoveToColumn(0), Clear(ClearType::CurrentLine))?;
        if i == cursor {
            queue!(out, SetAttribute(Attribute::Reverse))?;
        }
        queue!(out, Print(truncate(&line, width)), SetAttribute(Attribute::Reset), Print("\r\n"))?;
    }
    let hint = "up/down or j/k move, space mark, enter confirm, q cancel";
    queue!(out, MoveToColumn(0), Clear(ClearType::CurrentLine), SetAttribute(Attribute::Dim), Print(truncate(hint, width)), SetAttribute(Attribute::Reset), Print("\r\n"))?;
    out.flush()
}

fn select(items: &[Item]) -> io::Result<Option<Vec<usize>>> {
    let _guard = RawGuard::new()?;
    let (_, term_rows) = terminal::size()?;
    let rows = (term_rows as usize).saturating_sub(2).max(1);
    let shown = rows.min(items.len());
    let mut marked = vec![false; items.len()];
    let (mut cursor, mut top) = (0usize, 0usize);
    let mut first = true;
    let result = loop {
        draw(items, &marked, cursor, top, rows, first)?;
        first = false;
        let Event::Key(KeyEvent { code, modifiers, kind, .. }) = event::read()? else {
            continue;
        };
        if kind == KeyEventKind::Release {
            continue;
        }
        match code {
            KeyCode::Up | KeyCode::Char('k') => cursor = cursor.saturating_sub(1),
            KeyCode::Down | KeyCode::Char('j') => cursor = (cursor + 1).min(items.len() - 1),
            KeyCode::Char(' ') => marked[cursor] = !marked[cursor],
            KeyCode::Enter => {
                break Some((0..items.len()).filter(|&i| marked[i]).collect());
            }
            KeyCode::Esc | KeyCode::Char('q') => break None,
            KeyCode::Char('c') if modifiers.contains(KeyModifiers::CONTROL) => break None,
            _ => {}
        }
        if cursor < top {
            top = cursor;
        } else if cursor >= top + shown {
            top = cursor + 1 - shown;
        }
    };
    queue!(io::stdout(), MoveUp((shown + 1) as u16), MoveToColumn(0), Clear(ClearType::FromCursorDown))?;
    io::stdout().flush()?;
    Ok(result)
}

fn list(scope: Option<&str>, no_interactive: bool) -> Result<(), String> {
    let store = open_store()?;
    let items = fetch_open(&store, scope)?;
    if items.is_empty() {
        println!("No open reminders.");
        return Ok(());
    }
    if no_interactive {
        for it in &items {
            let due = if it.due.is_empty() { String::new() } else { format!("  ({})", it.due) };
            println!("{}{}", it.title, due);
        }
        return Ok(());
    }
    if !io::stdin().is_terminal() || !io::stdout().is_terminal() {
        return Err("`tt list` needs an interactive terminal".to_string());
    }
    let Some(picked) = select(&items).map_err(|e| e.to_string())? else {
        return Ok(());
    };
    if picked.is_empty() {
        println!("Nothing marked.");
    }
    for i in picked {
        complete(&store, &items[i].id)?;
        println!("Done: {}", items[i].title);
    }
    Ok(())
}

fn main() {
    let cli = Cli::parse();
    if let Some(Cmd::List { scope, no_interactive }) = cli.command {
        if let Err(e) = list(scope.as_deref(), no_interactive) {
            eprintln!("error: {e}");
            std::process::exit(1);
        }
        return;
    }
    let title = cli.title.join(" ");
    let due = match (&cli.date, &cli.time) {
        (None, None) => None,
        (d, t) => Some(
            [d.as_deref(), t.as_deref()]
                .into_iter()
                .flatten()
                .collect::<Vec<_>>()
                .join(" "),
        ),
    };
    match remind(&title, cli.scope.as_deref(), due.as_deref()) {
        Ok(()) => match due {
            Some(due) => println!("Reminder created: {title} ({due})"),
            None => println!("Reminder created: {title}"),
        },
        Err(e) => {
            eprintln!("error: {e}");
            std::process::exit(1);
        }
    }
}
