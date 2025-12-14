# Monet Setup: Connecting Emacs with Claude Code in Ghostty

This guide explains how to connect your Doom Emacs configuration with Claude Code running in Ghostty using the Monet IDE integration.

## Prerequisites

- Doom Emacs with Monet package installed (already configured in this setup)
- Claude Code CLI tool installed
- Ghostty terminal

## Setup Steps

### 1. Start Monet Server in Emacs

In Emacs, start the Monet server:

**Method 1 - Using Leader Key:**
- Press `SPC k S` (Space + k + Shift+S)

**Method 2 - Using Monet Prefix:**
- Press `C-c m s` (Ctrl+c, m, s)

You'll see a message in the minibuffer showing the port number:
```
Monet server started on port 8080
```

**Important:** Note the port number - you'll need it for the next step.

### 2. Launch Claude Code with IDE Integration

In your Ghostty terminal, run Claude Code with these environment variables:

```bash
ENABLE_IDE_INTEGRATION=t CLAUDE_CODE_SSE_PORT=8080 claude
```

Replace `8080` with the actual port number from step 1.

## Available Commands

Once connected, you can use these Monet commands in Emacs:

| Keybinding | Command | Description |
|------------|---------|-------------|
| `SPC k S` | `monet-start-server` | Start the Monet server |
| `SPC k l` | `monet-list-sessions` | List active Monet sessions |
| `SPC k d` | `monet-show-diff` | Show diff from Claude's changes |
| `C-c m s` | `monet-start-server` | Alternative start server binding |

## Workflow Example

1. **Start Server:** Press `SPC k S` in Emacs
   - Note the port (e.g., "Monet server started on port 8080")

2. **Launch Claude:** In Ghostty terminal:
   ```bash
   ENABLE_IDE_INTEGRATION=t CLAUDE_CODE_SSE_PORT=8080 claude
   ```

3. **Work with Claude:** 
   - Ask Claude about your code
   - Request changes or improvements
   - Claude can now read your project files

4. **Review Changes:** In Emacs, press `SPC k d` to:
   - See diffs of Claude's proposed changes
   - Review modifications before applying
   - Accept or reject individual changes

5. **Manage Sessions:** Use `SPC k l` to:
   - See active Claude sessions
   - Monitor connection status

## How It Works

The Monet integration creates a bridge between Emacs and Claude Code:

- **File Access:** Claude can read files from your current project
- **Change Proposals:** Claude suggests modifications as diffs
- **Review Control:** You maintain full control over what changes are applied
- **Real-time Sync:** Changes are communicated via Server-Sent Events (SSE)

## Troubleshooting

### Server Won't Start
- Check if the port is already in use
- Try restarting Emacs
- Verify Monet is properly installed with `SPC h d m monet`

### Claude Can't Connect
- Ensure the port number matches exactly
- Check that `ENABLE_IDE_INTEGRATION=t` is set
- Verify Claude Code is updated to the latest version

### No Diffs Showing
- Make sure you're using `SPC k d` after Claude suggests changes
- Check the Monet session list with `SPC k l`
- Restart both the server and Claude Code connection

## Configuration

The Monet configuration is already set up in your `config.org`:

```emacs-lisp
;; Monet - IDE integration for Claude Code
(use-package! monet
  :config
  ;; Enable Monet mode globally
  (monet-mode 1)
  
  ;; Configure diff handling
  (setq monet-diff-tool 'monet-ediff-tool)  ; Use ediff for interactive diffs
  
  ;; Set custom keybindings for Monet
  (setq monet-prefix-key "C-c m"))
```

This setup provides seamless integration between your Emacs workflow and Claude's AI assistance while keeping you in control of all code changes.