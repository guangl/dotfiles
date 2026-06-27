# ======== starship ====================
Invoke-Expression (&starship init powershell)
# =======================================

# ======== Atuin ========================
Invoke-Expression (& atuin init powershell | Out-String)
# =======================================

# ======== Zellij =======================
$env:ZELLIJ_AUTO_ATTACH = "false"
$env:ZELLIJ_AUTO_EXIT = "true"
Invoke-Expression (& zellij setup --generate-auto-start powershell | Out-String)
# =======================================

# ======== Alias =========================
function ls { eza --group-directories-first --icons @args }
# =========================================

# ======== Espanso =======================
$env:ESPANSO_CONFIG_DIR = "$HOME\.config\espanso"
# =======================================

# ======== Starship config ===============
$env:STARSHIP_CONFIG = "$HOME\.config\starship\config.toml"
# =========================================
