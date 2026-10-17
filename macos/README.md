# macOS system preferences

Binary ~/Library/Preferences plists are not captured verbatim - they contain
per-app account state, window state, and other churn that does not belong in a
dotfiles repository. Instead this directory keeps a curated, reviewable export
of the preference domains that actually shape the desktop.

| File | Domain | Covers |
| --- | --- | --- |
| defaults/NSGlobalDomain.plist | NSGlobalDomain | locale, keyboard repeat, scroll direction, window behaviour |
| defaults/com.apple.dock.plist | com.apple.dock | icon size, magnification, autohide, hot corners, persistent apps |
| defaults/com.apple.finder.plist | com.apple.finder | default view, extensions, path bar, search scope |
| defaults/com.apple.screencapture.plist | com.apple.screencapture | screenshot location and format |
| defaults/com.apple.menuextra.clock.plist | com.apple.menuextra.clock | clock format |
| defaults/com.apple.controlcenter.plist | com.apple.controlcenter | menu bar modules |
| defaults/com.apple.AppleMultitouchTrackpad.plist | com.apple.AppleMultitouchTrackpad | tap to click, three-finger drag |
| defaults/com.apple.AppleMultitouchMouse.plist | com.apple.AppleMultitouchMouse | mouse gestures |
| defaults/com.apple.symbolichotkeys.plist | com.apple.symbolichotkeys | global keyboard shortcuts |
| defaults/com.apple.desktopservices.plist | com.apple.desktopservices | .DS_Store on network/USB volumes |
| defaults/com.apple.TextEdit.plist | com.apple.TextEdit | plain-text default |

## Restore

```sh
./macos/restore.sh       # import everything and restart Dock/Finder
./macos/restore.sh -n    # dry run, print what would be imported
```

## Re-capture

```sh
for domain in $(basename -s .plist macos/defaults/*.plist); do
  defaults export "$domain" "macos/defaults/$domain.plist"
done
```

`defaults export` and `defaults import` round-trip a whole domain, so re-running
the export after changing a preference keeps this snapshot current.
