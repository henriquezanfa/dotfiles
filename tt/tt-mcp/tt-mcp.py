from typing import Any
import subprocess

TT = "/Users/henrique/.local/bin/tt"

from mcp.server import MCPServer

# Initialize MCPServer
mcp = MCPServer("tt-mcp")


def run_tt(*args: str) -> str:
    """Run tt with the given arguments and return its output."""
    try:
        result = subprocess.run(
            [TT, *args],
            capture_output=True,
            text=True,
            timeout=30,
        )
    except FileNotFoundError:
        return f"Error: tt not found at {TT}"
    except subprocess.TimeoutExpired:
        return "Error: tt timed out"

    if result.returncode != 0:
        return f"Error (exit {result.returncode}): {result.stderr.strip()}"
    return result.stdout.strip() or "Done."


@mcp.tool()
async def list_tasks() -> str:
    """List open todos from Apple Reminders."""
    return run_tt("list", "--no-interactive")

@mcp.tool()
def add_todo(title: str, list_name: str = "") -> str:
    """Add a todo to Apple Reminders.

    Args:
        title: What the reminder should say
        list_name: Optional Reminders list to put it in
    """
    args = [title]
    if list_name:
        args += ["--scope", list_name]
    return run_tt(*args)

if __name__ == "__main__":
    mcp.run(transport="stdio")
