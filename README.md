🇬🇧 English | 🇵🇱 Polski

# 🖼️ **Universal Windows Wallpaper Changer**

## 🔧 Set a Fresh 4K Wallpaper on Windows — Once, or on a Schedule

**Universal Windows Wallpaper Changer** downloads a random, free 4K wallpaper from a free image service (or picks one from your own folder) and applies it as the Windows desktop wallpaper. Runs once, or keeps changing in the background with a tray icon.

This project was built through a pragmatic collaboration between human expertise and AI-assisted tooling.

### Why This Tool Exists

Windows has no built-in way to rotate wallpapers from multiple free sources without third-party bloatware. This tool gives you:
- **Zero API keys needed** for the default sources (Bing, Picsum, Wallhaven)
- **Background mode** with tray icon and start at sign-in
- **SHA-256 self-verification** against GitHub Releases
- **No administrator rights** required

* * *

👉 Share your feedback via [Issues](https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/issues)!

* * *

## 💖 Support This Project

**Universal Windows Wallpaper Changer** is free and open-source — maintained by a single developer. The provider integrations, background mode, and image filtering pipeline are maintained in my free time.

If this tool saved you time or made your desktop a little nicer, consider supporting development.

## 🏢 Sponsors

_No sponsors yet — be the first and add your company ad!_

## ❤️ Supporters

A huge thank you to all our supporters – your contributions make a real difference.  
Your name could be here too.

- Sqania, jadeanemail, westor7, J. A. Dean, Bartechr, tsantaliki, PegHorse

## ⭐ Stars

If this project helped you, please click the "Star" button at the top of this page on GitHub.

<!-- STAR-GRAPH-START -->
<!-- stars-graph.yml will auto-commit the chart here. Do not remove this comment block. -->
<!-- STAR-GRAPH-END -->

## 🌐 Community & Distribution

- Official threads on forums:  
🔗 **TechPowerUp**, **Guru3D**, **WinClub**, **ElevenForum**, **Win-Raid**, **Station-Drivers**

## 💼 Career Opportunity

**I specialize in Windows deployment, driver automation, hardware compatibility, Microsoft technologies, infrastructure analysis, and custom IT tooling. If your organization faces automation, deployment, device management, or unsupported hardware environments, let's discuss how I can help.**

🔗 **Business Contact:** firstever.tech/contact  
🔗 **LinkedIn Profile:** linkedin.com/in/marcin-grygiel

* * *

## 📑 **1. Table of Contents**

1. Table of Contents
2. Release Highlights  
   2.1 Latest Version  
   2.2 Previous Release
3. Application Overview
4. Key Features  
   4.1 Multiple Free Sources  
   4.2 Background Mode  
   4.3 Security & Verification  
   4.4 Customization
5. System Requirements
6. Quick Start  
   6.1 Method 1: Interactive Start Screen  
   6.2 Method 2: One Random Wallpaper  
   6.3 Method 3: Background Changer  
   6.4 Method 4: PowerShell Gallery  
   6.5 Command-Line Options
7. How It Works  
   7.1 Self-Verification & Update Check  
   7.2 Image Source Selection  
   7.3 Download & Filter Pipeline  
   7.4 Wallpaper Application
8. Security First Approach
9. Usage Scenarios
10. Download Options
11. Project Structure
12. Release Structure
13. Frequently Asked Questions (FAQ)
14. Image Source Comparison
15. Performance Metrics
16. Known Issues
17. Ready to Use?
18. Contributing
19. License
20. Acknowledgments
21. Important Links
22. Author & Contact

↑ Back to top

* * *

## 🎉 **2. Release Highlights**

### 2.1 Latest Version

**v2026.11.0001** → [Release Notes](https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/releases/tag/v2026.11.0001)

### 🆕 Initial Release

