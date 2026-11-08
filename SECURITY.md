# Security Policy

## Reporting Vulnerabilities

If you discover a security vulnerability in this project, please report it privately:
- Email: contact@firstever.tech
- Do NOT create public GitHub issues for security vulnerabilities

## Security Measures

- The script verifies its own SHA-256 hash against the hash published in GitHub Releases
- Updates (SFX package or `.ps1` asset) are verified by SHA-256 before they are installed
- API keys are stored encrypted with DPAPI for the current Windows user, are never accepted on the command line and are masked in logs
- No administrator rights are required: everything runs per user (HKCU, `%LOCALAPPDATA%`, `%APPDATA%`)
- Extensive logging for audit purposes (`%LOCALAPPDATA%\UniversalWindowsWallpaperChanger\wallpaper.log`)

## Supported Versions

Only the latest version receives security updates.
