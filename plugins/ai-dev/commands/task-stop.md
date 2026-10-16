---
name: task-stop
description: Stop all background processes for a task without archiving it
---

# /task-stop

Stop all recorded processes for an active task. This does NOT archive the task — use it to free ports, restart services, or clean up before re-running.

## Usage

```
/task-stop <task-dir>
```

`task-dir` is the task directory name or its suffix, e.g. `task-login-pwd-20261010-a1b2c3` or `login-pwd-20261010-a1b2c3`.

## Instructions

1. **Resolve the task directory**:
   - If input starts with `task-`, look for `~/task_workspaces/<input>`
   - Otherwise, look for `~/task_workspaces/task-<input>`
   - If not found: "Task not found. Use /task-list to see active tasks."

2. **Read `processes.json`** in the task directory (if it exists).
   - If the file doesn't exist or is empty: "No recorded processes for this task."
   - Show the user what will be stopped: repo name, PID, command, port.

3. **Confirm with the user**: "Stop these N process(es)? (y/n)"

4. **Stop each process**:
   - Check if alive: `kill -0 <pid> 2>/dev/null`
   - If alive: `kill <pid>`, wait 2 seconds, then `kill -9 <pid>` if still running.
   - Also kill child processes: `pkill -P <pid>`
   - Report which were stopped, which were already dead.

5. **Clear processes.json**:
   - After stopping all processes, reset `processes.json` to `{}`.
   - This way next time sub-agents start services, they record fresh PIDs.

6. **Fallback if processes.json is missing or stale**:
   - Ask the user for ports or service names to look up.
   - `lsof -ti:<port> | xargs kill -9`
   - Or `pkill -f "<branch-name>"`

## Rules

- This does NOT archive the task or remove worktrees — it only stops processes.
- If a process won't die after SIGTERM + SIGKILL, report it to the user instead of looping.
- Always confirm before killing — the user might be actively using the service.
