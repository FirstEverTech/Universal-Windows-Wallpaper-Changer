<p align="left">
  <a href="https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/blob/main/docs/NEW-RELEASE-GUIDE_EN_2026.md">🇬🇧 English</a> |
  <a href="https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/blob/main/docs/NEW-RELEASE-GUIDE_PL_2026.md">🇵🇱 Polski</a> |
  <a href="https://translate.google.com/translate?sl=en&tl=de&u=https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/blob/main/docs/NEW-RELEASE-GUIDE_EN_2026.md">🇩🇪 Deutsch</a> |
  <a href="https://translate.google.com/translate?sl=en&tl=fr&u=https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/blob/main/docs/NEW-RELEASE-GUIDE_EN_2026.md">🇫🇷 Français</a> |
  <a href="https://translate.google.com/translate?sl=en&tl=es&u=https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/blob/main/docs/NEW-RELEASE-GUIDE_EN_2026.md">🇪🇸 Español</a> |
  <a href="https://translate.google.com/translate?sl=en&tl=pt&u=https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/blob/main/docs/NEW-RELEASE-GUIDE_EN_2026.md">🇧🇷 Português</a> |
  <a href="https://translate.google.com/translate?sl=en&tl=nl&u=https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/blob/main/docs/NEW-RELEASE-GUIDE_EN_2026.md">🇳🇱 Nederlands</a>
  <br>
  <a href="https://translate.google.com/translate?sl=en&tl=zh-CN&u=https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/blob/main/docs/NEW-RELEASE-GUIDE_EN_2026.md">🇨🇳 中文</a> |
  <a href="https://translate.google.com/translate?sl=en&tl=ja&u=https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/blob/main/docs/NEW-RELEASE-GUIDE_EN_2026.md">🇯🇵 日本語</a> |
  <a href="https://translate.google.com/translate?sl=en&tl=ko&u=https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/blob/main/docs/NEW-RELEASE-GUIDE_EN_2026.md">🇰🇷 한국어</a> |
  <a href="https://translate.google.com/translate?sl=en&tl=it&u=https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/blob/main/docs/NEW-RELEASE-GUIDE_EN_2026.md">🇮🇹 Italiano</a> |
  <a href="https://translate.google.com/translate?sl=en&tl=tr&u=https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/blob/main/docs/NEW-RELEASE-GUIDE_EN_2026.md">🇹🇷 Türkçe</a> |
  <a href="https://translate.google.com/translate?sl=en&tl=ar&u=https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/blob/main/docs/NEW-RELEASE-GUIDE_EN_2026.md">🇸🇦 العربية</a> |
  <a href="https://translate.google.com/translate?sl=en&tl=hi&u=https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/blob/main/docs/NEW-RELEASE-GUIDE_EN_2026.md">🇮🇳 हिन्दी</a> |
  <a href="https://translate.google.com/translate?sl=en&tl=ru&u=https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/blob/main/docs/NEW-RELEASE-GUIDE_EN_2026.md">🇷🇺 Русский</a>
</p>

# New Release Guide

---

## 1. Prepare the Files

Update the version and contents of:

- `universal-windows-wallpaper-changer.ps1` — change `.VERSION` in the PSScriptInfo block and `$ScriptVersion` in the code

---

## 2. Generate the SHA256 File

Run `Generate_Hash.bat` — it will generate a hash file for the PS1:

```
universal-windows-wallpaper-changer-202x.xxx.xxxx-ps1.sha256
```

---

## 3. Create the SFX Archive in WinRAR

Add the following file to the archive:
```
universal-windows-wallpaper-changer.ps1
```

### General tab

| Option | Value |
|--------|-------|
| Archive name | `WindowsWallpaperChanger-202x.xx.xxxx-Win10-Win11.exe` |
| Archive format | `RAR` |
| Compression method | `Best` |
| Create SFX archive | `Yes` |
| Create solid archive | `Yes` |
| Add recovery record | `Yes` |
| Lock archive | `Yes` |

### Advanced → SFX options → General

| Option | Value |
|--------|-------|
| Path to extract | `%SystemRoot%\Temp\universal-windows-wallpaper-changer` |

### Advanced → SFX options → Setup

| Option | Value |
|--------|-------|
| Run after extraction | `powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Normal -File "%SystemRoot%\Temp\universal-windows-wallpaper-changer\universal-windows-wallpaper-changer.ps1"` |

### Advanced → SFX options → Modes

| Option | Value |
|--------|-------|
| Hide all | `Yes` |

### Advanced → SFX options → Update

| Option | Value |
|--------|-------|
| Overwrite all files | `Yes` |

### Advanced → SFX options → Logo and icon

| Option | Value |
|--------|-------|
| Load SFX icon | `universal-windows-wallpaper-changer-icon.ico` |

---

## 4. Digitally Sign the SFX File

Sign the generated EXE with your certificate:

```
WindowsWallpaperChanger-202x.xx.xxxx-Win10-Win11.exe
```

---

## 5. Publish the Release on GitHub

Create a new release and attach the following files:

```
WindowsWallpaperChanger-202x.xx.xxxx-Win10-Win11
universal-windows-wallpaper-changer-202x.xx.xxxx-ps1.sha256
```

---

## 6. Update the Version File on GitHub

Update the contents of:
```
/src/universal-windows-wallpaper-changer.ver
```

---

## 7. Publish to PowerShell Gallery

Publish **only after** the GitHub release is live — the script verifies a hash that must already be available in the repo.
> Your API Key can be copied from your ([PowerShell Gallery](https://www.powershellgallery.com/account/apikeys)) account.

```powershell
Publish-Script -Path ".\universal-windows-wallpaper-changer.ps1" `
               -NuGetApiKey "your-api-key" `
               -Repository PSGallery
```

---

Author: Marcin Grygiel aka FirstEver ([LinkedIn](https://www.linkedin.com/in/marcin-grygiel))
