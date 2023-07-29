#!/bin/bash

#region TERMINAL CUSTOM TEXT COLORS
BLK_CLR='\e[0;30m' # black  / textcolor
RED_CLR='\e[0;31m' # red    / textcolor
GRN_CLR='\e[0;32m' # green  / textcolor
YLW_CLR='\e[0;33m' # yellow / textcolor
BLU_CLR='\e[0;34m' # blue   / textcolor
PUR_CLR='\e[0;35m' # purple / textcolor
CYN_CLR='\e[0;36m' # cyan   / textcolor
WHT_CLR='\e[0;37m' # white  / textcolor
BLK_BLD='\e[1;30m' # black  / textcolor + bold
RED_BLD='\e[1;31m' # red    / textcolor + bold
GRN_BLD='\e[1;32m' # green  / textcolor + bold
YLW_BLD='\e[1;33m' # yellow / textcolor + bold
BLU_BLD='\e[1;34m' # blue   / textcolor + bold
PUR_BLD='\e[1;35m' # purple / textcolor + bold
CYN_BLD='\e[1;36m' # cyan   / textcolor + bold
WHT_BLD='\e[1;37m' # white  / textcolor + bold
BLK_UND='\e[4;30m' # black  / textcolor + underline
RED_UND='\e[4;31m' # red    / textcolor + underline
GRN_UND='\e[4;32m' # green  / textcolor + underline
YLW_UND='\e[4;33m' # yellow / textcolor + underline
BLU_UND='\e[4;34m' # blue   / textcolor + underline
PUR_UND='\e[4;35m' # purple / textcolor + underline
CYN_UND='\e[4;36m' # cyan   / textcolor + underline
WHT_UND='\e[4;37m' # white  / textcolor + underline
BLK_BGC='\e[40m'   # black  / background
RED_BGC='\e[41m'   # red    / background
GRN_BGC='\e[42m'   # green  / background
YLW_BGC='\e[43m'   # yellow / background
BLU_BGC='\e[44m'   # blue   / background
PUR_BGC='\e[45m'   # purple / background
CYN_BGC='\e[46m'   # cyan   / background
WHT_BGC='\e[47m'   # white  / background
T_RESET='\e[0m'    # text reset
#endregion

OS_PROFILE_LINUX="LINUX"
OS_PROFILE_WINDOWS="WIN"

# REF: 9822079d14474a9a87acee47231d0c4a >>>
# ? define a variavel OSPROFILEKEY a partir do sistema operacional reconhecido
OS_PROFILE_CURRENT="unknow"
# $OSTYPE < geralmente não encontrada em so linux
# se $OSTYPE, padrao, nao preenchida, retorna e utiliza o valor de uname
case "${OSTYPE:-$(uname)}" in
  *nix*|*nux*) OS_PROFILE_CURRENT=$OS_PROFILE_LINUX;;
  *msys*|*GW*) OS_PROFILE_CURRENT=$OS_PROFILE_WINDOWS;;
  *)
    echo "que sistema é esse tio? [${OSTYPE:-$(uname)}]"
    exit 1
    ;;
esac
# REF: 9822079d14474a9a87acee47231d0c4a <<<

LOCAL_IPV4=""
case $OS_PROFILE_CURRENT in
*$OS_PROFILE_LINUX*) ipv4='hostname -I';;
*$OS_PROFILE_WINDOWS*)
  # no windows, ipconfig retorna "um binario", da problema pra interpretar como texto etc...
  # pra contornar esse texto maluco, use o paremetro --text
  # o cut vai tbm ajudar a limpar o texto por conta o "ce-cedilha"
  #  1234567890123
  # "   Endere□o IPv4. . . . . . . .  . . . . . . . : 192.168.0.1"
  LOCAL_IPV4=`ipconfig | egrep --ignore-case --text 'ipv4' | cut -c 13- | sed 's/.*\:\s//' | awk -F. '{printf "%03d.%03d.%03d.%03d\n", $1, $2, $3, $4}'`
  ;;
*)
  echo "que sistema é esse tio? [${OSTYPE:-$(uname)}]"
  exit 1
  ;;
esac

function get_git_ps1() {
  local git_main
  git_main=$(__git_ps1 "%s")
  if [ -n "$git_main" ]; then
    echo "( $git_main "
  fi
}
function get_git_ps1_pths_pos() {
  local git_main
  git_main=$(__git_ps1 "%s")
  if [ -n "$git_main" ]; then
    echo ")"
  fi
}
function get_git_ps1_changed() {
  local git_main
  git_main=$(__git_ps1 "%s")
  if [ -n "$git_main" ]; then
    if git status | grep -q "Changes to be committed"; then
      echo "[+]"
    fi
  fi
}
function get_git_ps1_not_staged() {
  local git_main
  git_main=$(__git_ps1 "%s")
  if [ -n "$git_main" ]; then
    if git status | grep -q "Changes not staged for commit" || git status | grep -q "Untracked files"; then
      echo "[x]"
    fi
  fi
}

function get_curr_path() {
  dirname=`pwd`
  echo ${dirname%/*}
}
function get_curr_folder() {
  dirname=`pwd`
  echo /${dirname##*/}
}

# item
# ========================================================
# \[\033]0; | prefixo do titulo do terminal :
# \u        | nome do usuário               : = whoami
# \h        | nome da máquina               : = hostname
# \w        | diretorio completo            : = pwd
# \W        | diretorio atual               : apenas a pasta
# \n        | nova linha                    : 
# \s        | nome do shell atual           :  

export PS1='\
\[\033]0;$TITLEPREFIX:$PWD\007\]\
'$BLK_CLR'${LOCAL_IPV4} \
'$BLU_CLR'\u \
'$BLK_CLR'`get_curr_path`'$YLW_CLR'`get_curr_folder` \
'$CYN_CLR'`get_git_ps1`'$GRN_CLR'`get_git_ps1_changed`'$RED_CLR'`get_git_ps1_not_staged`'$CYN_CLR'`get_git_ps1_pths_pos`\
\n\
'$BLK_CLR'$ '$T_RESET
