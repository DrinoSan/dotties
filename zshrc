

export VISUAL="$EDITOR"

export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export VK_ICD_FILENAMES=/opt/homebrew/opt/vulkan-tools/lib/mock_icd/VkICD_mock_icd.json

ZSH_DISABLE_COMPFIX=true

# Path to your oh-my-zsh installation.
export ZSH="/Users/sandi/.oh-my-zsh"


# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="cdimascio-lambda"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
export EDITOR=vim
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='vim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
export PATH=/Library/Frameworks/Python.framework/Versions/3.9/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/sandi/.cargo/bin



# Created by `pipx` on 2021-10-17 11:38:05
#export PATH="$PATH:/Users/sandi/.local/bin"

# Created by `pipx` on 2021-10-17 11:47:37
#export PATH="$PATH:/Users/sandi/Library/Python/3.9/bin"


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniforge/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniforge/base/etc/profile.d/conda.sh" ]; then
# . "/opt/homebrew/Caskroom/miniforge/base/etc/profile.d/conda.sh"  # commented out by conda initialize
    else
        export PATH="/opt/homebrew/Caskroom/miniforge/base/bin:$PATH"
    fi
fi
unset __conda_setup


# DOGECOIN flags for compilation
export CFLAGS="-I/opt/homebrew/include $CFLAGS"
export PKG_CONFIG_PATH="/opt/homebrew/lib/pkgconfig:$PKG_CONFIG_PATH"


#
#export LD_LIBRARY_PATH="/opt/homebrew/Cellar/openssl@3/3.0.0/lib:/opt/homebrew/Cellar/openssl@3/3.0.0/include"


#Alias stuff
alias updatedb='sudo /usr/libexec/locate.updatedb'
#alias ls=lsd
#alias lg='lazygit'
alias sc='source ~/.zshrc'
alias doge='~/DEV/dogecoin'
alias makeCtags='/opt/homebrew/Cellar/ctags/5.8_2/bin/ctags -R'
export updatedb='sudo /usr/libexec/locate.updatedb'
export OPENSSL_ROOT_DIR="/usr/local/openssl/3.0.7"
export GOPATH="/Users/sandi/DEV/go/projects"
export GOROOT="/opt/homebrew/opt/go/libexec"



#cowsay "What you looking at?"
#fortune -s | cowsay
#cowsay -f ghostbusters Who you Gonna Call
export NVS_HOME="$HOME/.nvs"
[ -s "$NVS_HOME/nvs.sh" ] && . "$NVS_HOME/nvs.sh"

## Raspberry PI
export PICO_SDK_PATH="/Users/sandi/DEV/pico-sdk"

# Homebrew
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:$PATH"

export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export CPATH="/opt/homebrew/include"

export GOPATH=$HOME/go
export GOROOT="$(brew --prefix golang)/libexec"
export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"
# Add this to ~/.zshrc or ~/.bash_profile
export PATH="/Applications/MacPorts/Emacs.app/Contents/MacOS:$PATH"
export PATH="$HOME/.config/emacs/bin:$PATH"
export PATH="/usr/local/texlive/2024/bin/universal-darwin:$PATH"
export OPENSSL_ROOT_DIR=/opt/homebrew/opt/openssl@3

