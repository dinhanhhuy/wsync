set -e

# Setting
HOUR_BEFORE_CHECK=0
WSYNC_CONFIG_FILE=~/.wsync.config


if [ ! -f $WSYNC_CONFIG_FILE ]; then
  echo "[INFO]: Create config file"
  touch $WSYNC_CONFIG_FILE
fi

ask() {
  read -p "$1" confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]
}

check_for_update() {
  LAST=$(cat $WSYNC_CONFIG_FILE)
  NOW=$(date +%s)
  SECOND=$(($NOW-$LAST))
  HOUR=$((DELTA/3600))

  if [ $HOUR -lt $HOUR_BEFORE_CHECK ]; then
    exit 0
  fi

  cd $GIT_FOLDER
  CURRENT_COMMIT=$(git rev-parse HEAD)
  LATEST_COMMIT=$(git rev-parse origin/master)

  if [ "${CURRENT_COMMIT}" != "${LATEST_COMMIT}" ]; then
    echo "[INFO]: up to date"
    exit 0
  else
    ask "Do you want to update [y/n]? "
    git pull | cowsay
    date +%s > $WSYNC_CONFIG_FILE
  fi
}


BASE_CONFIG_PATH="/home/dahuy/.zshrc"
SHARE_CONFIG_PATH=""
GIT_FOLDER="/home/dahuy/.ssh"

check_for_update