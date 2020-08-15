set -e

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
  fi
}

check_for_update() {
  if [ ! -f $WSYNC_CONFIG_FILE ]; then
    touch $WSYNC_CONFIG_FILE
  fi
  LAST=$(cat $WSYNC_CONFIG_FILE)
  LAST=${LAST:-0}
  NOW=$(date +%s)
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
    if [ "$CUSTOM_EVAL" ]; then
      eval $CUSTOM_EVAL
    fi
  fi
}

# Let's rock
for FILE in config/*; do
  (
    echo "[INFO]: start sync config $FILE"
    while read line; do
      eval $line
    done < $FILE
    if [ -f $WSYNC_CONFIG_FILE ]; then
      CONFIG_NAME=${FILE##*/}
      CACHE_PATH=$(eval echo ~$USER)
      WSYNC_CONFIG_FILE=${WSYNC_CONFIG_FILE:-"$CACHE_PATH/.wsync.$CONFIG_NAME.time"}
    fi
    check_for_update
  )
done  
