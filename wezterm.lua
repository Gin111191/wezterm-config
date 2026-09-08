-- WezTerm — Gin's terminal window.
--
-- Deliberately small. WezTerm's defaults are already sane; every line here exists because the
-- default was wrong for how Gin actually works (long Claude Code sessions, Vietnamese text, and
-- images that should show up without opening Preview).
--
-- Reload: WezTerm watches this file and applies changes on save. No restart needed.
--
-- Keys added here:
--   CMD+OPT+↑ (CTRL+SHIFT+ALT+↑)   toggle window transparency off/on when a screen needs full contrast
--   CMD+OPT+↓ (CTRL+SHIFT+ALT+↓)   toggle the background gradient
--
-- The runtime keys are all modifier+arrow on purpose: arrows produce no character, so a binding
-- that fails to match cannot leak a stray letter into whatever is running in the pane.
--
-- Đổi màu: sửa thẳng theme.lua (dark = "...", light = "..."). WezTerm theo dõi file đó nên
-- lưu là mọi cửa sổ đang mở đổi theo ngay, không cần khởi động lại.

local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- ── Nền tảng ──────────────────────────────────────────────────────────────────
-- Config này chạy trên cả macOS và Windows. Mọi khác biệt giữa hai bên đều đi qua
-- ba biến dưới đây, không rải rác trong file.
--   IS_MAC  : blur nền, phím CMD, font giao diện SF Pro Text
--   IS_WIN  : mở thẳng vào WSL, render bằng WebGpu, font giao diện Segoe UI
--   SUPER_ALT : phím bổ trợ cho 2 phím tắt còn lại — CMD+OPT (macOS) / CTRL+SHIFT+ALT (Windows)
local IS_MAC = wezterm.target_triple:find("darwin") ~= nil
local IS_WIN = wezterm.target_triple:find("windows") ~= nil
local SUPER_ALT = IS_MAC and "CMD|ALT" or "CTRL|SHIFT|ALT"

-- ── Colours ───────────────────────────────────────────────────────────────────
-- The chosen scheme lives in theme.lua, not here, so it can be changed without touching this
-- file — and so Neovim can read the same file and match. Light and dark are stored separately: macOS switches appearance and the terminal
-- follows, keeping whatever was picked for each side.

local THEME_FILE = wezterm.config_dir .. "/theme.lua"
local FALLBACK = {
  dark = "Everforest Dark Medium (Gogh)",
  light = "Everforest Light Medium (Gogh)",
  gradient = false,
}

-- Ported from ~/Downloads/Dusk-Navy.terminal, a Terminal.app profile: the sixteen ANSI colours,
-- the foreground, the cursor and the selection are that profile's own sRGB values, unchanged.
--
-- Two things are deliberately NOT taken from the profile. Its background was #000B10, all but
-- black; the background here stays #1d2837 — Galaxy's, what this terminal was already sitting on
-- — because that is the part Gin wanted kept. And the profile's own transparency (0.70 alpha, a
-- light blur) is ignored in favour of the opacity, blur and gradient set further down.
local CUSTOM_SCHEMES = {
  ["Dusk-Navy"] = {
    foreground = "#EDEEF7",
    background = "#1d2837",
    cursor_bg = "#A9AFC6",
    cursor_border = "#A9AFC6",
    cursor_fg = "#1d2837",
    selection_bg = "#3D4A6B",
    selection_fg = "#EDEEF7",
    ansi = { "#1A1D26", "#B4637A", "#6E9E8A", "#C9A227", "#5C7CB8", "#8B7BB8", "#6E9AB8", "#A9AFC6" },
    brights = { "#3D4A6B", "#D18A9E", "#8FBFA9", "#E0C05A", "#7D9BD4", "#A99AD4", "#8FBBD4", "#EDEEF7" },
  },
}

local function write_theme(theme)
  local f = io.open(THEME_FILE, "w")
  if not f then
    return
  end
  f:write("-- Scheme đang dùng. Sửa tay thoải mái; WezTerm nạp lại ngay khi lưu.\n")
  f:write(string.format(
    "return { dark = %q, light = %q, gradient = %s }\n",
    theme.dark,
    theme.light,
    tostring(theme.gradient == true)
  ))
  f:close()
end

local function read_theme()
  local chunk = loadfile(THEME_FILE)
  if chunk then
    local ok, saved = pcall(chunk)
    if ok and type(saved) == "table" and saved.dark and saved.light then
      return { dark = saved.dark, light = saved.light, gradient = saved.gradient == true }
    end
  end
  write_theme(FALLBACK) -- first run, or the file got mangled
  return { dark = FALLBACK.dark, light = FALLBACK.light, gradient = FALLBACK.gradient }
end

-- Watching theme.lua is what makes the picker instant in *every* open window, not just the one
-- the key was pressed in: the write triggers a config reload everywhere.
wezterm.add_to_config_reload_watch_list(THEME_FILE)

local theme = read_theme()

local function is_dark(appearance)
  return appearance:find("Dark") ~= nil
end

local function scheme_for(appearance)
  return is_dark(appearance) and theme.dark or theme.light
