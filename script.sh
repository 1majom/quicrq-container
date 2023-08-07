
function terminate_sleep() {
  echo "Sleep skipped!"
  # Terminate the sleep process by killing the subshell
  kill $!
}
function countdown(){
  countdown_duration=180

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

source secret_variables.sh
countdown
cd $yamldir ;
kubectl delete all --all & wait;

find ./ -type f -exec sed -i -e 's/'$oldIP1'/'$IP1'/g' {} \;
find ./ -type f -exec sed -i -e 's/'$oldIP2'/'$IP2'/g' {} \;
echo "1";
kubectl apply -f 1-7-8-9-client-lb-server-lb-client/;
cd $quicrqdir ;
mkdir LOGS-$where;
echo "frick (scenario 1)";
countdown
for id in {1..3}
do
  echo $id
  ./quicrq_app client $IP1 d 4433 get:videotest$id:./me_tests/test1.bin > LOGS-$where/$id-get.csv  & \
  ./quicrq_app client $IP1 d 4433 post:videotest$id:../tests/video1_source.bin > LOGS-$where/$id-post.csv & \
  wait;
done
cd $yamldir ;
kubectl delete all --all & wait;

echo "scenario 2";
kubectl apply -f 2-3-client-lb1-r1-s1-lb2-client/;
cd $quicrqdir ;
countdown
for id in {4..6}
do
  echo $id  
  ./quicrq_app client $IP1 d 4433 get:videotest$id:./me_tests/test1.bin > LOGS-$where/$id-get.csv & \
  ./quicrq_app client $IP2 d 30900 post:videotest$id:../tests/video1_source.bin > LOGS-$where/$id-post.csv & \
  wait;
done
echo "scenario 3";
# 3 sc
for id in {7..9}
do
  echo $id  
  ./quicrq_app client $IP1 d 4433 post:videotest$id:../tests/video1_source.bin > LOGS-$where/$id-post.csv & \
  ./quicrq_app client $IP2 d 30900 get:videotest$id:./me_tests/test1.bin > LOGS-$where/$id-get.csv & \
  wait;
done


cd $yamldir ;
kubectl delete all --all & wait;

echo "scenario 4";
kubectl apply -f 4-client-lb-relay-server-relay-lb-client/;
cd $quicrqdir ;
countdown;
for id in {10..12}
do
  echo $id  
  ./quicrq_app client $IP1 d 30900 get:videotest$id:./me_tests/test1.bin > LOGS-$where/$id-get.csv & \
  ./quicrq_app client $IP1 d 30900 post:videotest$id:../tests/video1_source.bin > LOGS-$where/$id-post.csv & \
  wait;
done

cd $yamldir ;
kubectl delete all --all & wait;

echo "scenario 5";

kubectl apply -f 5-c-lb1-r1-s-r2-lb2-c/;
cd $quicrqdir ;
countdown;
for id in {13..15}
do
  echo $id  
  ./quicrq_app client $IP2 d 30900 get:videotest$id:./me_tests/test1.bin > LOGS-$where/$id-get.csv &
  ./quicrq_app client $IP1 d 30901 post:videotest$id:../tests/video1_source.bin > LOGS-$where/$id-post.csv & \
  wait;
done

cd $yamldir ;
kubectl delete all --all & wait;

echo "scenario 6";

kubectl apply -f 6-c-lb1-r1-s-r2-r3-lb2-c/;
cd $quicrqdir ;
countdown;
for id in {16..18}
do
  echo $id  
  ./quicrq_app client $IP2 d 30902  get:videotest$id:./me_tests/test1.bin > LOGS-$where/$id-get.csv & \
  ./quicrq_app client $IP1 d 30901 post:videotest$id:../tests/video1_source.bin > LOGS-$where/$id-post.csv & \
  wait;
done

cd $yamldir ;
kubectl delete all --all & wait;

echo "scenario 7-8-9";

kubectl apply -f 1-7-8-9-client-lb-server-lb-client/;
cd $quicrqdir;
countdown;
for id in {19..21}
do
    echo $id    
    ./quicrq_app client -p 8899 $IP1 d 4433 get:videotest$id:./me_tests/test1.bin > LOGS-$where/$id-get-1.csv  & \
    ./quicrq_app client -p 8898  $IP1 d 4433 get:videotest$id:./me_tests/test1.bin > LOGS-$where/$id-get-2.csv  & \
    ./quicrq_app client  -p 8897 $IP1 d 4433 get:videotest$id:./me_tests/test1.bin > LOGS-$where/$id-get-3.csv  & \
    ./quicrq_app client $IP1 d 4433 post:videotest$id:../tests/video1_source.bin > LOGS-$where/$id-post.csv & \
    wait;
done
cd $yamldir ;
kubectl delete all --all & wait;
cd $quicrqdir/LOGS-$where/;
cp ../quicrq_eval_script.py .
for i in {1..18}; do echo -n "$i :"; python3 quicrq_eval_script.py -p $i-post.csv -g $i-get.csv; done
for i in {19..21}; do for j in {1..3}; do echo -n "$i.$j: "; python3 quicrq_eval_script.py -p $i-post.csv -g $i-get-$j.csv; done;done

