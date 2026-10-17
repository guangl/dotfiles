# macOS system preferences

Binary `~/Library/Preferences` plists are not captured verbatim - they contain
per-app account state, window state, and other churn that does not belong in a
dotfiles repository. Instead this directory keeps a curated, reviewable export
of the preference domains that actually shape the desktop.

All files are XML plists (`plutil -convert xml1`), so diffs are readable and
`scripts/sync_home.py` can scan them for secrets.

| File | Domain | Covers |
| --- | --- | --- |
| defaults/NSGlobalDomain.plist | NSGlobalDomain | locale, keyboard repeat, scroll direction, window behaviour |
| defaults/com.apple.dock.plist | com.apple.dock | icon size, magnification, autohide, hot corners, persistent apps |
| defaults/com.apple.finder.plist | com.apple.finder | default view, extensions, path bar, search scope |
| defaults/com.apple.screencapture.plist | com.apple.screencapture | screenshot location and format |
| defaults/com.apple.menuextra.clock.plist | com.apple.menuextra.clock | clock format |
| defaults/com.apple.controlcenter.plist | com.apple.controlcenter | menu bar modules |
| defaults/com.apple.systemuiserver.plist | com.apple.systemuiserver | menu bar extras |
| defaults/com.apple.WindowManager.plist | com.apple.WindowManager | Stage Manager |
| defaults/com.apple.universalaccess.plist | com.apple.universalaccess | accessibility options |
| defaults/com.apple.AppleMultitouchTrackpad.plist | com.apple.AppleMultitouchTrackpad | tap to click, three-finger drag |
| defaults/com.apple.AppleMultitouchMouse.plist | com.apple.AppleMultitouchMouse | mouse gestures |
| defaults/com.apple.symbolichotkeys.plist | com.apple.symbolichotkeys | global keyboard shortcuts |
| defaults/com.apple.iCal.plist | com.apple.iCal | calendar preferences |
| defaults/com.apple.ActivityMonitor.plist | com.apple.ActivityMonitor | update interval, Dock icon |
| defaults/com.apple.Terminal.plist | com.apple.Terminal | Terminal.app profiles |

Deliberately absent: `com.apple.TextEdit` (its preferences live inside the app's
sandbox container, not in `~/Library/Preferences`) and
`com.apple.desktopservices` (no keys set on this machine).

## Restore

```sh
./macos/restore.sh       # import everything and restart Dock/Finder
./macos/restore.sh -n    # dry run, print what would be imported
```

## Re-capture

```sh
./macos/capture.sh       # re-export every domain above as XML
```

`defaults export` and `defaults import` round-trip a whole domain, so re-running
the capture after changing a preference keeps this snapshot current. Domains
that do not exist on the machine are skipped silently.
