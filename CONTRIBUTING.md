# Contributing to Universal Windows Wallpaper Changer

First off, thank you for considering contributing to Universal Windows Wallpaper Changer! It's people like you that make this tool better for everyone.

Following these guidelines helps to communicate that you respect the time of the developers managing and developing this open source project. In return, they should reciprocate that respect in addressing your issue, assessing changes, and helping you finalize your pull requests.

---

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [What We're Looking For](#what-were-looking-for)
3. [How to Contribute](#how-to-contribute)
4. [Reporting Bugs](#reporting-bugs)
5. [Suggesting Enhancements](#suggesting-enhancements)
6. [Your First Code Contribution](#your-first-code-contribution)
7. [Pull Request Process](#pull-request-process)
8. [Style Guidelines](#style-guidelines)
9. [Community](#community)

---

## Code of Conduct

This project and everyone participating in it is expected to follow basic principles of respect and constructive collaboration:

- **Be respectful**: Treat all contributors with respect and dignity
- **Be constructive**: Provide helpful feedback and suggestions
- **Be patient**: Remember that contributors may be working on this in their free time
- **Be inclusive**: Welcome contributors of all skill levels and backgrounds

---

## What We're Looking For

We love contributions from the community! Here are some ways you can help:

### High Priority Areas
- 🐛 **Bug reports and fixes** - Help us identify and resolve issues
- 🔒 **Security improvements** - Enhanced verification or safer handling of API keys
- 📚 **Documentation** - Improvements to README, guides, or code comments
- 🌍 **Translations** - Better documentation in other languages
- 🧪 **Testing** - Testing on various Windows versions, and verification of the **experimental** Flickr and Immich sources against live accounts/servers

### Medium Priority Areas
- ✨ **Feature enhancements** - Improvements to existing functionality
- 🔧 **Code optimization** - Performance improvements and refactoring
- 🖼️ **Image sources** - Additional free image sources (see the note on licenses below)
- 🎨 **User experience** - Wizard, tray menu and console screen improvements

### Ideas We're Open To
- Additional free image sources that need no API key
- Enhanced logging and diagnostic capabilities
- Better handling of multi-monitor setups
- Automated testing frameworks

**Note on image sources:** this tool does not host or redistribute third-party images. A new source must have a free API or a public listing that allows personal use, and the license/terms of the source should be stated in the pull request.

---

## How to Contribute

### Quick Start

1. **Fork** the repository
2. **Clone** your fork: `git clone https://github.com/YOUR-USERNAME/Universal-Windows-Wallpaper-Changer.git`
3. **Create** a branch: `git checkout -b feature/your-feature-name`
4. **Make** your changes
5. **Test** thoroughly
6. **Commit** with clear messages: `git commit -m "Add feature: description"`
7. **Push** to your fork: `git push origin feature/your-feature-name`
8. **Open** a Pull Request

---

## Reporting Bugs

### Before Submitting a Bug Report

1. **Check the [Known Issues](https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/blob/main/KNOWN_ISSUES.md)** - Your issue might already be documented
2. **Search existing issues** - Someone may have already reported it
3. **Update to the latest version** - The bug might already be fixed
4. **Enable debug mode** - Run the script with `-Debug` for detailed diagnostic messages

### How to Submit a Good Bug Report

Use the **Bug Report** issue template and include:

**Required Information:**
- **System Information**:
  - Windows version (e.g., Windows 11 23H2) and build number
  - PowerShell version: Run `$PSVersionTable.PSVersion`
- **Script Version**: Run `.\universal-windows-wallpaper-changer.ps1 -Version` (e.g., v2026.11.0001)
- **Image Source and options**: e.g. `-Source Wallhaven -Query "forest"`, one-time or background mode
- **Expected Behavior**: What you expected to happen
- **Actual Behavior**: What actually happened
- **Steps to Reproduce**: Detailed steps to recreate the issue
- **Log Files**: Attach or paste relevant sections from `%LOCALAPPDATA%\UniversalWindowsWallpaperChanger\wallpaper.log`
- **Screenshots**: If applicable, especially for UI issues

**Never post API keys.** Keys are masked in the log, but check the text before you paste it.

**Example Bug Report:**
```markdown
**System**: Windows 11 23H2, PowerShell 5.1
**Version**: v2026.11.0001
**Command**: .\universal-windows-wallpaper-changer.ps1 -Source Wallhaven -Query "forest" -Once
**Issue**: Wallpaper is not changed, all attempts rejected

**Steps to Reproduce**:
1. Run the command above
2. Wait for the filter phase to finish
3. The tool reports that no image passed the filters

**Log Output**:
[paste relevant log section here]

**Expected**: One wallpaper is downloaded and applied
**Actual**: Error message displayed and the wallpaper stays the same
```

---

## Suggesting Enhancements

### Before Submitting an Enhancement

1. **Check if it's already implemented** in the latest version
2. **Search existing feature requests** in issues
3. **Consider the scope** - Does it align with the project's goals?

### How to Submit a Good Enhancement Request

Open an issue and include:

- **Clear Title**: Concise description of the enhancement
- **Problem Statement**: What problem does this solve?
- **Proposed Solution**: How would you implement it?
- **Alternatives Considered**: Other approaches you've thought about
- **Use Cases**: Real-world scenarios where this would be useful
- **Impact**: Who would benefit from this?

**Example Feature Request:**
```markdown
**Title**: Add a source for a local RSS feed of images

**Problem**: Users who publish their own photo feed cannot use it as a source

**Proposed Solution**:
Add a `-Source Feed -Url <link>` option that reads image links from an RSS/Atom feed

**Use Cases**:
- Users who run their own photo blog
- IT administrators publishing company wallpapers

**Benefits**: More flexible sources without an API key
```

---

## Your First Code Contribution

Unsure where to begin? Look for issues labeled:

- `good first issue` - Simple issues perfect for newcomers
- `help wanted` - Issues where we'd especially appreciate help
- `documentation` - Great for non-coding contributions

### Setting Up Your Development Environment

1. **Install Prerequisites**:
   - Windows 10/11 with Windows PowerShell 5.1
   - Git for version control
   - A code editor (VS Code recommended with PowerShell extension)

2. **Fork and Clone**:
   ```bash
   git clone https://github.com/YOUR-USERNAME/Universal-Windows-Wallpaper-Changer.git
   cd Universal-Windows-Wallpaper-Changer
   ```

3. **Create a Test Branch**:
   ```bash
   git checkout -b test/your-test-name
   ```

4. **Test Your Changes**:
   - Run the script from `src\` with `-Debug` and `-NoUpdate` (and `-SkipVerify` while the file differs from the published hash)
   - Test on your own system first
   - Check for any error messages or warnings

---

## Pull Request Process

### Before Submitting

- ✅ **Test thoroughly** on your system
- ✅ **Follow style guidelines** (see below)
- ✅ **Update documentation** if adding/changing features
- ✅ **Add comments** for complex logic
- ✅ **Check for typos** and formatting consistency

### Pull Request Checklist

1. **Clear Title**: Descriptive PR title (e.g., "Fix: Handle empty query for the Picsum source")
2. **Description**: Explain what changes you made and why
3. **Link Issues**: Reference related issues (e.g., "Fixes #123")
4. **Test Results**: Describe how you tested your changes
5. **Screenshots**: Include if relevant (especially for UI changes)

### PR Template Example

```markdown
## Description
Brief description of what this PR does

## Related Issues
Fixes #123, Relates to #456

## Changes Made
- Added feature X
- Fixed bug Y
- Updated documentation Z

## Testing Performed
- Tested on Windows 11 23H2, PowerShell 5.1
- Verified with the Wallhaven and Folder sources
- Confirmed the wallpaper is applied and the old files are cleaned up

## Screenshots (if applicable)
[Paste screenshots here]

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] Tested on my system
- [ ] No new warnings or errors
```

### Review Process

1. **Automated Checks**: (When CI/CD is implemented) Your PR must pass all checks
2. **Code Review**: Maintainers will review your code
3. **Feedback**: Address any requested changes
4. **Approval**: Once approved, your PR will be merged
5. **Credit**: You'll be credited in the release notes!

---

## Style Guidelines

### PowerShell Code Style

#### General Principles
- **Clarity over cleverness**: Readable code is maintainable code
- **Consistent formatting**: Follow existing code patterns
- **Meaningful names**: Use descriptive variable and function names
- **Error handling**: Always include proper error checking
- **Compatibility**: The script must run on Windows PowerShell 5.1 (no PowerShell 7-only syntax)
- **Secrets**: Never log, print or accept API keys on the command line

#### Naming Conventions
```powershell
# Variables: PascalCase
$DownloadUrl = "https://example.com"
$ImageCount = 5

# Script-scope variables: $script: prefix
$script:LogFile = Join-Path $script:LocalRoot 'wallpaper.log'

# Functions: Verb-Noun format, PascalCase
function Get-JpegImportQuality { }
function Test-ImageFile { }
```

#### Code Formatting
```powershell
# Use 4-space indentation (no tabs)
if ($condition) {
    Write-Host "Message"
    # Nested code
    foreach ($item in $collection) {
        Process-Item $item
    }
}

# Line length: Keep under 120 characters when possible
# Break long lines logically
$result = Invoke-WebRequest `
    -Uri $url `
    -Method Get `
    -Headers $headers

# Space around operators
$sum = $a + $b
$isValid = ($value -eq $expected)
```

#### Comments
```powershell
# Single-line comments for brief explanations
$retryCount = 3  # Maximum retry attempts

# Multi-line comments for complex logic
<#
    This function checks the real size of a downloaded image
    and rejects it if it does not pass the configured filters.
    Returns $true if the image is accepted, $false otherwise.
#>
function Test-ImageFile {
    # Implementation
}

# TODO comments for future improvements
# TODO: Add support for multi-monitor setups
```

#### Error Handling
```powershell
# Always use try-catch for operations that can fail
try {
    $result = Invoke-WebRequest -Uri $url
    # Process result
}
catch {
    Write-Host "Error: Failed to download file - $_" -ForegroundColor Red
    # Fallback logic or cleanup
}

# Validate inputs
if (-not $filePath) {
    Write-Error "File path is required"
    return
}
```

### Documentation Style

#### README and Markdown Files
- Use clear, concise language
- Break up text with headers and lists
- Include examples for complex concepts
- Keep line length reasonable (80-100 characters in paragraphs)
- Use proper Markdown formatting

#### Code Comments
- Explain **why**, not **what** (code shows what)
- Update comments when code changes
- Use clear, professional language
- Avoid redundant comments

**Good:**
```powershell
# Retry with the next image if the real size is below the minimum width
$photo = $queue[0]
```

**Bad:**
```powershell
# Set photo to the first item
$photo = $queue[0]
```

---

## Community

### Getting Help

- 💬 **GitHub Issues**: Best place for bugs and feature requests
- 📖 **Documentation**: Check README and KNOWN_ISSUES first
- 🔍 **Search**: Look for existing discussions before posting

### Project Resources

- [Project Website](https://www.firstever.tech)
- [GitHub Repository](https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer)
- [Security Policy](https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/blob/main/SECURITY.md)
- [Latest Release](https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/releases/latest)

### Recognition

Contributors will be:
- Listed in release notes
- Credited in the project README (for significant contributions)
- Appreciated by the entire community! 🎉

---

## Questions?

Don't hesitate to ask questions! You can:
1. Open an issue with the `question` label
2. Check if your question is already answered in existing issues
3. Reach out via the contact information in the README

---

## License

By contributing to Universal Windows Wallpaper Changer, you agree that your contributions will be licensed under the MIT License.

The FirstEverTech photos are **not** covered by the MIT License. They are the work of Marcin Grygiel, all rights reserved, and are published separately in the [`wallpapers` release](https://github.com/FirstEverTech/Universal-Windows-Wallpaper-Changer/releases/tag/wallpapers). Please do not submit photos to this repository.

---

**Thank you for contributing! Your efforts make this project better for everyone.** 🚀

---

*This contributing guide is inspired by open source best practices and adapted for this project's specific needs.*