- **One random 4K wallpaper** from free sources that need no API key: Bing, Picsum, Wallhaven (or a random mix)
- **Background mode** with tray icon and start at sign-in — changes the wallpaper every 1–1440 minutes
- **Multiple sources**: free services, your own folders (used in place), your own image links or `.txt` lists, and optional API-key services
- **Security**: SHA-256 self-hash verification against GitHub Releases, optional auto-update
- **Dynamic credits**: support links loaded from `data/universal-windows-wallpaper-changer-credits.txt` on GitHub RAW
- **API keys** stored encrypted with DPAPI for the current Windows user

↑ Back to top

### 2.2 Previous Release

_None — this is the initial release._

↑ Back to top

## 🖼️ **3. Application Overview**

| Phase 1 | Phase 2 | Phase 3 | Phase 4 |
|---------|---------|---------|---------|
| _Security check & update check_ | _Source selection & image fetch_ | _Filter & verify (size, dimensions)_ | _Apply wallpaper / start tray_ |

> **📸 SCREENSHOT PLACEHOLDER 1:**  
> Insert here: `docs/screenshots/phase-overview.png` — four-panel graphic showing the console phases.  
> **Action:** Skel do góry, wstaw obrazek po utworzeniu folderu `docs/screenshots/` w repo.

↑ Back to top

## ✨ **4. Key Features**

### 🖼️ 4.1 Multiple Free Sources

| Source | API key | Query | Notes |
|--------|---------|-------|-------|
| **Bing** | No | No | Landscape only, max 3840 px |
| **Picsum** | No | No | Random photos, server-side crop available |
| **Wallhaven** | Optional | Yes | SFW only, higher rate limits with a key |
| **Photos** | No | No | Windows Pictures folder, used in place |
| **Folder** | No | No | Any folder, used in place, never copied/deleted |
| **URL** | No | No | Image link or `.txt` list of links |
| **Flickr** | Yes | Yes | **EXPERIMENTAL** |
| **Immich** | Yes | No | **EXPERIMENTAL**, own server |
| **Pexels** | Yes | Yes | New keys currently paused |
| **Pixabay** | Yes | Yes | Free API: max 1280 px |
| **Unsplash** | Yes | Yes | 50 requests per hour |

### ⚡ 4.2 Background Mode

- Hidden PowerShell process with **tray icon**
- **Start at sign-in** via `HKCU\...\Run`
- Pause / Resume / Change now from tray menu
- State persisted in `%LOCALAPPDATA%\UniversalWindowsWallpaperChanger\state.json`

### 🛡️ 4.3 Security & Verification

- **SHA-256 self-hash** verified against GitHub Releases on every interactive start
- **Auto-update** checks `src/universal-windows-wallpaper-changer.ver` on GitHub RAW
- **DPAPI-encrypted API keys** (never shown, never logged, never accepted on command line)
- **No admin rights** required — everything runs in HKCU

### 🎨 4.4 Customization

- Minimum width, minimum pixels, minimum file size filters
- Orientation: landscape, portrait, squarish
- Output format (JPG/PNG) and quality for services that convert
- `-Keep` limit for stored downloads (never deletes current wallpaper)
- API keys overridable via environment variables

> **📸 SCREENSHOT PLACEHOLDER 2:**  
> Insert here: `docs/screenshots/tray-menu.png` — tray icon context menu showing "Current wallpaper", "Pause", "Change now".  
> **Action:** Skel w tej sekcji, wstaw obrazek po zrobieniu screenshota.

↑ Back to top

## 📋 **5. System Requirements**

| Component | Minimum | Recommended | Notes |
|-----------|---------|-------------|-------|
| Windows | 10 1809 (17763) | 11 22H2+ | 1809 requires .NET 4.7.2+ |
| .NET Framework | 4.7.2 | 4.8+ | Required for TLS 1.2 |
| PowerShell | 5.1 | 5.1+ | Windows PowerShell 5.1 included |
| Administrator | **Not required** | **Not required** | HKCU only |
| Internet | Required for online sources | Required | For hash verification & updates |
| RAM | 2 GB | 4 GB+ | For image processing |
| Disk Space | 100 MB | 500 MB+ | Depends on `-Keep` setting |

