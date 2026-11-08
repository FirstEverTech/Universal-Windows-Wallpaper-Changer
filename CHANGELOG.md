# Changelog

All notable changes to **Universal Windows Wallpaper Changer** will be documented in this file.

The format is loosely based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [v2026.11.0001](https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/releases/tag/v2026.11.0001) - 2026-11-08

### Initial Public Release

* First public version of **Universal Windows Wallpaper Changer**
* Sets one random 4K wallpaper, or keeps changing it in the background with a tray icon (every 1–1440 minutes, start at sign-in)
* Works for the current user only, no administrator rights required

### Features

* **Image sources without an API key**: FirstEverTech (author's own 4K photos, filterable by tags), Bing, Picsum, Wallhaven (or a random mix of them)
* **Local and custom sources**: Windows Pictures folder and any own folder (used in place, never copied or deleted), image links or `.txt` lists of links
* **Optional API-key services**: Flickr and Immich (**experimental**), Pexels, Pixabay, Unsplash
* **Filters**: minimum width, minimum pixels, minimum file size, orientation; metadata pre-filter before download and real dimension check after download
* **Interactive start screen and step-by-step wizard**, saved profiles (`-Profile`), silent mode (`-Quiet`) for schedulers and deployment tools
* **Windows JPEG import quality** switch (`-JpegImportQuality Max|Default`) with a one-time pre-check on the start screen
* **Dynamic credits**: support links loaded from `data/universal-windows-wallpaper-changer-credits.txt` on GitHub RAW, with an embedded fallback

### 🛡️ Security

* SHA-256 self-hash verification against GitHub Releases
* One-click update from the SFX package (or PowerShell Gallery) with SHA-256 check; the previous copy is restored if anything fails
* API keys stored encrypted with DPAPI for the current Windows user, never accepted on the command line, masked in logs; environment variables override stored keys

### Notes

* The FirstEverTech photos are published in the separate release tagged `wallpapers` together with `wallpapers.json`. That release is not a version release.

---

# Release Links

* [v2026.11.0001](https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/releases/tag/v2026.11.0001)
