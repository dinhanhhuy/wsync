set -e

# Setting
HOUR_BEFORE_CHECK=3
WSYNC_CONFIG_FILE=~/.wsync.config
IGNORE_CACHE_TIME=true
AUTO_UPDATE=true
USER_PATH="/root"
BASE_CONFIG_PATH="$USER_PATH/.zshrc"
SHARE_CONFIG_PATH=""
GIT_FOLDER="$USER_PATH/.ssh"

if [ ! -f $WSYNC_CONFIG_FILE ]; then
  echo "[INFO]: Create config file"
  touch $WSYNC_CONFIG_FILE
fi

ask() {
  read -p "$1" ASK_CONFIRM && [[ $ASK_CONFIRM == [yY] || $ASK_CONFIRM == [yY][eE][sS] ]]
}

update() {
  if [ ! $AUTO_UPDATE ]; then
     ask "Do you want to update [y/n]? "
  fi

  if [ $AUTO_UPDATE ] || [ $ASK_CONFIRM ];  then
    git pull
    date +%s > $WSYNC_CONFIG_FILE
    echo "[INFO]: $ source $BASE_CONFIG_PATH"
    source $BASE_CONFIG_PATH
  fi
}

check_for_update() {
  LAST=$(cat $WSYNC_CONFIG_FILE)
  LAST=${LAST:-0}
  NOW=$(date +%s)
  # echo $LAST $NOW
  SECOND=$(($NOW-$LAST))
  HOUR=$((DELTA/3600))

  if [ ! $IGNORE_CACHE_TIME ] && [ $HOUR -lt $HOUR_BEFORE_CHECK ]; then
    exit 0
  fi

  cd $GIT_FOLDER
  CURRENT_COMMIT=$(git rev-parse HEAD)
  LATEST_COMMIT=$(git rev-parse origin/master)

  if [ "$CURRENT_COMMIT" = "$LATEST_COMMIT" ]; then
    update
  fi
}

check_for_update