### Windows Version Support

| Version | Build | Status |
|---------|-------|--------|
| Windows 11 | All builds | ✅ Full |
| Windows 10 | 22H2+ | ✅ Full |
| Windows 10 | 21H2 / 21H1 | ✅ Full |
| Windows 10 | 20H2–1809 | ✅ Full |
| Windows 10 | LTSB 2016/2015 | ⚠️ Limited (TLS 1.2 manual updates) |

↑ Back to top

## ⚡ **6. Quick Start**

### 6.1 Method 1: Interactive Start Screen

```powershell
.\universal-windows-wallpaper-changer.ps1
```

Opens the start screen: wizard or one random 4K wallpaper.

### 6.2 Method 2: One Random Wallpaper

```powershell
.\universal-windows-wallpaper-changer.ps1 -Once
```

Sets one random 4K wallpaper from Bing, Picsum, or Wallhaven.

### 6.3 Method 3: Background Changer

```powershell
.\universal-windows-wallpaper-changer.ps1 -Source Wallhaven -Query "forest" -IntervalMinutes 30
```

Changes the wallpaper every 30 minutes in the background with tray icon.

Check status:

```powershell
.\universal-windows-wallpaper-changer.ps1 -Background Status
```

Stop and remove settings:

```powershell
.\universal-windows-wallpaper-changer.ps1 -Background Stop
```

### 6.4 Method 4: PowerShell Gallery

```powershell
Install-Script -Name universal-windows-wallpaper-changer
universal-windows-wallpaper-changer.ps1
```

> **📸 SCREENSHOT PLACEHOLDER 3:**  
> Insert here: `docs/screenshots/start-screen.png` — start screen with options [1] Wizard, [2] One random 4K wallpaper.  
> **Action:** Skel w tej sekcji, wstaw obrazek po zrobieniu screenshota.

### 6.5 Command-Line Options

| Option | Description |
|--------|-------------|
| `-help`, `-?` | Display help and exit |
| `-version`, `-v` | Display version and exit |
| `-wizard` | Step-by-step setup wizard |
| `-source <name>` | Image source (Random, Bing, Picsum, Wallhaven, Photos, Folder, Flickr, Immich, Pexels, Pixabay, Unsplash, URL) |
| `-query <text>` | Search phrase, e.g. "nature winter" |
| `-folder <path>` | Folder for `-Source Folder` |
| `-url <link\|file>` | Image link, or `.txt` list |
| `-minwidth <px>` | Minimum width. Default: 3840 |
| `-minpixels <n>` | Minimum width×height. Default: 0 (off) |
| `-minsize <size>` | Minimum file size, e.g. 500K, 1M |
| `-quality <1-100>` | JPEG quality for services that convert |
| `-format <jpg\|png>` | Output format |
| `-orientation <o>` | landscape / portrait / squarish |
| `-maxattempts <n>` | Images to try before failing (1-20) |
| `-dir <path>` | Where downloaded wallpapers are stored |
| `-keep <n>` | Keep last n downloaded files (0 = all) |
| `-keepcurrentonly` | Keep only current wallpaper |
| `-once` | Change once and exit |
| `-intervalminutes <n>` | Change every n min (1-1440) in background |
| `-profile [name]` | Run a saved profile |
| `-fresh` | Discard stored queue |
| `-immichurl <url>` | Immich server address |
| `-background <cmd>` | Status / Start / Stop / Pause / Resume |
| `-keys` | Show which keys are set |
| `-setkey <service>` | Enter a key (hidden input) |
| `-removekey <svc>` | Remove API key |
| `-jpegimportquality <Max\|Default>` | Set Windows JPEG import quality |
| `-quiet`, `-q` | No screens, no prompts, no credits |
| `-noupdate` | Skip update check |
| `-skipverify`, `-s` | Skip self-hash verification |
| `-debug`, `-d` | Print diagnostic messages |

↑ Back to top

## 🔧 **7. How It Works**

