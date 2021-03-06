# Change to the containing directory if the first argument was a file
cd () {
  last_directory=$PWD;

  file_or_directory="";
  if [ -n "$1" ]; then
    file_or_directory=$1;
  fi

  if [ -z "$file_or_directory" ]; then
    builtin cd;
  elif [ -f "$file_or_directory" ]; then
    builtin cd $(dirname $file_or_directory);
  else
    builtin cd "$file_or_directory";
  fi

  elixir_version_file=$PWD/.elixir-version;
  if [ -e "$elixir_version_file" ]; then
    refresh_environment=true;
  fi

  node_version_file=$PWD/.node-version;
  if [ -e "$node_version_file" ]; then
    refresh_environment=true;
  fi

  notags_file=$PWD/.notags;
  if [ -e "$notags_file" ]; then
    refresh_environment=true;
  fi

  python_version_file=$PWD/.python-version;
  if [ -e "$python_version_file" ]; then
    refresh_environment=true;
  fi

  ruby_version_file=$PWD/.ruby-version;
  if [ -e "$ruby_version_file" ]; then
    refresh_environment=true;
  fi

  sbt_version_file=$PWD/.sbt-version;
  if [ -e "$sbt_version_file" ]; then
    refresh_environment=true;
  fi

  if ([ -n "$PROJECT_DIRECTORY" ] && [[ ! $PWD =~ ^$PROJECT_DIRECTORY ]]) || \
    [ -n "$refresh_environment" ];
  then
    unset ELIXIR_VERSION;
    unset NODE_VERSION;
    unset NOTAGS;
    unset PROJECT_DIRECTORY;
    unset PYTHON_VERSION;
    unset RUBY_VERSION;
    unset SBT_VERSION;
  fi

  if [ -e "$elixir_version_file" ]; then
    export ELIXIR_VERSION=$(cat "$elixir_version_file");
  fi

  if [ -e "$node_version_file" ]; then
    export NODE_VERSION=$(cat "$node_version_file");
  fi

  if [ -e "$notags_file" ]; then
    export NOTAGS=true;
  fi

  if [ -e "$python_version_file" ]; then
    export PYTHON_VERSION=$(cat "$python_version_file");
  fi

  if [ -e "$ruby_version_file" ]; then
    export RUBY_VERSION=$(cat "$ruby_version_file");
  fi

  if [ -e "$sbt_version_file" ]; then
    export SBT_VERSION=$(cat "$sbt_version_file");
  fi

  if [ -n "$refresh_environment" ]; then
    export PROJECT_DIRECTORY=$PWD;
  fi
}

# Echos the last argument from the previous command
last_argument () {
  last_argument=`echo $(fc -ln -1) | tr ' ' '\n' | tail -1`;
  if [[ ! "$last_argument" =~ ^last_(argument|command)$ ]]; then
    echo $last_argument;
  fi
}

# Echos the last command
last_command () {
  last_command=`echo $(fc -ln -1) | sed 's/^[ \t]*//g'`;
  if [[ ! "$last_command" =~ ^last_(argument|command)$ ]]; then
    echo $last_command;
  fi
}

# Echos the last pid
last_pid () {
  last_pid=$!;
  if [ -n "$last_pid" ]; then
    echo $last_pid;
  fi
}

# Echos the last status
last_status () {
  last_status=$?;
  if [ -n "$last_status" ]; then
    echo $last_status;
  fi
}

# Echos an asterix if the local [git] repo has changes
parse_git_dirty () {
  nogitdirty_file=$HOME/.nogitdirty;
  if [ -f $nogitdirty_file ]; then
    return;
  fi

  dirty=`git status --porcelain 2> /dev/null`;
  if [ -n "$dirty" ]; then
    echo "*";
  fi
}

# Echos the current [git] branch
parse_git_branch () {
  nogitbranch_file=$HOME/.nogitbranch;
  if [ -f $nogitbranch_file ]; then
    return;
  fi

  branch=`git rev-parse --abbrev-ref HEAD 2> /dev/null`;
  if [ -n "$branch" ]; then
    echo "${branch}";
  fi
}

# Echos the current environment info
environment_prompt_info () {
  if [ -e "$PWD/.noenvironmentinfo" ] || [ -e "$HOME/.noenvironmentinfo" ]; then
    return;
  fi

  active_versions="";

  elixir_version=$ELIXIR_VERSION;
  if [ -n "$elixir_version" ]; then
    [[ $elixir_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] && \
      elixir_version="elixir-$elixir_version";
    active_versions="$active_versions $elixir_version";
  fi

  node_version=$NODE_VERSION;
  if [ -n "$node_version" ]; then
    [[ $node_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] && \
      node_version="node-$node_version";
    active_versions="$active_versions $node_version";
  fi

  python_version=$PYTHON_VERSION;
  if [ -n "$python_version" ]; then
    [[ $python_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] && \
      python_version="python-$python_version";
    active_versions="$active_versions $python_version";
  fi

  ruby_version=$RUBY_VERSION;
  if [ -n "$ruby_version" ]; then
    [[ $ruby_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] && \
      ruby_version="ruby-$ruby_version";
    active_versions="$active_versions $ruby_version";
  fi

  sbt_version=$SBT_VERSION;
  if [ -n "$sbt_version" ]; then
    [[ $sbt_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] && \
      sbt_version="sbt-$sbt_version";
    active_versions="$active_versions $sbt_version";
  fi

  if [ -n "$active_versions" ]; then
    echo "($(echo $active_versions | awk '{$1=$1};1' | sed 's/ /, /g')) ";
  fi
}

# Echos an "x" if the previous command has a non-zero exit-code
error_prompt_info () {
  last_exit_code=$?;

  noerrorinfo_file=$HOME/.noerrorinfo;
  if [ -f $noerrorinfo_file ]; then
    return;
  fi

  if [ $last_exit_code -ne 0 ]; then
    echo "x ";
  fi
}

# Echos the combination of git-branch and git-dirty to form an informative prompt
git_prompt_info () {
  nogitinfo_file=$HOME/.nogitinfo;
  if [ -f $nogitinfo_file ]; then
    return;
  fi

  if ! \which git > /dev/null 2>&1; then
    return;
  fi

  branch=$(parse_git_branch);
  dirty=$(parse_git_dirty);

  if [ -n "$branch" ] || [ -n "$dirty" ]; then
    echo "${branch}${dirty} ";
  fi
}

# Echos the hostname, it can be overridden with something static via $HOME/.hostname
hostname_prompt_info () {
  hostname_file=$HOME/.hostname;
  if [ -e "$hostname_file" ]; then
    cat $hostname_file;
  else
    hostname -s;
  fi
}
