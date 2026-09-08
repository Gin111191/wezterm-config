# wezterm-config

Config [WezTerm](https://wezterm.org) cho **macOS và Windows**. Một file `wezterm.lua`, cố tình để ngắn — mặc định
của WezTerm vốn đã hợp lý, mỗi dòng ở đây tồn tại vì mặc định sai với cách tôi làm việc thật:
phiên Claude Code chạy dài, chữ tiếng Việt, và màu đổi được ngay trong lúc dùng.

```
 ~/…/config/wezterm  ·  Dusk-Navy  ·  ⚡ 87%  ·  14:32
 └────────────────┘    └────────┘    └────┘    └───┘
  thư mục hiện tại      scheme        pin       giờ
```

---

## Có gì

- **Scheme khai báo trong `theme.lua`** — sửa tay, lưu là mọi cửa sổ đang mở đổi ngay (WezTerm theo dõi file)
- **Sáng/tối tự theo hệ điều hành** — mỗi bên nhớ scheme riêng
- **Gradient nền sinh theo scheme đang chạy** — chọn scheme xanh thì gradient xanh, không hard-code
- **Titlebar bám màu scheme** — không còn dải xám macOS lệch màu ở trên
- **Nâng riêng slot ANSI 8** để dòng phụ của agent (tool output, số dòng, comment) đọc được
- **JetBrains Mono** — phủ đủ dấu tiếng Việt, không bị thay glyph thầm lặng
- **Scrollback 100.000 dòng** — một task Claude Code in ra nhiều hơn mặc định 3.500 dòng
- `colortest.sh` để soi 16 màu ANSI, thuộc tính chữ, dấu tiếng Việt và icon Nerd Font của scheme hiện tại

---

## Đổi màu

Sửa `theme.lua`:

```lua
return { dark = "Dusk-Navy", light = "Everforest Light Medium (Gogh)", gradient = true }
```

Tên scheme lấy từ [danh sách built-in của WezTerm](https://wezterm.org/colorschemes/index.html) (~1100 cái),
hoặc tự thêm bảng màu vào `CUSTOM_SCHEMES` trong `wezterm.lua` như `Dusk-Navy`.

Lưu file là xong — WezTerm theo dõi `theme.lua` nên mọi cửa sổ đang mở đổi theo ngay.
Cấu hình Neovim ở [Gin111191/nvim-config](https://github.com/Gin111191/nvim-config) cũng đọc chính file này.

## Nền tảng

Một file `wezterm.lua` chạy cả hai bên. Khác biệt đi qua 3 biến ở đầu file (`IS_MAC`, `IS_WIN`, `SUPER`):

| | macOS | Windows |
|---|---|---|
| Bật/tắt gradient | `CMD+OPT+↓` | `CTRL+SHIFT+ALT+↓` |
| Bật/tắt nền trong | `CMD+OPT+↑` | `CTRL+SHIFT+ALT+↑` |
| Font giao diện titlebar | SF Pro Text | Segoe UI |
| Nền mờ | `macos_window_background_blur` | (macOS mới có) |
| Shell mặc định | mặc định hệ thống | mở thẳng `WSL:Ubuntu` |
| Render | mặc định | `WebGpu`, 144 fps |

Sáng/tối tự theo hệ thống ở cả hai nền tảng.

## Cài đặt

```sh
git clone https://github.com/Gin111191/wezterm-config ~/.config/wezterm
```

Nếu `~/.config/wezterm` đã có sẵn thì sao lưu trước:

```sh
mv ~/.config/wezterm ~/.config/wezterm.bak.$(date +%s)
git clone https://github.com/Gin111191/wezterm-config ~/.config/wezterm
```

WezTerm theo dõi file config và tự nạp lại khi lưu — **không cần khởi động lại**.

---

## Phím tắt

| Tác dụng | macOS | Windows |
|---|---|---|
| Bật/tắt trong suốt, khi cần tương phản tối đa | `CMD+OPT+↑` | `CTRL+SHIFT+ALT+↑` |
| Bật/tắt gradient nền | `CMD+OPT+↓` | `CTRL+SHIFT+ALT+↓` |

Chỉ hai phím này, đều là modifier+mũi tên có chủ đích: mũi tên không sinh ký tự, nên một binding
trượt cũng không làm lọt chữ lạ vào chương trình đang chạy trong pane. Đổi màu thì sửa `theme.lua`,
không có phím tắt riêng.

---

## Cấu trúc

| File | Vai trò |
|---|---|
| `wezterm.lua` | Toàn bộ config |
| `theme.lua` | Scheme đang chọn cho sáng/tối + cờ gradient. Sửa tay, lưu là áp dụng ngay |
| `colortest.sh` | Test màu + thuộc tính chữ của scheme đang chạy |

`theme.lua` tách riêng để đổi scheme mà không đụng vào `wezterm.lua`. WezTerm theo dõi
file đó, nên một lần ghi là kích hoạt reload ở **mọi** cửa sổ.

---

## Scheme mặc định

**Tối: `Dusk-Navy`** — scheme tự viết, port từ một profile Terminal.app. Mười sáu màu ANSI,
foreground, con trỏ và vùng chọn giữ nguyên giá trị sRGB của profile gốc.

Hai thứ cố tình **không** lấy theo profile: nền gốc là `#000B10` (gần như đen), ở đây giữ `#1d2837`;
và độ trong của profile (alpha 0.70) bị bỏ qua, thay bằng opacity/blur/gradient đặt trong config.

| | |
|---|---|
| Nền | `#1d2837` |
| Chữ | `#EDEEF7` |
| Con trỏ | `#A9AFC6` |
| Vùng chọn | `#3D4A6B` |

**Sáng: `Everforest Light Medium (Gogh)`** — built-in.

Đổi bằng cách sửa `theme.lua` — lưu file là mọi cửa sổ đang mở đổi theo ngay.

---

## Ghi chú: chữ mờ của agent

Mọi agent chạy trong terminal đều vẽ dòng phụ — tóm tắt tool, số dòng, `+59 lines`, comment — bằng
ANSI slot 8, "bright black". Phần lớn scheme để slot đó lệch vài phần trăm so với nền: đẹp trong ảnh
chụp, không đọc nổi khi dùng thật. Config này **chỉ** nâng slot 8; mười lăm màu còn lại giữ nguyên
đúng như tác giả scheme đã chọn.

`foreground_text_hsb` **không** giải quyết được chuyện này. Đã thử (brightness 1.35, rồi 2.0), config
có reload thật — kiểm chứng bằng một phép thử đổi font-size — mà các dòng mờ không nhúc nhích. Nâng
slot trong palette mới ăn.

Và nó chỉ có tác dụng khi theme của agent là biến thể ANSI — ví dụ `"theme": "dark-ansi"` trong
`~/.claude/settings.json`. Các theme truecolor đi vòng qua palette này.

---

## Nerd Font

**Có cần cài không: không bắt buộc.** WezTerm đóng gói sẵn `Symbols Nerd Font Mono` và tự
dùng nó làm chốt chặn cuối, nên icon của starship/eza/lf vẫn hiện dù bạn chưa cài font nào.
Đây là điểm khác biệt với Terminal.app, iTerm2 hay Windows Terminal — ở những terminal đó
thiếu Nerd Font là prompt ra toàn ô vuông.

Xem chuỗi font thật mà WezTerm đang dùng:

```sh
wezterm ls-fonts
```

Nếu chưa cài `JetBrainsMono Nerd Font`, lệnh trên mở đầu bằng cảnh báo — **không phải lỗi**,
chỉ là báo nó đang rơi xuống fallback:

```
Unable to load a font specified by your font=wezterm.font('JetBrainsMono Nerd Font', ...)
configuration. Fallback(s) are being used instead
```

và chuỗi rơi về: `JetBrains Mono` (WezTerm đóng gói) → `Menlo` → `Noto Color Emoji` →
`Symbols Nerd Font Mono` (cũng đóng gói). Chữ và icon đều hiện, chỉ là icon lấy từ font
symbols rời chứ không phải cùng một font với chữ.

**Cài để làm gì.** Một font duy nhất lo cả chữ lẫn icon thì bề ngang glyph đều nhau hơn,
icon không lệch baseline so với chữ bên cạnh. Cài xong không phải sửa gì —
`JetBrainsMono Nerd Font` đã nằm đầu danh sách fallback trong `wezterm.lua`.

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
fc-list | grep -i "JetBrainsMono Nerd Font" | head -3   # có dòng ra là xong
```

**Windows (và WSL)**

Tải `JetBrainsMono.zip` từ [nerdfonts.com](https://www.nerdfonts.com/font-downloads), giải nén,
bôi đen toàn bộ file `.ttf` → chuột phải → **Install for all users**.

Với WSL, font phải cài bên **Windows** chứ không phải bên Linux: Windows mới là bên vẽ chữ,
Linux chỉ gửi ký tự sang.

Cài xong mở lại WezTerm rồi chạy `wezterm ls-fonts` — cảnh báo biến mất và
`JetBrainsMono Nerd Font` đứng đầu chuỗi. Không cần sửa `wezterm.lua`.

Muốn font khác thì đổi tên trong `config.font_with_fallback` ở `wezterm.lua`; giữ
`JetBrains Mono` ở vị trí thứ hai vì nó luôn có mặt và phủ đủ dấu tiếng Việt.

---

## Ghi chú: app để theme sáng trên nền tối

Triệu chứng: mở một tool chạy trong terminal (Claude Code, một TUI bất kỳ), chữ và nền
chìm vào nhau, gần như không đọc được — trong khi shell bình thường vẫn rõ.

Nguyên nhân không nằm ở WezTerm. Scheme mặc định `Dusk-Navy` có nền `#1d2837`, tối. Nếu app
đó đang để theme **sáng**, nó vẽ chữ màu tối vì tưởng mình đang nằm trên nền trắng. Chữ tối
trên nền tối thì chìm.

Với Claude Code, kiểm tra và sửa:

```sh
grep '"theme"' ~/.claude/settings.json     # "light" trên nền tối là sai
defaults read -g AppleInterfaceStyle       # "Dark" = macOS đang tối
```

Sửa nhanh nhất là gõ `/config` trong Claude Code rồi chọn theme tối, khỏi đụng file.

**Cái bẫy còn lại:** `wezterm.lua` tự đổi scheme theo appearance của hệ điều hành (hàm
`scheme_for`), còn theme của Claude Code là **cố định**. Lật macOS sang Light mode thì
WezTerm chuyển sang `Everforest Light Medium` còn Claude Code vẫn tối — chìm ngược lại.
Đổi hệ điều hành sáng/tối thì nhớ đổi cả bên kia.

Chuyện này khác với mục *chữ mờ của agent* ở trên: ở đó **toàn bộ** giao diện vẫn đọc được,
chỉ riêng dòng phụ vẽ bằng ANSI slot 8 là mờ.

---

## Yêu cầu

- macOS (config dùng `macos_window_background_blur` và appearance của hệ thống)
- WezTerm — JetBrains Mono đã đóng gói sẵn bên trong, không cần cài thêm
- Nerd Font là tuỳ chọn — WezTerm đóng gói sẵn `Symbols Nerd Font Mono`. Xem mục *Nerd Font*