### 🔒 7.1 Self-Verification & Update Check

- **Integrity Verification** — Validates script SHA-256 against GitHub Release
- **Update Detection** — Compares current version with `src/universal-windows-wallpaper-changer.ver`
- **PSGallery Path** — If installed via `Install-Script`, updates go through `Update-Script`

### 🖼️ 7.2 Image Source Selection

- `Random` picks Bing, Picsum, and Wallhaven in random order
- Local sources (`Photos`, `Folder`) scan files in place — never copy or delete
- `URL` accepts a single link or a `.txt` list (local file or remote link)

### 📊 7.3 Download & Filter Pipeline

- Metadata pre-filter (width, height, orientation) before download
- Download to temp, then verify real dimensions via System.Drawing
- File type detected from magic bytes (not extension)
- Accepted files renamed to `<provider>_img_<date>_<N>.<ext>`

### ⚡ 7.4 Wallpaper Application

- `SystemParametersInfo` with `SPI_SETDESKWALLPAPER`
- `WallpaperStyle = 10` (Fill), `TileWallpaper = 0`
- Attribution logged to `%LOCALAPPDATA%\...\attribution.log`
- Old files cleaned up according to `-Keep`

↑ Back to top

## 🛡 **8. Security First Approach**

### 🔒 8.1 Verified Security Layers

```
1. Self-Integrity   → Script Hash Verification against GitHub Releases
2. API Key Safety   → DPAPI encryption (current Windows user), never logged
3. Command Line     → Keys never accepted on the command line
4. Log Safety       → Secrets masked with Hide-Secret
5. Update Safety    → Version verification before download
6. PSGallery        → Verified by PowerShellGet (self-check skipped)
```

### 🏷️ 8.2 Why is the certificate "not trusted"?

The FirstEver.tech certificate is self-signed. The PowerShell script is the authoritative source. Its SHA-256 hash is published on GitHub and verified automatically on every run. The SFX executable is a convenience wrapper — its contents are the same verified PS1.

### 🛡 8.3 Why does VirusTotal show detections for the SFX executable?

_Once the SFX is released:_ The SFX package may show a small number of detections — known false positives from SFX+PowerShell combinations. The PS1 script itself scores clean.

> **📸 SCREENSHOT PLACEHOLDER 4:**  
> Insert here: `docs/screenshots/virustotal-ps1.png` — VirusTotal scan of the PS1 showing 0 detections.  
> **Action:** Skel w tej sekcji, wstaw obrazek po zrobieniu screenshota.

↑ Back to top

## 🎯 **9. Usage Scenarios**

### 🏠 9.1 Home Users

- **Fresh wallpaper daily** without third-party apps
- **No API keys** for default sources
- **One-click operation** via wizard

### 💼 9.2 IT Professionals

- **Silent deployment** via `-quiet`
- **Per-user** — no admin rights, runs in HKCU
- **Profile-based** — save settings with `-wizard`, deploy with `-Profile`

### 🛠️ 9.3 System Builders

- **Pre-configured profiles** for customer machines
- **Folder source** — use curated wallpapers without downloading
- **Background mode** — set once, runs at sign-in

↑ Back to top

## 📥 **10. Download Options**

### 10.1 Option 1: SFX Executable (Recommended)

- **File:** `Universal-Windows-Wallpaper-Changer-202x.xx.xxxx.exe`
- **Features:** One-click execution, automatic extraction
- **For:** Most users, easiest method

### 10.2 Option 2: Direct PS1

Download `universal-windows-wallpaper-changer.ps1` and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\universal-windows-wallpaper-changer.ps1
```

### 10.3 Option 3: PowerShell Gallery

```powershell
Install-Script -Name universal-windows-wallpaper-changer
```

### 10.4 Option 4: Source Code

Clone the repository and run from `src/`.

↑ Back to top

## 📁 **11. Project Structure**

```
Universal-Windows-Wallpaper-Changer/
├── README.md
├── LICENSE
├── .gitignore
├── universal-windows-wallpaper-changer.ps1     # Main script (dev)
├── src/
│   ├── universal-windows-wallpaper-changer.ps1 # Auto-update copy (optional)
│   └── universal-windows-wallpaper-changer.ver # Version string
└── data/
    ├── universal-windows-wallpaper-changer-credits.txt
    └── universal-windows-wallpaper-changer-ads.txt
