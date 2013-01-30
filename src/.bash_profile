# Set the "Prompt"
export PS1='\[\e[36;1m\]\u\[\e[31;1m\]@\[\e[32;1m\]\h\[\033[1;34m\]:\[\e[35;1m\](\[\e[37;1m\]\w\[\e[35;1m\])\[\e[33;1m\]$ \[\e[0m\]'

# Update the "PATH"
export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin

# Set up the "History"
export HISTTIMEFORMAT='%Y-%m-%d %H:%M:%S - '
export HISTSIZE=100000
export HISTFILESIZE=100000

# Set the default "Editor" (git, amongst other things use this)
export EDITOR=vim

# Append to the history file, don't overwrite it
shopt -s histappend

# If it exists, process ".bash_aliases"
if [ -f ~/.bash_aliases ];
then
	. ~/.bash_aliases
fi

# If it exists, process ".bash_key_bindings"
if [ -f ~/.bash_key_bindings ];
then
	bind -f ~/.bash_key_bindings
fi

# If it exists, process ".sshagentrc"
if [ -f ~/.sshagentrc ];
then
	. ~/.sshagentrc
fi

# If it exists, load "RVM"
if [ -f ~/.rvm/scripts/rvm ];
then
	PATH=$PATH:~/.rvm/bin
	. ~/.rvm/scripts/rvm
fi

# "Homebrew" specific inclusions
BREW_PREFIX=`brew --prefix 2> /dev/null`
if [ -n "$BREW_PREFIX" ];
then
	# If it exists, process [Homebrew] "bash_completion"
	if [ -f $BREW_PREFIX/etc/bash_completion ];
	then
		. $BREW_PREFIX/etc/bash_completion
	fi
fi
