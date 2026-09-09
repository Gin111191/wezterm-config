#!/usr/bin/env bash
# Colour + text-attribute test for the active WezTerm scheme.
# Run it in a real WezTerm tab: ~/.config/wezterm/colortest.sh

e=$'\033'
r="${e}[0m"

names=(black red green yellow blue magenta cyan white)

hr() { printf '%s[38;5;242m%s%s\n' "$e" "────────────────────────────────────────────────────────────────────────" "$r"; }
head() { printf '\n%s[1m%s%s\n' "$e" "$1" "$r"; hr; }

head "1 · 16 ANSI colours — normal / bold"
for i in {0..7}; do
  printf '  %-9s %s[3%dm%-22s%s %s[1;3%dm%-22s%s %s[38;5;%dm%s%s\n' \
    "${names[$i]}" \
    "$e" "$i" "normal  Xin chào" "$r" \
    "$e" "$i" "bold  Xin chào" "$r" \
    "$e" "$((i+8))" "bright  Xin chào" "$r"
done

head "2 · Background colours"
printf '  '; for i in {0..7}; do printf '%s[4%d;30m %d %s' "$e" "$i" "$i" "$r"; done; printf '\n  '
for i in {0..7}; do printf '%s[48;5;%dm %d %s' "$e" "$((i+8))" "$((i+8))" "$r"; done; printf '\n'

head "3 · Text attributes"
for a in "1:bold" "2:dim  (secondary slot)" "3:italic" "4:underline" \
         "9:strikethrough" "7:reverse" "21:double underline" "53:overline"; do
  printf '  %s[%sm%s%s\n' "$e" "${a%%:*}" "${a#*:}" "$r"
done
printf '  %s[4:3;58;5;1mundercurl%s\n' "$e" "$r"
printf '  %s[1;4;3mbold + underline + italic  combined%s\n' "$e" "$r"

head "4 · Dim text on the background — where Claude Code spends its time"
printf '  %s[2mdim: Read  wezterm.lua  ·  +59 lines  ·  ⎿ tool output%s\n' "$e" "$r"
printf '  %s[90mslot 8 (bright black): // comment, line numbers, secondary rows%s\n' "$e" "$r"
printf '  %s[38;5;242mgrey 242: if this line sinks in, the background is too light%s\n' "$e" "$r"

head "5 · Vietnamese — the full set of diacritics"
printf '  %s[37mế ộ ữ ằ ẳ ẵ ặ ọ ỏ ố ồ ổ ỗ ợ ứ ừ ử ữ ự ỳ ỷ ỹ ỵ đ Đ%s\n' "$e" "$r"
printf '  %s[1;33mNghiêng ngả  ·  Quyết định  ·  Trường hợp  ·  Hưởng ứng%s\n' "$e" "$r"

head "6 · Nerd Font icons"
printf '                  \n'
printf '  %s[34m%s  %s[32m%s  %s[31m%s  %s[33m%s%s\n' \
  "$e" "" "$e" "" "$e" "" "$e" "" "$r"
printf '  powerline: %s[7m %s%s[27m%s\n' "$e" "" "$e" "$r"

head "7 · Code syntax sample"
printf '  %s[35mlocal%s %s[36mconfig%s = %s[35mrequire%s(%s[32m"wezterm"%s)%s[2m  -- comment%s\n' \
  "$e" "$r" "$e" "$r" "$e" "$r" "$e" "$r" "$e" "$r"
printf '  %s[31m- removed line%s\n  %s[32m+ added line%s\n' "$e" "$r" "$e" "$r"
printf '  %s[1;31mERROR%s  %s[1;33mWARN%s  %s[1;32mOK%s  %s[1;34mINFO%s\n' \
  "$e" "$r" "$e" "$r" "$e" "$r" "$e" "$r"

head "8 · The 256-colour ramp"
printf '  '; for i in {16..51};  do printf '%s[48;5;%dm %s' "$e" "$i" "$r"; done; printf '\n  '
for i in {52..87};  do printf '%s[48;5;%dm %s' "$e" "$i" "$r"; done; printf '\n  '
for i in {232..255}; do printf '%s[48;5;%dm %s' "$e" "$i" "$r"; done; printf '\n'
echo
