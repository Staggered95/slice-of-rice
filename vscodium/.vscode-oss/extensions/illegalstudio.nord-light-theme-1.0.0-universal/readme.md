# Nord Light Theme for Visual Studio Code

A light theme for Visual Studio Code and compatible editors (Cursor, VSCodium, etc.) based on the [Nord](https://www.nordtheme.com/) color palette, adapted for light backgrounds.

## Project Structure

```
nord-light-vscode/
├── themes/
│   └── nord-light-color-theme.json   # Theme colors and syntax highlighting
├── outputs/                          # Build output directory
├── package.json                      # Extension manifest
├── build.sh                          # Build script
├── LICENSE
└── README.md
```

## Build

### Requirements

- Node.js (v16 or higher)
- npm
- vsce (Visual Studio Code Extension Manager)

### Install vsce

```bash
npm install -g @vscode/vsce
```

For more info: https://github.com/microsoft/vscode-vsce

### Build Command

```bash
./build.sh
```

This generates `outputs/nord-light-theme-<version>.vsix`.

## Installation

### From VSIX file

1. Open Visual Studio Code / Cursor
2. Open Command Palette (`Cmd+Shift+P` / `Ctrl+Shift+P`)
3. Run "Extensions: Install from VSIX..."
4. Select the `.vsix` file from the `outputs/` folder
5. Reload the editor

### From source (development)

```bash
# Create a symlink in the extensions folder
# For Visual Studio Code:
ln -s /path/to/nord-light-vscode ~/.vscode/extensions/nord-light-theme

# For Cursor:
ln -s /path/to/nord-light-vscode ~/.cursor/extensions/nord-light-theme
```

Then reload the editor.

### Activate the theme

1. Open Command Palette (`Cmd+Shift+P` / `Ctrl+Shift+P`)
2. Run "Preferences: Color Theme"
3. Select "Nord Light"

## Color Palette

### Base Colors (Nord Snow Storm)

These colors are used for backgrounds and UI elements:

| Name | Hex | Usage |
|------|-----|-------|
| Nord 4 | `#D8DEE9` | Selection, borders, secondary backgrounds |
| Nord 5 | `#E5E9F0` | Sidebar, toolbar, inactive backgrounds |
| Nord 6 | `#ECEFF4` | Main editor background |

### Text Colors (Nord Polar Night)

| Name | Hex | Usage |
|------|-----|-------|
| Nord 0 | `#2E3440` | Main text, identifiers |
| Nord 1 | `#3B4252` | Secondary text |
| Nord 2 | `#434C5E` | Tertiary text |
| Nord 3 | `#4C566A` | Comments base, punctuation |

### Accent Colors Comparison

The original Nord accent colors are designed for dark backgrounds. For the light theme, we darkened them significantly to ensure proper contrast and readability.

| Element | Original Nord | Nord Light | Description |
|---------|---------------|------------|-------------|
| Classes/Types | `#8FBCBB` (nord7) | `#1D7A79` | Teal - class names, type references |
| Functions | `#88C0D0` (nord8) | `#0D7D8C` | Cyan - function declarations and calls |
| Tags | `#81A1C1` (nord9) | `#4B6C8C` | Light blue - HTML/XML tags, operators |
| Keywords | `#5E81AC` (nord10) | `#3B5E85` | Blue - language keywords |
| Strings | `#A3BE8C` (nord14) | `#6B8B4F` | Green - string literals |
| Numbers | `#B48EAD` (nord15) | `#8B5E84` | Purple - numeric literals |
| Constants | `#EBCB8B` (nord13) | `#B8941E` | Yellow - constants, enums |
| Fields | `#D08770` (nord12) | `#A5614A` | Orange - instance/static fields |
| Errors | `#BF616A` (nord11) | `#BF616A` | Red - errors (unchanged) |

### Color Rationale

- **Darkening factor:** ~25-40% darker than original Nord colors
- **Saturation:** Maintained or slightly increased for vibrancy
- **Contrast ratio:** All colors meet WCAG AA standards against `#ECEFF4` background

## Supported Languages

The theme includes syntax highlighting for:

- JavaScript / TypeScript / JSX / TSX
- HTML / XML
- CSS / SCSS / SASS / Less
- JSON / YAML / TOML
- Markdown
- PHP
- Python
- Go
- Rust
- SQL
- And more...

## Credits

- Based on [Nord Theme](https://www.nordtheme.com/) by [Sven Greb](https://github.com/svengreb)
- JetBrains version: [nord-light/jetbrains](https://github.com/nord-light/jetbrains)

## License

MIT License

## Author

Created by [Vincenzo Petrucci](https://nahi.me/) ([@nahime0](https://github.com/nahime0)) as part of [Illegal Studio](https://illegal.studio/).