```

**Note:** The `src/` copy is optional. The main script is in the repository root. The `.ver` file is always read from `src/` on GitHub RAW.

↑ Back to top

## 📦 **12. Release Structure**

### 12.1 Primary Files

| File | Purpose |
|------|---------|
| `Universal-Windows-Wallpaper-Changer-<version>.exe` | SFX self-extracting package |
| `universal-windows-wallpaper-changer.ps1` | Main script (for direct PS1 users) |

### 12.2 Verification Files

| File | Purpose |
|------|---------|
| `universal-windows-wallpaper-changer-<version>-ps1.sha256` | SHA-256 hash of the PS1 script (for self-check) |

### 12.3 Data Files (loaded from `main` branch, not Release)

| File | Purpose |
|------|---------|
| `src/universal-windows-wallpaper-changer.ver` | Latest version string for auto-update |
| `data/universal-windows-wallpaper-changer-credits.txt` | Credits screen content |
| `data/universal-windows-wallpaper-changer-ads.txt` | Promotional links (keys A–E) |

↑ Back to top

## ❓ **13. Frequently Asked Questions (FAQ)**

### 🤔 13.1 Is this tool safe to use?

Yes. The tool:
- Verifies its own SHA-256 hash against GitHub Releases
- Never requires administrator rights
- Stores API keys encrypted with DPAPI
- Never writes keys to logs or accepts them on the command line

### 🔄 13.2 Do I need an API key?

No, for the default sources: **Bing, Picsum, Wallhaven** work without a key. Wallhaven has higher rate limits with a free key.

### 🖼️ 13.3 Where are wallpapers saved?

By default: `%USERPROFILE%\Pictures\Universal Windows Wallpapers\`.  
Change with `-Dir <path>`.

### ⚠️ 13.4 Are Bing images copyrighted?

Yes. Bing images are copyrighted and meant for personal use. The tool does not claim ownership or redistribute images. For commercial use, stick to Picsum, your own folders, or sources with explicit licenses.

### 🔧 13.5 What if a download fails?

The tool tries up to `-MaxAttempts` images (default 5). If all fail, it reports the reasons. For `Random`, it falls back through Bing → Picsum → Wallhaven.

### 🔄 13.6 How does the automatic update check work?

The tool compares `$ScriptVersion` with `src/universal-windows-wallpaper-changer.ver` on GitHub RAW. If a newer version exists, it offers to download it (with SHA-256 verification).

### 🔒 13.7 What does self-hash verification do?

Before running interactively, the tool calculates its own SHA-256 hash and compares it with the reference hash published in the GitHub Release. This ensures the script hasn't been modified or corrupted.

### 🏷️ 13.8 Why is the certificate "not trusted"?

The FirstEver.tech certificate is self-signed. The PS1 script is the authoritative source, verified by SHA-256 on every run. The SFX is a convenience wrapper.

### 🛡️ 13.9 Why does VirusTotal show detections for the SFX?

_Once released:_ Known false positives from SFX + PowerShell execution. The PS1 itself scores clean. See Section 8.3.

### 💾 13.10 Where is the log file?

`%LOCALAPPDATA%\UniversalWindowsWallpaperChanger\wallpaper.log`

### 🖥️ 13.11 Can I use this on a server?

Yes, but wallpaper changing is per-user. On Server Core (no desktop), it has no visible effect.

↑ Back to top

## 🖼️ **14. Image Source Comparison**

| Feature | Bing | Picsum | Wallhaven | Photos/Folder | API-key services |
|---------|------|--------|-----------|---------------|------------------|
| **API key** | No | No | Optional | No | Yes |
| **Query** | No | No | Yes | No | Yes |
| **4K native** | Yes (UHD) | Yes (server crop) | Yes (filter) | Depends | Varies |
| **Orientation filter** | Landscape only | Yes (server) | Yes | Local scan | Yes |
| **Used in place** | No | No | No | Yes | No |
| **Rate limit** | None | None | Higher with key | None | Varies |
| **Experimental** | No | No | No | No | Flickr, Immich |

↑ Back to top

## 📊 **15. Performance Metrics**

### 15.1 Typical Execution Time Breakdown

| Phase | Time | Description |
|-------|------|-------------|
| Compatibility Pre-Check | 5–10 s | OS build, .NET, TLS 1.2, GitHub connectivity |
| Verification & Update Check | 5–10 s | Self-hash + version check |
| Image Fetch & Download | 2–15 s | Depends on source and image size |
| Filter & Verify | 1–3 s | System.Drawing dimension check |
| Wallpaper Apply | < 1 s | SystemParametersInfo |

> **Note:** Times measured on typical SSD systems with broadband internet.

### 15.2 Disk Space Usage

| Component | Typical Size |
|-----------|-------------|
| Script | ~100 KB |
| Log file | < 512 KB (auto-trimmed) |
| Downloaded wallpapers | 2–10 MB each × `-Keep` count |
| State & queue files | < 1 MB |

↑ Back to top

## ⚠️ **16. Known Issues**

- **Bing images** are copyrighted and meant for personal use
- **Flickr and Immich** support is **experimental** — not verified against live accounts/servers
- **Pixabay** free API delivers at most **1280 px** regardless of `-MinWidth`
- **Unsplash** allows **50 requests per hour** — intervals under 5 minutes can hit the limit
- **Background mode** runs for the current user only (per-user registry HKCU)
- **Windows 10 LTSB 2015/2016** may need manual TLS 1.2 updates

↑ Back to top

## 🚀 **17. Ready to Use?**

### Quick Start Guide

```powershell
# One random 4K wallpaper
.\universal-windows-wallpaper-changer.ps1 -Once

