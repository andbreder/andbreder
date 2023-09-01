#!/bin/bash

#region TERMINAL CUSTOM TEXT COLORS

BLK_CLR="\033[30m" # black
RED_CLR="\033[31m" # red
GRN_CLR="\033[32m" # green
YLW_CLR="\033[33m" # yellow
BLU_CLR="\033[34m" # blue
PUR_CLR="\033[35m" # purple
CYN_CLR="\033[36m" # cyan
WHT_CLR="\033[37m" # white

BLK_LCR="\033[90m" # light-black
RED_LCR="\033[91m" # light-red
GRN_LCR="\033[92m" # light-green
YLW_LCR="\033[93m" # light-yellow
BLU_LCR="\033[94m" # light-blue
PUR_LCR="\033[95m" # light-purple
CYN_LCR="\033[96m" # light-cyan
WHT_LCR="\033[97m" # light-white

BLK_BLD="\033[30;1m" # black  / textcolor + bold
RED_BLD="\033[31;1m" # red    / textcolor + bold
GRN_BLD="\033[32;1m" # green  / textcolor + bold
YLW_BLD="\033[33;1m" # yellow / textcolor + bold
BLU_BLD="\033[34;1m" # blue   / textcolor + bold
PUR_BLD="\033[35;1m" # purple / textcolor + bold
CYN_BLD="\033[36;1m" # cyan   / textcolor + bold
WHT_BLD="\033[37;1m" # white  / textcolor + bold

BLK_UND="\033[30;4m" # black  / textcolor + underline
RED_UND="\033[31;4m" # red    / textcolor + underline
GRN_UND="\033[32;4m" # green  / textcolor + underline
YLW_UND="\033[33;4m" # yellow / textcolor + underline
BLU_UND="\033[34;4m" # blue   / textcolor + underline
PUR_UND="\033[35;4m" # purple / textcolor + underline
CYN_UND="\033[36;4m" # cyan   / textcolor + underline
WHT_UND="\033[37;4m" # white  / textcolor + underline

BLK_BGC="\033[40m" # black  / background
RED_BGC="\033[41m" # red    / background
GRN_BGC="\033[42m" # green  / background
YLW_BGC="\033[43m" # yellow / background
BLU_BGC="\033[44m" # blue   / background
PUR_BGC="\033[45m" # purple / background
CYN_BGC="\033[46m" # cyan   / background
WHT_BGC="\033[47m" # white  / background

BLK_BGL="\033[100m" # black  / light-background
RED_BGL="\033[101m" # red    / light-background
GRN_BGL="\033[102m" # green  / light-background
YLW_BGL="\033[103m" # yellow / light-background
BLU_BGL="\033[104m" # blue   / light-background
PUR_BGL="\033[105m" # purple / light-background
CYN_BGL="\033[106m" # cyan   / light-background
WHT_BGL="\033[107m" # white  / light-background

T_RESET="\033[0m"   # text reset

#endregion

OS_PROFILE_LINUX="LINUX"
OS_PROFILE_WINDOWS="WIN"