end

-- A custom scheme is not in the built-in table, so every palette lookup goes through here.
-- Without it the titlebar colour, the gradient and the slot-8 lift below would all silently
-- fall back to nil the moment a hand-written scheme is selected.
local function palette_for(name)
  return CUSTOM_SCHEMES[name] or wezterm.color.get_builtin_schemes()[name]
end

-- The titlebar carries the tab bar, so it should be the same colour as the terminal body rather
-- than macOS grey — otherwise every scheme change leaves a mismatched strip on top.
local function frame_for(scheme_name)
  local palette = palette_for(scheme_name)
  return {
    -- SF Pro Text chỉ có trên macOS; Windows dùng Segoe UI.
    font = wezterm.font({ family = IS_MAC and "SF Pro Text" or "Segoe UI", weight = "Medium" }),
    font_size = 12.0,
    active_titlebar_bg = palette and palette.background,
    inactive_titlebar_bg = palette and palette.background,
    active_titlebar_fg = palette and palette.foreground,
    inactive_titlebar_fg = palette and palette.foreground,
  }
end

-- Derived from whichever scheme is active rather than hard-coded, so the gradient stays in the
-- scheme's own hue: pick a blue scheme and the gradient is blue. Kept shallow (a touch lighter at
-- the top, darker at the bottom) because a wide sweep turns text into work to read.
local function gradient_for(scheme_name)
  local palette = palette_for(scheme_name)
  if not (palette and palette.background) then
    return nil
  end
  local base = wezterm.color.parse(palette.background)
  return {
    orientation = "Vertical",
    colors = {
      tostring(base:lighten(0.05)),
      palette.background,
      tostring(base:darken(0.22)),
    },
    interpolation = "Linear",
    blend = "Rgb",
    noise = 48, -- hides the banding a smooth ramp shows on a dark background
  }
end

local function visuals_for(scheme_name)
  return frame_for(scheme_name), (theme.gradient and gradient_for(scheme_name) or nil)
end

local function toggle_gradient(window)
  local current = read_theme()
  current.gradient = not current.gradient
  write_theme(current)
  theme = current

  local overrides = window:get_config_overrides() or {}
  overrides.window_background_gradient = current.gradient and gradient_for(window:effective_config().color_scheme)
    or nil
  window:set_config_overrides(overrides)
end

-- Every terminal agent paints its secondary rows — tool summaries, line numbers, "+59 lines",
-- comments — in ANSI slot 8, "bright black". Most schemes park that slot a few percent off the
-- background, which is legible in a screenshot and unreadable in practice. Lift slot 8 only;
-- the other fifteen colours stay exactly as the scheme author chose them.
--
-- Note for whoever finds this later: `foreground_text_hsb` does NOT fix that problem. It was tried
-- (brightness 1.35, then 2.0), the config demonstrably reloaded — a font-size probe proved it — and
-- the dim rows did not move at all. Lifting the palette slot is what works, and it only works while
-- the agent's own theme is set to an ANSI variant (`"theme": "dark-ansi"` in ~/.claude/settings.json);
-- the truecolor themes bypass this palette entirely.
local BRIGHT_BLACK = { dark = "#93a1b3", light = "#4f5b66" }

local function colors_for(scheme_name)
  local palette = palette_for(scheme_name)
  if not (palette and palette.brights) then
    return nil
  end
  local brights = {}
  for i = 1, 8 do
    brights[i] = palette.brights[i]
  end
  brights[1] = is_dark(scheme_name == theme.dark and "Dark" or "Light") and BRIGHT_BLACK.dark
    or BRIGHT_BLACK.light
  return { brights = brights }
end

config.color_schemes = CUSTOM_SCHEMES
config.color_scheme = scheme_for(wezterm.gui and wezterm.gui.get_appearance() or "Light")
config.colors = colors_for(config.color_scheme)

wezterm.on("window-config-reloaded", function(window)
  local overrides = window:get_config_overrides() or {}
  local scheme = scheme_for(window:get_appearance())
  local frame, gradient = visuals_for(scheme)
  local gradient_changed = (overrides.window_background_gradient ~= nil) ~= (gradient ~= nil)

  local lifted = colors_for(scheme)
  local palette_changed = (overrides.colors == nil) ~= (lifted == nil)
    or (lifted ~= nil and overrides.colors ~= nil and overrides.colors.brights[1] ~= lifted.brights[1])

  -- The palette lift must be re-applied even when the scheme itself did not change: an override
  -- carrying `color_scheme` replaces the window's whole palette, so a `config.colors` set at file
  -- level never reaches a window that already has overrides. Leaving this inside the scheme-changed
  -- branch is why the first attempt silently did nothing.
  if overrides.color_scheme ~= scheme or gradient_changed or palette_changed then
    overrides.color_scheme = scheme
    overrides.window_frame = frame
    overrides.window_background_gradient = gradient
    overrides.colors = lifted
    window:set_config_overrides(overrides)
  end
end)

