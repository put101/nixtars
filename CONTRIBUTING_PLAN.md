# Contribution Plan: Fix OpenCode Agent Buffering

## Issue
The OpenCode agent plugin in `ralph-tui` processes output from the `opencode` CLI in chunks. Sometimes, these chunks split a JSON line in half (e.g., `{"type": "te` in one chunk and `xt"...}` in the next). The current implementation attempts to parse each chunk immediately, causing `JSON.parse` errors for partial lines. These errors are caught and ignored, resulting in data loss (blank output in the TUI).

## Fix
Implement a string buffer to accumulate incoming data. We only process the buffer when a newline character (`\n`) is found, extracting complete lines for parsing and leaving any remaining partial data in the buffer for the next chunk.

## Steps to Contribute

I have prepared the following steps to create a Pull Request to the official repository.

1.  **Fork the Repository** (if not already done)
    ```bash
    gh repo fork subsy/ralph-tui --clone=false --remote=true
    ```

2.  **Clone/Update Local Repository**
    ```bash
    cd ~/repos/ralph-tui
    git checkout main
    git pull upstream main  # Ensure we are up to date with official repo
    ```

3.  **Create a Feature Branch**
    ```bash
    git checkout -b fix/opencode-buffering
    ```

4.  **Apply the Fix**
    I will copy the verified patched file from your Nix workspace to the repository.
    ```bash
    cp ~/nixtars/pkgs/patched/opencode.ts src/plugins/agents/builtin/opencode.ts
    ```

5.  **Commit the Changes**
    ```bash
    git add src/plugins/agents/builtin/opencode.ts
    git commit -m "fix(opencode): implement line buffering for reliable JSON parsing"
    ```

6.  **Push and Open PR**
    ```bash
    git push -u origin fix/opencode-buffering
    gh pr create --title "fix(opencode): implement line buffering for reliable JSON parsing" --body "Fixes an issue where partial JSON chunks from the opencode CLI caused JSON parse errors and data loss. This change buffers stdout and only parses complete lines."
    ```

## Action
I will now execute steps 1-5. I will **STOP** before step 6 (pushing/opening PR) as requested, so you can review the state.

```