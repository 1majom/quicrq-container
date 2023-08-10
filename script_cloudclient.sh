
function terminate_sleep() {
  echo "Sleep skipped!"
  # Terminate the sleep process by killing the subshell
  kill $!
}
function countdown(){
  countdown_duration=20

  echo "Starting countdown for $countdown_duration seconds..."
  (sleep $countdown_duration; echo -e "\nCountdown completed.") &

  # Disable terminal input buffering to detect keystrokes immediately
  stty -icanon

  for ((i = countdown_duration; i >= 0; i--)); do
    echo -ne "Time left: $i seconds\r"

    # Check if the "x" key is pressed
    read -t 0.1 -n 1 input
    if [[ $input == "x" ]]; then
      terminate_sleep
      break
    fi
    sleep 1
  done

  # Enable terminal input buffering again
  stty icanon
}

cd $quicrqdir/LOGS-$where/;
cp ../quicrq_eval_script.py .
for i in {1..18}; do echo -n "$i :"; python3 quicrq_eval_script.py -p $i-post.csv -g $i-get.csv; done > endyendy.csv
for i in {19..21}; do for j in {1..3}; do echo -n "$i.$j: "; python3 quicrq_eval_script.py -p $i-post.csv -g $i-get-$j.csv ; done;done >> endyendy.csv

