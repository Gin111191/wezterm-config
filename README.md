# wezterm-config

Config [WezTerm](https://wezterm.org) cho **macOS và Windows**. Một file `wezterm.lua`, cố tình để ngắn — mặc định
của WezTerm vốn đã hợp lý, mỗi dòng ở đây tồn tại vì mặc định sai với cách tôi làm việc thật:
phiên Claude Code chạy dài, chữ tiếng Việt, và bộ chọn màu đổi được ngay trong lúc dùng.

```
 ~/…/config/wezterm  ·  Dusk-Navy  ·  ⚡ 87%  ·  14:32
 └────────────────┘    └────────┘    └────┘    └───┘
  thư mục hiện tại      scheme        pin       giờ
```

---

## Có gì

- **Bộ chọn scheme ngay trong terminal** — `CMD+SHIFT+T` mở danh sách fuzzy ~1100 scheme built-in,
  gõ để lọc, Enter là áp dụng **và lưu lại**
- **Sáng/tối tự theo macOS** — mỗi bên nhớ scheme riêng, hệ thống đổi appearance thì terminal đổi theo
- **Đổi scheme là mọi cửa sổ đang mở đổi theo** — không phải chỉ cửa sổ vừa bấm phím
- **Gradient nền sinh theo scheme đang chạy** — chọn scheme xanh thì gradient xanh, không hard-code
- **Titlebar bám màu scheme** — không còn dải xám macOS lệch màu ở trên
- **Nâng riêng slot ANSI 8** để dòng phụ của agent (tool output, số dòng, comment) đọc được
- **JetBrains Mono** — phủ đủ dấu tiếng Việt, không bị thay glyph thầm lặng
- **Scrollback 100.000 dòng** — một task Claude Code in ra nhiều hơn mặc định 3.500 dòng
- `colortest.sh` để soi 16 màu ANSI, thuộc tính chữ, dấu tiếng Việt và icon Nerd Font của scheme hiện tại

---

## Nền tảng

Một file `wezterm.lua` chạy cả hai bên. Khác biệt đi qua 3 biến ở đầu file (`IS_MAC`, `IS_WIN`, `SUPER`):

| | macOS | Windows |
|---|---|---|
| Phím bộ chọn scheme | `CMD+SHIFT+T` | `CTRL+SHIFT+T` |
| Bước qua scheme | `CMD+OPT+←/→` | `CTRL+SHIFT+ALT+←/→` |
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

| Phím | Tác dụng |
|---|---|
| `CMD+SHIFT+T` | Mở bộ chọn scheme (fuzzy, gõ để lọc) |
| `CMD+OPT+→` / `←` | Bước qua shortlist đã chọn sẵn, áp dụng ngay |
| `CMD+OPT+SHIFT+→` / `←` | Bước qua **toàn bộ** scheme theo thứ tự alphabet |
| `CMD+OPT+↑` | Bật/tắt trong suốt, khi cần tương phản tối đa |
| `CMD+OPT+↓` | Bật/tắt gradient nền |

Tất cả đều dùng phím mũi tên có chủ đích: mũi tên không sinh ký tự, nên một binding trượt cũng
không làm lọt chữ lạ vào chương trình đang chạy trong pane.

---

## Cấu trúc

| File | Vai trò |
|---|---|
| `wezterm.lua` | Toàn bộ config |
| `theme.lua` | Scheme đang chọn cho sáng/tối + cờ gradient. Do bộ chọn ghi ra, sửa tay cũng được |
| `colortest.sh` | Test màu + thuộc tính chữ của scheme đang chạy |

`theme.lua` tách riêng để bộ chọn ghi đè được mà không đụng vào `wezterm.lua`. WezTerm theo dõi
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

Đổi bằng `CMD+SHIFT+T`, hoặc sửa thẳng `theme.lua`.

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

## Yêu cầu

- macOS (config dùng `macos_window_background_blur` và appearance của hệ thống)
- WezTerm — JetBrains Mono đã đóng gói sẵn bên trong, không cần cài thêm
- Nerd Font là tuỳ chọn, chỉ để phần 6 của `colortest.sh` hiện icon
