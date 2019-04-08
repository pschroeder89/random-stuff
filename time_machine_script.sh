#!/usr/bin/env bash

# USAGE: Run this script to get historical data from a repo. It traverses through a git repo's state at a set interval
# and runs your script on that date's master branch version
# Put this script in the root of your repo and run it in terminal via: `COMMAND=path/to/command INTERVAL=week sh time_machine_script.sh`

# MAC ONLY: THIS SCRIPT WON"T WORK IN LINUX DUE TO DATE COMMANDS, FEEL FREE TO ADD LINUX CONDITIONALS

if [[ -z $COMMAND ]];then
    echo "No COMMAND env var supplied, exiting intentionally."
    echo "Example: COMMAND=path/to/command INTERVAL=week sh time_machine_script.sh"
    echo "or"
    echo "COMMAND='echo hi' INTERVAL=week sh time_machine_script.sh"
    exit 1
fi

echo "Checking out master latest"
git pull
git checkout master

echo "Determining first commit epoch time"
time_to_check=$(git log origin/master --pretty=format:'%at' | tail -1)
echo "Determining current epoch time"
time_now=$(date +%s)

MINUTE=60
DAY=86400
WEEK=604800
YEAR=31557600

case ${INTERVAL} in
'minute')
  time_to_add=${MINUTE}
  ;;
'day')
  time_to_add=${DAY}
  ;;
'week')
  time_to_add=${WEEK}
  ;;
'year')
  time_to_add=${YEAR}
  ;;
*)
  echo "No INTERVAL env var supplied, defaulting to a week"
  time_to_add=${WEEK}
esac

checkout_and_run() {
    if [[ ${time_to_check} -le ${time_now} ]]; then
        find .  -mindepth 1 -maxdepth 1 -not -name '.git' -exec rm -rf {} + # Delete the repo except .git folder, so each checkout has a clean slate
        git checkout -f $(git rev-list -n 1 --after=${time_to_check} origin/master) 2> /dev/null # get the commit post-checkout date and check it out
        git archive origin/HEAD time_machine_script.sh | tar -x
        ${COMMAND} # run your command on the current state of the repo

        time_to_check=$((${time_to_check} + ${time_to_add})) # add the supplied interval to the time to check of the next run
        checkout_and_run # run again with the new time_to_check env var
    fi
}

checkout_and_run
git checkout -f master
git reset --hard # Blow away anything that doesn't exist in latest master
