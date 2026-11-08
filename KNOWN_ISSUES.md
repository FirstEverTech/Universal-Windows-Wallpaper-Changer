<a id="top"></a>
# 🐛 Known Issues & Solutions

This document contains reported issues, limitations, and their corresponding solutions for the Universal Windows Wallpaper Changer. The list is maintained by the community and updated regularly.

## 📑 Quick Navigation

- [Issue #1: PowerShell Execution Policy Restriction](#issue-1-powershell-execution-policy-restriction)
- [Issue #2: JPG Wallpapers Look Worse Than PNG (Windows JPEG Import Quality)](#issue-2-jpg-wallpapers-look-worse-than-png)
- [Issue #3: Bing Images Are Copyrighted](#issue-3-bing-images-are-copyrighted)
- [Issue #4: Source-Specific Limits (Pixabay, Unsplash, Pexels)](#issue-4-source-specific-limits)
- [Issue #5: Flickr and Immich Support Is Experimental](#issue-5-flickr-and-immich-support-is-experimental)
- [Issue #6: Windows 10 LTSB 2015/2016 Cannot Connect (TLS 1.2)](#issue-6-windows-10-ltsb-20152016-cannot-connect-tls-12)
- [Issue #7: Background Mode Is Per User; No Effect on Server Core](#issue-7-background-mode-is-per-user-no-effect-on-server-core)
- [Issue #8: "Not Trusted" Certificate and Antivirus Detections for the SFX Package](#issue-8-not-trusted-certificate-and-antivirus-detections-for-the-sfx-package)

---

<a id="issue-1-powershell-execution-policy-restriction"></a>
## Issue #1: PowerShell Execution Policy Restriction

**Affected Systems**: All Windows systems with default PowerShell settings

**Symptoms**:
- The SFX EXE or the PS1 script fails to run with PowerShell execution policy errors
- Script terminates immediately without user interaction
- Error message:
  ```
  File ... cannot be loaded because running scripts is disabled on this system
  ```

**Cause**:
Windows PowerShell blocks script execution by default for security reasons. Scripts downloaded from the internet also carry a "blocked" mark (Mark of the Web) that some policies refuse to run.

**Solution**:

### For SFX EXE Users

#### ✅ Permanent Fix (Recommended)
1. Open **Windows PowerShell** (administrator rights are **not** needed)
2. Run the command:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. Type **Y** to confirm
4. Run the `WindowsWallpaperChanger-<version>-Win10-Win11.exe` normally

#### ⚠️ Temporary Fix (One-Time Bypass)
1. Open Command Prompt
2. Navigate to your EXE location
3. Run:
   ```cmd
   PowerShell -ExecutionPolicy Bypass -Command "& {Start-Process -FilePath 'WindowsWallpaperChanger-<version>-Win10-Win11.exe'}"
   ```

---

### For PS1 Users (Direct PowerShell Script)

#### Permanent Fix:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Unblock-File -Path ".\universal-windows-wallpaper-changer.ps1"
```
Type **Y** to confirm.
Now you can run the PS1 script normally.

#### Temporary Fix:
```powershell
powershell -ExecutionPolicy Bypass -File ".\universal-windows-wallpaper-changer.ps1"
```

---

### Security Notes
- Permanent fix affects only the current user and is safe for trusted scripts
- Temporary bypass is safest for one-time use
- Revert execution policy anytime with:
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope CurrentUser
  ```

[↑ Back to top](#top)

---

<a id="issue-2-jpg-wallpapers-look-worse-than-png"></a>
## Issue #2: JPG Wallpapers Look Worse Than PNG

**Affected Systems**: Windows 11 (measured on build 29704.100; other builds were not tested)

**Symptoms**:
- A JPG wallpaper looks softer or shows compression artifacts on the desktop, while the same picture as PNG looks fine
- The FirstEverTech photos (published as JPG, quality 100%) look worse on the desktop than the file itself

**Cause**:
When a wallpaper is set, Windows stores its own copy as `%APPDATA%\Microsoft\Windows\Themes\TranscodedWallpaper`. Unless the registry value `HKCU\Control Panel\Desktop\JPEGImportQuality` is set to 100, Windows recompresses JPG wallpapers with loss. PNG wallpapers are not changed.

Measured (4K images, same resolution of the Windows copy as the source in all tests):

| Source | `JPEGImportQuality` | Size of Windows copy |
|--------|---------------------|---------------------:|
| PNG, 15.0 MB | not set | 15.33 MB |
| PNG, 15.0 MB | 100 | 15.33 MB |
| JPG, 6.74 MB | not set | 2.14 MB |
| JPG, 6.74 MB | 100 | 7.18 MB |

The quality value Windows uses when the setting is not present was not measured. The tool assumes 85%.

**Solution**:
1. Set the Windows JPEG import quality to 100%:
   ```powershell
   .\universal-windows-wallpaper-changer.ps1 -JpegImportQuality Max
   ```
2. Sign out and back in (or restart Windows)
3. Set the wallpaper again

The change is per user (HKCU) and needs no administrator rights. Restore the Windows default with `-JpegImportQuality Default`. The interactive start screen offers this once as a pre-check; use `-NoPrompt` to hide the question. See also the [README](README.md#jpeg-import-quality).

[↑ Back to top](#top)

---

<a id="issue-3-bing-images-are-copyrighted"></a>
## Issue #3: Bing Images Are Copyrighted

**Symptoms**:
- Concern about using Bing images outside of your own desktop

**Cause**:
Bing images are copyrighted and meant for personal use. The tool does not claim ownership or redistribute images.

**Solution**:
For commercial use, stick to Picsum, your own folders, or sources with explicit licenses. Always respect the license of every image you keep.

[↑ Back to top](#top)

---

<a id="issue-4-source-specific-limits"></a>
## Issue #4: Source-Specific Limits (Pixabay, Unsplash, Pexels)

**Symptoms and limits**:
- **Pixabay**: the free API delivers at most **1280 px** regardless of `-MinWidth`, so images below the 4K default are rejected unless you lower `-MinWidth`
- **Unsplash**: **50 requests per hour**. Intervals under 5 minutes in background mode can hit the limit (the tool warns about this)
- **Pexels**: **new API keys are currently paused**. Existing keys keep working

**Solution**:
- For 4K wallpapers without a key, use FirstEverTech, Bing, Picsum or Wallhaven
- Use a longer `-IntervalMinutes` with Unsplash
- Lower `-MinWidth` only if you accept lower resolution

[↑ Back to top](#top)

---

<a id="issue-5-flickr-and-immich-support-is-experimental"></a>
## Issue #5: Flickr and Immich Support Is Experimental

**Symptoms**:
- Errors or no images returned from Flickr (Pro API key) or from your own Immich server

**Cause**:
Flickr and Immich support is **experimental**. It has not been verified against a live account or server.

**Solution**:
1. Run with `-Debug` and check `%LOCALAPPDATA%\UniversalWindowsWallpaperChanger\wallpaper.log`
2. For Immich, set the server address with `-ImmichUrl <url>` and the key with `-SetKey Immich`
3. Open an issue with the log (without any API keys) so the support can be improved

[↑ Back to top](#top)

---

<a id="issue-6-windows-10-ltsb-20152016-cannot-connect-tls-12"></a>
## Issue #6: Windows 10 LTSB 2015/2016 Cannot Connect (TLS 1.2)

**Affected Systems**: Windows 10 LTSB 2015 (1507) and LTSB 2016 (1607)

**Symptoms**:
- Online sources, hash verification and update checks fail with connection errors

**Cause**:
These systems may lack TLS 1.2 / SHA-2 support out-of-the-box.

**Solution**:
1. Install [.NET Framework 4.8](https://go.microsoft.com/fwlink/?linkid=2088631)
2. Install [KB4474419](https://catalog.update.microsoft.com/Search.aspx?q=KB4474419) (SHA-2 update)
3. Local sources (`Photos`, `Folder`) work even without internet connectivity

[↑ Back to top](#top)

---

<a id="issue-7-background-mode-is-per-user-no-effect-on-server-core"></a>
## Issue #7: Background Mode Is Per User; No Effect on Server Core

**Symptoms**:
- Background changer does not run for other Windows accounts
- On Server Core (no desktop) the wallpaper change has no visible effect

**Cause**:
Wallpaper changing is per user. Background mode starts at sign-in through `HKCU\Software\Microsoft\Windows\CurrentVersion\Run` and runs for the current user only.

**Solution**:
Run `-Background Start` (or the wizard) in each user account that should use it. Check the state with `-Background Status`, and remove the start at sign-in with `-Background Stop`.

[↑ Back to top](#top)

---

<a id="issue-8-not-trusted-certificate-and-antivirus-detections-for-the-sfx-package"></a>
## Issue #8: "Not Trusted" Certificate and Antivirus Detections for the SFX Package

**Symptoms**:
- Windows shows the FirstEver.tech certificate as "not trusted"
- The SFX executable may show a small number of antivirus detections (e.g. on VirusTotal)

**Cause**:
The FirstEver.tech certificate is self-signed. SFX + PowerShell combinations are a known source of false positives.

**Solution**:
The PowerShell script (`universal-windows-wallpaper-changer.ps1`) is the authoritative source of the tool. Its SHA-256 hash is published on GitHub and verified automatically on every run. Always verify the hashes published in the Release. The SFX executable is a convenience wrapper that installs the same PS1.

[↑ Back to top](#top)

---

## 🔍 Reporting New Issues

If you encounter a new issue not listed here, please:

- Check if the issue is already listed in this document
- Open a new GitHub Issue with detailed description
- Include your system specifications and exact error messages
- Attach the relevant part of `%LOCALAPPDATA%\UniversalWindowsWallpaperChanger\wallpaper.log` (without API keys)
- Share any workarounds or solutions you've discovered

---

Last Updated: 08/11/2026