# Background changer every 30 minutes
.\universal-windows-wallpaper-changer.ps1 -Source Wallhaven -Query "forest" -IntervalMinutes 30
```

### Verification Steps (Optional)

1. Download the `.sha256` file from the Release
2. Run: `Get-FileHash .\universal-windows-wallpaper-changer.ps1 -Algorithm SHA256`
3. Compare with the published hash

### Need Help?

- Check the [FAQ](#-13-frequently-asked-questions-faq)
- Open an [Issue](https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/issues)

↑ Back to top

## 🤝 **18. Contributing**

Contributions are welcome:
- **Bug reports** — include log file excerpts
- **Feature requests** — describe the use case
- **Provider integrations** — new free image sources

Please open an Issue before submitting a PR.

↑ Back to top

## 📄 **19. License**

MIT License. See [LICENSE](LICENSE) for details.

↑ Back to top

## 🙏 **20. Acknowledgments**

- **Bing**, **Picsum**, **Wallhaven** for free image APIs
- **Flickr**, **Immich**, **Pexels**, **Pixabay**, **Unsplash** for optional provider APIs
- The open-source PowerShell community

↑ Back to top

## 🔗 **21. Important Links**

- **Repository:** [github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer](https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer)
- **Releases:** [github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/releases](https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/releases)
- **Issues:** [github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/issues](https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/issues)
- **PowerShell Gallery:** [universal-windows-wallpaper-changer](https://www.powershellgallery.com/packages/universal-windows-wallpaper-changer)


↑ Back to top

## 👤 **22. Author & Contact**

**Marcin Grygiel / FirstEver.tech**

- **GitHub:** [github.com/FirstEverTech](https://github.com/FirstEverTech)
- **Business Contact:** [firstever.tech/contact](https://firstever.tech/contact)
- **LinkedIn:** [linkedin.com/in/marcin-grygiel](https://linkedin.com/in/marcin-grygiel)

↑ Back to top
