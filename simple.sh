#!/bin/sh

# Color variables
cr="\033[1;31m"
ce="\033[1;37m"
cb="\033[1;34m"

# Colors
c() { printf "\033[%s;%sm" "$1" "$2"; }

# Get info functions
Name() {
  read -r host < /etc/hostname;
  printf "%s@%s" "$USER" "$host";
}

Os() {
  if command -v lsb_release 1>/dev/null; then 
    os=$(lsb_release -sc);
  else 
    . /etc/os-release ;
    os=$NAME;
  fi
  printf "%s" "$os";
}

Kernel() {
  read -r _ _ kern _ < /proc/version;
  printf "%s" "$kern";
}

Uptime() {
  IFS=. read -r up _ < /proc/uptime;
  printf "%dD %dH %dM" "$((up / 60 / 60 / 24))" "$((up / 60 / 60 % 24))" "$((up / 60 % 60))";
}

Shell() { printf "%s" "${SHELL##*/}"; }

Desktop() {
  if [ "$DESKTOP_SESSION" != "" ]; then
    printf "%s\n" "$DESKTOP_SESSION"
  elif [ "$XDG_CURRENT_DESKTOP" != "" ]; then
    printf "%s\n" "$XDG_CURRENT_DESKTOP"
  else
    for i in /proc/*/comm; do
      [ -f "$i" ] || continue
      read -r p < "$i"
      case "$p" in
        awesome|xmonad*|qtile|sway|i3|[bfo]*box|*wm*) printf "%s" "${p%%-*}"; break;;
      esac
    done
  fi
}

Memory() {
  while IFS=':k ' read -r mem1 mem2 _; do
    case "$mem1" in
      MemTotal)
        memt="$(( mem2 / 1024 ))";;
      MemAvailable)
        memu="$(( memt - mem2 / 1024))";;
    esac;
  done < /proc/meminfo;
  printf "%dMib / %dMib" "$memu" "$memt";
}

help() { printf "${ce}Usage: fetch [ ${cb}-c${ce} config_file${ce} | ${cb}-d${ce} | ${cb}-h${ce} ]
  ${cb}-c:${ce} provide a config 
  ${cb}-d:${ce} use default config 
  ${cb}-h:${ce} show help
${cr}Report issue at:${ce} https://github.com/manas140/fetch\n\n" && exit; }

def_conf() {
  printf "$(c 0 37)
  ⣿⣿⣿⣿⣯⣿⣿⠄⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠈⣿⣿⣿⣿⣿⣿⣆⠄    $(c 1 34)$(Name)$(c 0 0)
  ⢻⣿⣿⣿⣾⣿⢿⣢⣞⣿⣿⣿⣿⣷⣶⣿⣯⣟⣿⢿⡇⢃⢻⣿⣿⣿⣿⣿⢿⡄    $(c 1 37; c 0 37)
  ⠄⢿⣿⣯⣏⣿⣿⣿⡟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣧⣾⢿⣮⣿⣿⣿⣿⣾⣷    Os       : $(Os)
  ⠄⣈⣽⢾⣿⣿⣿⣟⣄⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣝⣯⢿⣿⣿⣿⣿    Kernel   : $(Kernel)
  ⣿⠟⣫⢸⣿⢿⣿⣾⣿⢿⣿⣿⢻⣿⣿⣿⢿⣿⣿⣿⢸⣿⣼⣿⣿⣿⣿⣿⣿⣿    Uptime   : $(Uptime)
  ⡟⢸⣟⢸⣿⠸⣷⣝⢻⠘⣿⣿⢸⢿⣿⣿⠄⣿⣿⣿⡆⢿⣿⣼⣿⣿⣿⣿⢹⣿    Shell    : $(Shell)
  ⡇⣿⡿⣿⣿⢟⠛⠛⠿⡢⢻⣿⣾⣞⣿⡏⠖⢸⣿⢣⣷⡸⣇⣿⣿⣿⢼⡿⣿⣿    DE/WM    : $(Desktop)
  ⣡⢿⡷⣿⣿⣾⣿⣷⣶⣮⣄⣿⣏⣸⣻⣃⠭⠄⠛⠙⠛⠳⠋⣿⣿⣇⠙⣿⢸⣿    Memory   : $(Memory)
  ⠫⣿⣧⣿⣿⣿⣿⣿⣿⣿⣿⣿⠻⣿⣾⣿⣿⣿⣿⣿⣿⣿⣷⣿⣿⣹⢷⣿⡼⠋:
  ⠄⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⣿⣿⣿⠄⠄
  ⠄⠄⢻⢹⣿⠸⣿⣿⣿⣿⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣼⣿⣿⣿⣿⡟⠄⠄
  ⠄⠄⠈⢸⣿⠄⠙⢿⣿⣿⣹⣿⣿⣿⣿⣟⡃⣽⣿⣿⡟⠁⣿⣿⢻⣿⣿⢿⠄⠄
  ⠄⠄⠄⠘⣿⡄⠄⠄⠙⢿⣿⣿⣾⣿⣷⣿⣿⣿⠟⠁⠄⠄⣿⣿⣾⣿⡟⣿⠄⠄    $(c 0 90)  $(c 0 31)  $(c 0 32)  $(c 0 33)  $(c 0 34)  $(c 0 35)  $(c 0 36)  $(c 0 37)  $(c 0 0)
  ⠄⠄⠄⠄⢻⡇⠸⣆⠄⠄⠈⠻⣿⡿⠿⠛⠉⠄⠄⠄⠄⢸⣿⣇⣿⣿⢿⣿⠄⠄    $(c 0 90)  $(c 0 91)  $(c 0 92)  $(c 0 93)  $(c 0 94)  $(c 0 95)  $(c 0 96)  $(c 0 97)  $(c 0 0)
  \n"
}

#Import config
if [ -f "$HOME"/.config/fetch/conf ]; then
  . "$HOME"/.config/fetch/conf
else
  # Default Config
  conf() { def_conf; }
fi

case "$1" in
  *-d*) conf() { def_conf; };;
  *-c*) [ -f "$2" ] && . "$2" ;;
  *-h*) help;;
esac

conf