#region TERMINAL PS1
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
  LOCAL_IPV4=`ipconfig | egrep --ignore-case --text 'ipv4.*\. \.' | cut -c 13- | sed 's/.*\:\s//' | awk -F. '{printf "%03d.%03d.%03d.%03d\n", $1, $2, $3, $4}'`
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
    echo "( $git_main"
  fi
}
function get_git_ps1_pths_pos() {
  local git_main
  git_main=$(__git_ps1 "%s")
  if [ -n "$git_main" ]; then
    echo " )"
  fi
}
function get_git_ps1_changed() {
  local git_main
  git_main=$(__git_ps1 "%s")
  if [ -n "$git_main" ]; then
    if git status | grep -q "Changes to be committed"; then
      echo " [+]"
    fi
  fi
}
function get_git_ps1_not_staged() {
  local git_main
  git_main=$(__git_ps1 "%s")
  if [ -n "$git_main" ]; then
    if git status | grep -q "Changes not staged for commit" || git status | grep -q "Untracked files"; then
      echo " [x]"
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
'${BLK_LCR}$LOCAL_IPV4' \
'${BLU_CLR}'\u \
'${BLK_LCR}'`get_curr_path`'${YLW_CLR}'`get_curr_folder` \
'${CYN_CLR}'`get_git_ps1`\
'${GRN_CLR}'`get_git_ps1_changed`\
'${RED_CLR}'`get_git_ps1_not_staged`\
'${CYN_CLR}'`get_git_ps1_pths_pos`\
\n\
'${BLK_LCR}'$ '$T_RESET
#endregion

#region GIT ALIAS
alias         gadd='git_alias "add"'         # add
alias      gbranch='git_alias "branch"'      # branch
alias           gb='git_alias "branch"'      # 
alias       gclone='git_alias "clone"'       # clone
alias           gc='git_alias "clone"'       # 
alias      gcommit='git_alias "commit"'      # commit
alias          gcm='git_alias "commit"'      # 
alias    gcheckout='git_alias "checkout"'    # checkout
alias         gchk='git_alias "checkout"'    # 
alias gcherry-pick='git_alias "cherry-pick"' # cherry-pick
alias      gcherry='git_alias "cherry-pick"' # 
alias        gchpk='git_alias "cherry-pick"' # 
alias        gdiff='git_alias "diff"'        # diff
alias          gdf='git_alias "diff"'        # 
alias       gfetch='git_alias "fetch"'       # fetch
alias          gft='git_alias "fetch"'       # 
alias         glog='git_alias "log"'         # log
alias       gmerge='git_alias "merge"'       # merge
alias          gmr='git_alias "merge"'       # 
alias          gmv='git_alias "mv"'          # mv
alias        gpush='git_alias "push"'        # push
alias        gpull='git_alias "pull"'        # pull
alias          grm='git_alias "rm"'          # rm
alias      grebase='git_alias "rebase"'      # rebase
alias          grb='git_alias "rebase"'      # 
alias      grevert='git_alias "revert"'      # revert
alias         grvt='git_alias "revert"'      # 
alias    gshortlog='git_alias "shortlog"'    # shortlog
alias        gslog='git_alias "shortlog"'    #
alias      gstatus='git_alias "status"'      # status
alias          gst='git_alias "status"'      # 
alias       gstash='git_alias "stash"'       # stash
alias      gswitch='git_alias "switch"'      # switch
alias         gswt='git_alias "switch"'      # 
alias         gtag='git_alias "tag"'         # tag

function git_alias() {
  echo -e "$PUR_CLR\$ git $1$T_RESET"
  git "$@"
}

function gfast() {
  gadd .
  gcommit -m "$1"
  gpush
}
function gurl() {
  echo -e "$PUR_CLR$ git config --get remote.origin.url$T_RESET"
  GIT_URL=$(git config --get remote.origin.url)
  echo -e "\n\t${GIT_URL%.git}"
}

#endregion

#region UUIDGEN

HARD_DISK_LETTER=$(mount | head -n 1 | awk -F ':' '{print $1}')
WINDOWS_MAJOR_VERSION=$(wmic os get Version | sed -n '2p' | cut -d '.' -f 1)
SYSTEM_ARCHITECTURE=$(wmic os get OSArchitecture | sed -n '2p' | cut -d '-' -f 1)
UUIDGEN_PATH=$(find "$HARD_DISK_LETTER:\\Program Files (x86)\\Windows Kits\\$WINDOWS_MAJOR_VERSION\\bin" -name uuidgen* | tac | grep "x$SYSTEM_ARCHITECTURE" | head -1)

function guid() {
  if [ -e "$UUIDGEN_PATH" ]; then
    echo -e "${PUR_UND}uuidgen$T_RESET $("$UUIDGEN_PATH")"
  else
    # <!> "printf" porque vai acontecer um "10\bin" e isso (0\b) quebra o terminal usando "echo -e ..."
    printf "${RED_CLR}not found!$T_RESET %s\n" "${UUIDGEN_PATH@Q}"
  fi
}

#endregion

function profile() {
  if [ "$#" -eq 0 ]; then
    profile --help
  else
    case "$1" in
      -c|--code)
        echo -e "${PUR_UND}profile${T_RESET} ${PUR_CLR}--code${T_RESET} ~/.profile"
        code ~/.profile
        ;;
      -s|--save)
        if [ ! "$#" -eq 2 ]; then
          profile --help
          return
        fi
        output="$2"
        if [ -d "$2" ]; then
          output="$2/.profile"
        fi
        echo -e "${PUR_UND}profile${T_RESET} ${PUR_CLR}--save${T_RESET} ~/.profile $output"
        cp ~/.profile "$output"
        ;;
      -h|--help|*)
        echo -e "${PUR_UND}profile${T_RESET} usage:\n"
        echo -e "  ${BLU_CLR}--code${T_RESET} | -c          opens the current .profile file for editing"
        echo -e "  ${BLU_CLR}--help${T_RESET} | -h          displays command execution options"
        echo -e "  ${BLU_CLR}--save${T_RESET} | -s <path>   updates the .profile file in the ~/ directory"
        echo ""
        ;;
    esac
  fi
}

# "settings.json" > desabilitar historico
# ... "terminal.integrated.persistentSessionReviveProcess": "never",
# ... "terminal.integrated.enablePersistentSessions": false

# apagar o historico do terminal anterior e a mensagem chata "History restored"
clear

CCD_FILE_REF=~/.ccd
function ccd() {
  if [ ! -d "$1" ]; then
    echo -e "${RED_CLR}not found!$T_RESET $1"
  else
    cd $1
    pwd > "$CCD_FILE_REF"
  fi
}

if [ -f "$CCD_FILE_REF" ] && [ -s "$CCD_FILE_REF" ]; then
  ccd_first_line=$(head -n 1 "$CCD_FILE_REF")
  if [ -d "$ccd_first_line" ]; then
    echo -e "${BLK_LCR}# ${PUR_UND}ccd${T_RESET}${BLK_LCR} [$CCD_FILE_REF]${GRN_CLR} restored, moving to${T_RESET}"
    cd "$ccd_first_line"
  else
    echo -e "${BLK_LCR}# ${PUR_UND}ccd${T_RESET}${BLK_LCR} [$CCD_FILE_REF]${RED_CLR} recorded directory ${RED_UND}not found${T_RESET}"
    rm "$ccd_file"
  fi
fi

