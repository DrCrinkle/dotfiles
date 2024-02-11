# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# clean up dotfiles
eval "$(antidot init)"

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

transfer() {
   if [ $# -eq 0 ]; then
      echo "No arguments specified.\nUsage:\n  transfer <file|directory>\n  ... | transfer <file_name>" >&2
      return 1
   elif tty -s; then
      file="$1"
      # Remove spaces from file or directory name
      file_name=$(basename "$file" | sed 's/ /_/g')
      if [ ! -e "$file" ]; then
         echo "$file: No such file or directory" >&2
         return 1
      elif [ -d "$file" ]; then
         # Use modified file_name for directories as well
         file_name="$file_name.zip"
         (cd "$file" && zip -r -q - .) | curl -v --progress-bar --upload-file "-" "https://transfer.sh/$file_name" | tee /dev/null
      else
         # Use modified file_name for files
         cat "$file" | curl -v --progress-bar --upload-file "-" "https://transfer.sh/$file_name" | tee /dev/null
      fi
   else
      # This part handles input from a pipe, where a file name must be specified as an argument
      # Remove spaces from the specified file_name
      file_name=$(echo "$1" | sed 's/ /_/g')
      curl -v --progress-bar --upload-file "-" "https://transfer.sh/$file_name" | tee /dev/null
   fi
}

extract() {
   if [[ -z "$1" ]]; then
       print -P "usage: \e[1;36mextract\e[1;0m < filename >"
       print -P "       Extract the file specified based on the extension"
   elif [[ -f $1 ]]; then
       case ${(L)1} in
           *.tar.xz)   tar -Jxf   $1 ;;
           *.tar.bz2)  tar -jxvf  $1 ;;
           *.tar.gz)   tar -zxvf  $1 ;;
           *.bz2)      bunzip2    $1 ;;
           *.gz)       gunzip     $1 ;;
           *.jar)      unzip      $1 ;;
           *.rar)      unrar x    $1 ;;
           *.tar)      tar -xvf   $1 ;;
           *.tbz2)     tar -jxvf  $1 ;;
           *.tgz)      tar -zxvf  $1 ;;
           *.zip)      unzip      $1 ;;
           *.Z)        uncompress $1 ;;
           *.7z)       7za e      $1 ;;
           *)          echo "Unable to extract '$1' :: Unknown extension"
       esac
   else
       echo "File ('$1') does not exist!"
   fi
}

mntiso() {
   if [[ -z "$1" ]]; then
      print -P "usage: \e[1;36mmntiso\e[1;0m < filename >"
      print -P "       Mount the iso file specified at /mnt/iso"
   elif [[ -f $1 ]]; then
      sudo mount -o loop $1 /mnt/iso
   else
      echo "File ('$1') does not exist!"
   fi
}

quick-warc() {
   if [ -f $1.warc.gz ]; then
      echo "$1.warc.gz already exists"
   else
      wget --warc-file=$1 --warc-cdx --mirror --page-requisites --no-check-certificate --restrict-file-names=windows \
      -e robots=off --waitretry 5 --timeout 60 --tries 5 --wait 1 \
      -U "Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/533.20.25 (KHTML, like Gecko) Version/5.0.4 Safari/533.20.27" \
      "http://$1/"
   fi
}

# Better history
# Credits to https://coderwall.com/p/jpj_6q/zsh-better-history-searching-with-arrow-keys
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down

alias cyanrip="cyanrip -s +6" #my disc drive (HL-DT-ST BD-RE  WH16NS40) has an offset of +6 according to AccurateRip
alias ls="ls --color=auto"
