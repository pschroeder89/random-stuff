#!/usr/bin/env bash

# USAGE: Run this script to get historical data from a repo. It traverses through a git repo's state at a set interval
# and runs your script on that date's master branch version
# Put this script in the root of your repo and run it in terminal via: `COMMAND=path/to/command INTERVAL=week sh time_machine_script.sh`

# MAC ONLY: THIS SCRIPT WON"T WORK IN LINUX DUE TO DATE COMMANDS, FEEL FREE TO ADD LINUX CONDITIONALS

echo "Checking out master latest"
git pull
git checkout master

echo "Determining first commit epoch time"
time_to_check=$(git log origin/master --pretty=format:'%at' | tail -1)
echo "Determining current epoch time"
time_now=$(date +%s)

DAY=86400
WEEK=604800
YEAR=31557600

case ${INTERVAL} in
'day')
  time_to_add=${DAY}
  ;;
'week')
  time_to_add=${WEEK}
  ;;
'year')
  time_to_add=${YEAR}
  ;;
esac

checkout_and_run() {
    if [[ ${time_to_check} -le ${time_now} ]]; then
        find . ! -name 'time_machine_script.sh' -type f -exec rm -f {} + # Delete the repo except this script, so each checkout has a clean slate
        git_result=$(git checkout -f $(git rev-list -n 1 --before=${time_to_check} origin/master) 2> /dev/null) # get the commit previous to the checkout date and check it out
        if [[ ${git_result} != *"warning:"* ]]; then # warning indicates git log for master didn't yet exist at current time, so skip running your command
            ${COMMAND} # run your command on the current state of the repo
        else
            echo "Log for master branch didn't yet exist, skipping ${time_to_check}"
        fi

        time_to_check=$((${time_to_check} + ${time_to_add})) # add the supplied interval to the time to check of the next run
        checkout_and_run # run again with the new time_to_check env var
    fi
}

checkout_and_run
git checkout master
git reset --hard # Blow away anything that doesn't exist in latest master
