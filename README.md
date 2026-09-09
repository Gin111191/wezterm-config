# wezterm-config

A [WezTerm](https://wezterm.org) config for **macOS and Windows**. One `wezterm.lua`, deliberately short — WezTerm's
defaults are already sensible, and every line here exists because the default was wrong for how I actually work:
long Claude Code sessions, Vietnamese text, and colours that can be changed while the terminal is running.

```
 ~/…/config/wezterm  ·  Dusk-Navy  ·  ⚡ 87%  ·  14:32
 └────────────────┘    └────────┘    └────┘    └───┘
  current folder        scheme       battery   clock
```

---

## What it does

- **The scheme is declared in `theme.lua`** — edit it by hand, and saving changes every open window at once (WezTerm watches the file)
- **Light/dark follows the operating system** — each side remembers its own scheme
- **The background gradient is derived from the running scheme** — pick a blue scheme and the gradient is blue, nothing hard-coded
- **The titlebar takes the scheme's colour** — no more mismatched grey macOS strip on top
- **ANSI slot 8 is lifted on its own** so an agent's secondary rows (tool output, line numbers, comments) stay readable
- **JetBrains Mono** — covers Vietnamese diacritics properly, with no silent glyph substitution
- **100,000 lines of scrollback** — one Claude Code task prints more than the 3,500-line default
- `colortest.sh` shows the current scheme's 16 ANSI colours, text attributes, Vietnamese diacritics and Nerd Font icons

---

## Changing colours

Edit `theme.lua`:

```lua
return { dark = "Dusk-Navy", light = "Everforest Light Medium (Gogh)", gradient = true }
```

Scheme names come from [WezTerm's built-in list](https://wezterm.org/colorschemes/index.html) (~1100 of them),
or add your own palette to `CUSTOM_SCHEMES` in `wezterm.lua`, the way `Dusk-Navy` is added.

Saving the file is all it takes — WezTerm watches `theme.lua`, so every open window follows immediately.
The Neovim config at [Gin111191/nvim-config](https://github.com/Gin111191/nvim-config) reads this same file.

## Platforms

One `wezterm.lua` runs on both. The differences go through 3 variables at the top of the file (`IS_MAC`, `IS_WIN`, `SUPER`):

| | macOS | Windows |
|---|---|---|
| Toggle the gradient | `CMD+OPT+↓` | `CTRL+SHIFT+ALT+↓` |
| Toggle transparency | `CMD+OPT+↑` | `CTRL+SHIFT+ALT+↑` |
| Titlebar UI font | SF Pro Text | Segoe UI |
| Background blur | `macos_window_background_blur` | (macOS only) |
| Default shell | the system default | opens straight into `WSL:Ubuntu` |
| Rendering | the default | `WebGpu`, 144 fps |

Light/dark follows the system on both platforms.

## Install

```sh
git clone https://github.com/Gin111191/wezterm-config ~/.config/wezterm
```

If `~/.config/wezterm` already exists, back it up first:

```sh
mv ~/.config/wezterm ~/.config/wezterm.bak.$(date +%s)
git clone https://github.com/Gin111191/wezterm-config ~/.config/wezterm
```

WezTerm watches the config file and reloads it on save — **no restart needed**.

---

## Keys

| What it does | macOS | Windows |
|---|---|---|
| Toggle transparency, when you need maximum contrast | `CMD+OPT+↑` | `CTRL+SHIFT+ALT+↑` |
| Toggle the background gradient | `CMD+OPT+↓` | `CTRL+SHIFT+ALT+↓` |

Only these two, and both are modifier+arrow on purpose: an arrow produces no character, so a binding that
fails to match cannot leak a stray letter into whatever is running in the pane. Colours are changed by editing
`theme.lua`; there is no key for that.

---

## Layout

| File | Role |
|---|---|
| `wezterm.lua` | The whole config |
| `theme.lua` | The chosen light/dark scheme + the gradient flag. Edit by hand, saving applies it at once |
| `colortest.sh` | Colour + text-attribute test for the running scheme |

`theme.lua` is kept separate so the scheme can change without touching `wezterm.lua`. WezTerm watches that
file, so one write triggers a reload in **every** window.

---

## The default schemes

**Dark: `Dusk-Navy`** — a hand-written scheme, ported from a Terminal.app profile. The sixteen ANSI colours,
the foreground, the cursor and the selection keep the original profile's own sRGB values.

Two things are deliberately **not** taken from the profile: its background was `#000B10` (all but black), and
this one keeps `#1d2837`; and the profile's own transparency (0.70 alpha) is ignored in favour of the
opacity/blur/gradient set in the config.

| | |
|---|---|
| Background | `#1d2837` |
| Text | `#EDEEF7` |
| Cursor | `#A9AFC6` |
| Selection | `#3D4A6B` |

**Light: `Everforest Light Medium (Gogh)`** — built in.

Change either by editing `theme.lua` — saving the file changes every open window at once.

---

## Note: an agent's dim text

Every agent running in a terminal paints its secondary rows — tool summaries, line numbers, `+59 lines`,
comments — in ANSI slot 8, "bright black". Most schemes park that slot a few percent away from the background:
pretty in a screenshot, unreadable in real use. This config lifts **only** slot 8; the other fifteen colours
stay exactly as the scheme's author chose them.

`foreground_text_hsb` does **not** solve this. It was tried (brightness 1.35, then 2.0), the config genuinely
did reload — proved with a font-size probe — and the dim rows did not move at all. Lifting the palette slot is
what works.

And it only works while the agent's own theme is an ANSI variant — for instance `"theme": "dark-ansi"` in
`~/.claude/settings.json`. The truecolor themes bypass this palette entirely.

---

## Nerd Font

**Do you have to install one: no.** WezTerm ships `Symbols Nerd Font Mono` and uses it as the last fallback by
itself, so the starship/eza/lf icons still show up even if you have installed no font at all.
This is where it differs from Terminal.app, iTerm2 or Windows Terminal — on those, a missing Nerd Font means a
prompt full of empty boxes.

To see the real font chain WezTerm is using:

```sh
wezterm ls-fonts
```

If `JetBrainsMono Nerd Font` is not installed, that command opens with a warning — **not an error**,
just a note that it is falling back:

```
Unable to load a font specified by your font=wezterm.font('JetBrainsMono Nerd Font', ...)
configuration. Fallback(s) are being used instead
```

and the chain falls back to: `JetBrains Mono` (shipped with WezTerm) → `Menlo` → `Noto Color Emoji` →
`Symbols Nerd Font Mono` (also shipped). Both text and icons show up; the icons just come from a separate
symbols font rather than the same font as the text.

**Why install it anyway.** With one font handling both text and icons, glyph widths are more even and the icons
do not sit off the baseline next to the text. Nothing needs changing after installing —
`JetBrainsMono Nerd Font` is already first in the fallback list in `wezterm.lua`.

**macOS**

```sh
brew install --cask font-jetbrains-mono-nerd-font
```

**Linux**

```sh
mkdir -p ~/.local/share/fonts
curl -fLo /tmp/JetBrainsMono.zip \
  https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono
fc-cache -f
fc-list | grep -i "JetBrainsMono Nerd Font" | head -3   # any output means it worked
```

**Windows (and WSL)**

Download `JetBrainsMono.zip` from [nerdfonts.com](https://www.nerdfonts.com/font-downloads), unzip it,
select all the `.ttf` files → right click → **Install for all users**.

On WSL the font has to be installed on the **Windows** side, not the Linux side: Windows is what draws the
text, Linux only sends the characters across.

Once installed, reopen WezTerm and run `wezterm ls-fonts` — the warning is gone and
`JetBrainsMono Nerd Font` is at the head of the chain. No edit to `wezterm.lua` is needed.

For a different font, change the name in `config.font_with_fallback` in `wezterm.lua`; keep
`JetBrains Mono` in second place, because it is always present and covers Vietnamese diacritics fully.

---

## Note: an app on a light theme over a dark background

The symptom: you open a tool that runs in the terminal (Claude Code, any TUI), and the text and the background
sink into each other, almost unreadable — while the ordinary shell is still perfectly clear.

The cause is not WezTerm. The default `Dusk-Navy` scheme has a dark background, `#1d2837`. If that app is set
to a **light** theme, it paints dark text because it believes it is sitting on white. Dark text on a dark
background disappears.

For Claude Code, check and fix it with:

```sh
grep '"theme"' ~/.claude/settings.json     # "light" on a dark background is wrong
defaults read -g AppleInterfaceStyle       # "Dark" = macOS is in dark mode
```

The quickest fix is to type `/config` in Claude Code and pick a dark theme, without touching any file.

**The remaining trap:** `wezterm.lua` changes scheme automatically with the operating system's appearance (the
`scheme_for` function), while Claude Code's theme is **fixed**. Flip macOS to Light mode and WezTerm switches to
`Everforest Light Medium` while Claude Code stays dark — sinking the other way round.
When you switch the OS between light and dark, remember to switch the other side too.

This is a different problem from *an agent's dim text* above: there, **all** of the interface is still readable
and only the secondary rows painted in ANSI slot 8 are dim.

---

## Requirements

- macOS (the config uses `macos_window_background_blur` and the system appearance)
- WezTerm — JetBrains Mono is bundled inside it, nothing extra to install
- A Nerd Font is optional — WezTerm ships `Symbols Nerd Font Mono`. See the *Nerd Font* section