-- ── Text ──────────────────────────────────────────────────────────────────────
-- WezTerm bundles JetBrains Mono, which covers Vietnamese diacritics properly. Many coding fonts
-- do not, and a missing glyph is silently substituted — which is how "ế" ends up looking wrong.
-- "JetBrainsMono Nerd Font" (bản cài riêng, có icon) đứng trước; "JetBrains Mono"
-- là bản WezTerm đóng gói sẵn, luôn có mặt; Menlo/Consolas là chốt chặn cuối.
config.font = wezterm.font_with_fallback({
  "JetBrainsMono Nerd Font",
  "JetBrains Mono",
  IS_MAC and "Menlo" or "Consolas",
})
config.font_size = 13.0
config.line_height = 1.1


-- A bar cursor sits between characters instead of covering one, which matters when reviewing
-- Vietnamese text. Constant easing means it blinks crisply rather than fading in and out — the
-- fade is easy to lose against a low-contrast scheme.
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 650
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.force_reverse_video_cursor = true -- keeps the cursor legible in every scheme

-- ── Scrollback ────────────────────────────────────────────────────────────────
-- The default (3,500 lines) is nowhere near enough: one Claude Code task can print more than that,
-- and losing the top of a run means losing the reasoning that explains the result.
config.scrollback_lines = 100000

-- ── Window ────────────────────────────────────────────────────────────────────
config.initial_cols = 140
config.initial_rows = 40
config.window_padding = { left = 12, right = 12, top = 8, bottom = 8 }
config.window_decorations = "RESIZE"

-- Slightly see-through with the desktop blurred behind it. Kept mild on purpose: any lower and
-- text edges start to soften. CMD+OPT+↑ turns it off when that matters.
config.window_background_opacity = 0.94
if IS_MAC then
  config.macos_window_background_blur = 26
end

if IS_WIN then
  -- Mở thẳng vào Ubuntu thay vì PowerShell.
  config.default_domain = "WSL:Ubuntu"
  -- Render bằng GPU rời.
  config.front_end = "WebGpu"
  config.max_fps = 144
end

-- The fancy tab bar is the native-looking one, and it doubles as the status strip below, so it
-- stays visible even with a single tab.
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 28
config.window_frame = frame_for(config.color_scheme)
if theme.gradient then
  config.window_background_gradient = gradient_for(config.color_scheme)
end

-- ── Status strip ──────────────────────────────────────────────────────────────
-- Right-hand side of the tab bar: where I am, which scheme is on, battery, clock.
local function short_path(path)
  local home = os.getenv("HOME")
  if home and path:sub(1, #home) == home then
    path = "~" .. path:sub(#home + 1)
  end
  local parts = {}
  for part in path:gmatch("[^/]+") do
    parts[#parts + 1] = part
  end
  if #parts > 3 then
    return "…/" .. parts[#parts - 1] .. "/" .. parts[#parts]
  end
  return path
end

local function cwd_of(pane)
  local ok, cwd = pcall(function()
    return pane:get_current_working_dir()
  end)
  if not ok or not cwd then
    return nil
  end
  local path = cwd.file_path
  if not path then
    path = tostring(cwd):gsub("^file://[^/]*", "")
  end
  return short_path(path)
end

local function battery_label()
  local info = wezterm.battery_info()
  if #info == 0 then
    return nil
  end
  local b = info[1]
  local pct = string.format("%.0f%%", b.state_of_charge * 100)
  if b.state == "Charging" then
    return "⚡ " .. pct
  end
  return pct
end

wezterm.on("update-right-status", function(window, pane)
  local bits = {}

  local cwd = cwd_of(pane)
  if cwd then
    bits[#bits + 1] = cwd
  end

  -- Scheme name without the collection suffix, so stepping through the list stays legible.
  local scheme = (window:effective_config().color_scheme or ""):gsub("%s*%(.-%)$", "")
  if scheme ~= "" then
    bits[#bits + 1] = scheme
  end

  local battery = battery_label()
  if battery then
    bits[#bits + 1] = battery
  end

  bits[#bits + 1] = wezterm.strftime("%H:%M")

  window:set_right_status(wezterm.format({
    { Attribute = { Intensity = "Half" } },
    { Text = " " .. table.concat(bits, "  ·  ") .. "  " },
  }))
end)

-- ── Quiet ─────────────────────────────────────────────────────────────────────
config.audible_bell = "Disabled"

-- Closing a window with a long agent run inside it should take a deliberate second click, so the
-- confirmation prompt stays on.
config.window_close_confirmation = "AlwaysPrompt"

-- ── Keys ──────────────────────────────────────────────────────────────────────
config.keys = {
  { key = "DownArrow", mods = SUPER_ALT, action = wezterm.action_callback(toggle_gradient) },
  {
    key = "UpArrow",
    mods = SUPER_ALT,
    action = wezterm.action_callback(function(window)
      local overrides = window:get_config_overrides() or {}
      if overrides.window_background_opacity == 1.0 then
        overrides.window_background_opacity = nil
      else
        overrides.window_background_opacity = 1.0
      end
      window:set_config_overrides(overrides)
    end),
  },
}

return config
