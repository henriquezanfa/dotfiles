#!/usr/bin/env bash

apply_theme() {
    local active_color="#b4befe"     # lavender bubble
    local inactive_color="#6c7086"   # dim text (inactive windows)
    local text_color="#cdd6f4"       # light text on dark bubble
    local accent_color="#b4befe"     # same as active
    local border_color="#44475a"     # dark grey bubble
    local dark_fg="#1e1e2e"          # text on lavender bubble

    # Rounded bubble caps (Powerline / Nerd Font)
    local L=""
    local R=""

    # Status bar: transparent background
    tmux set-option -g status on
    tmux set-option -g status-position bottom
    tmux set-option -g status-interval 3
    tmux set-option -g status-justify left
    tmux set-option -g status-style "bg=default,fg=$text_color"
    tmux set-option -g status-left-length 100
    tmux set-option -g status-right-length 200

    # Pane borders
    tmux set-option -g pane-border-style "fg=$border_color"
    tmux set-option -g pane-active-border-style "fg=$active_color"

    # Message style
    tmux set-option -g message-style "bg=$border_color,fg=$text_color,bold"
    tmux set-option -g message-command-style "bg=$border_color,fg=$text_color,bold"

    # Window list — transparent, active window shown as a subtle bubble
    tmux set-option -g window-status-format "#[fg=$inactive_color,bg=default]  #I:#W  "
    tmux set-option -g window-status-current-format "#[fg=$border_color,bg=default]$L#[fg=$text_color,bg=$border_color,bold] #I:#W #[fg=$border_color,bg=default]$R"
    tmux set-option -g window-status-separator ""

    # Status left: session bubble (lavender)
    tmux set-option -g status-left "#[fg=$accent_color,bg=default]$L#[fg=$dark_fg,bg=$accent_color,bold] #S #[fg=$accent_color,bg=default]$R "

    # Status right: dir bubble | date bubble | clock bubble
    local dir_bubble="#[fg=$border_color,bg=default]$L#[fg=$text_color,bg=$border_color] #([ #{pane_current_path} = \$HOME ] && echo '~' || basename #{pane_current_path}) #[fg=$border_color,bg=default]$R"
    local date_bubble="#[fg=$border_color,bg=default]$L#[fg=$text_color,bg=$border_color] #(date +%d) #[fg=$border_color,bg=default]$R"
    local clock_bubble="#[fg=$accent_color,bg=default]$L#[fg=$dark_fg,bg=$accent_color,bold] #(date +%H:%M) #[fg=$accent_color,bg=default]$R"
    tmux set-option -g status-right "$dir_bubble $date_bubble $clock_bubble"

    # Copy mode styling
    tmux set-option -g mode-style "bg=$active_color,fg=$dark_fg"

    # Clock mode
    tmux set-option -g clock-mode-colour "$active_color"
    tmux set-option -g clock-mode-style 24
}

apply_theme
