
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
echo "NAME the samples";
sleep 3;
where="euwest-cloudclient-0808";
yamldir="/home/szebala/Documents/bme/szakgyak/quicrq/yamls/cloudclient"
quicrqdir="/home/szebala/Dev/CLionProjects/quicrq_tinkering/cmake-build-debug/"
cd $yamldir ;
kubectl delete all --all & wait;

# # find ./ -type f -exec sed -i -e 's/'$oldIP1'/'$IP1'/g' {} \;
# # find ./ -type f -exec sed -i -e 's/'$oldIP2'/'$IP2'/g' {} \;

kubectl apply -f 1-7-8-9-client-lb-server-lb-client/;
cd $quicrqdir ;
mkdir LOGS-$where;
echo "frick (scenario 1)";
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-server..."; external_ip=$(kubectl get pod -l app=quicrq-server -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip'
SERVER_IP=$(kubectl get pod -l app=quicrq-server -o jsonpath="{.items[0].status.podIP}")
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-client0..."; external_ip=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip'
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-client1..."; external_ip=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[1].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip'
RECEIVE_POD=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[0].metadata.name}")
TRANSMIT_POD=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[1].metadata.name}")
echo $RECEIVE_POD
echo $TRANSMIT_POD
echo $SERVER_IP
sleep 5;
for id in {1..3}
do
  echo $id
  kubectl exec -t $RECEIVE_POD -- ./quicrq_app client $SERVER_IP d 4433 get:videotest$id:/video1_source.bin > LOGS-$where/$id-get.csv & \
  kubectl exec -t $TRANSMIT_POD -- ./quicrq_app client $SERVER_IP d 4433 post:videotest$id:./tests/video1_source.bin > LOGS-$where/$id-post.csv & \
  wait;
done
cd $yamldir ;
kubectl delete all --all & wait;

echo "scenario 2";
kubectl delete all --all & wait;

kubectl apply -f 2-3-client-lb1-r1-s1-lb2-client/;
cd $quicrqdir ;
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-server..."; external_ip=$(kubectl get pod -l app=quicrq-server -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip'
SERVER_IP=$(kubectl get pod -l app=quicrq-server -o jsonpath="{.items[0].status.podIP}")
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-relay..."; external_ip=$(kubectl get pod -l app=quicrq-relay -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip'
RELAY_IP=$(kubectl get pod -l app=quicrq-relay -o jsonpath="{.items[0].status.podIP}")
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-client0..."; external_ip=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip'
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-client1..."; external_ip=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[1].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip'
RECEIVE_POD=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[0].metadata.name}")
TRANSMIT_POD=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[1].metadata.name}")
sleep 5;
for id in {4..6}
do
  echo $id
  kubectl exec -t $RECEIVE_POD -- ./quicrq_app client $SERVER_IP d 4433 get:videotest$id:/video1_source.bin > LOGS-$where/$id-get.csv & \
  kubectl exec -t $TRANSMIT_POD -- ./quicrq_app client $RELAY_IP d 30900 post:videotest$id:./tests/video1_source.bin > LOGS-$where/$id-post.csv & \
  wait;
done
echo "scenario 3";
# 3 sc
for id in {7..9}
do
  echo $id  
  kubectl exec -t $RECEIVE_POD -- ./quicrq_app client $RELAY_IP d 30900 get:videotest$id:/video1_source.bin > LOGS-$where/$id-get.csv & \
  kubectl exec -t $TRANSMIT_POD -- ./quicrq_app client $SERVER_IP d 4433 post:videotest$id:./tests/video1_source.bin > LOGS-$where/$id-post.csv & \
  wait;
done


cd $yamldir ;
kubectl delete all --all & wait;

echo "scenario 4";
kubectl apply -f 4-client-lb-relay-server-relay-lb-client/;
cd $quicrqdir ;
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-relay..."; external_ip=$(kubectl get pod -l app=quicrq-relay -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip'
RELAY_IP=$(kubectl get pod -l app=quicrq-relay -o jsonpath="{.items[0].status.podIP}")
RECEIVE_POD=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[0].metadata.name}")
TRANSMIT_POD=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[1].metadata.name}")
sleep 5;
for id in {10..12}
do
  echo $id  
  kubectl exec -t $RECEIVE_POD -- ./quicrq_app client $RELAY_IP d 30900 get:videotest$id:/video1_source.bin > LOGS-$where/$id-get.csv & \
  kubectl exec -t $TRANSMIT_POD -- ./quicrq_app client $RELAY_IP d 30900 post:videotest$id:./tests/video1_source.bin > LOGS-$where/$id-post.csv & \
  wait;
done

cd $yamldir ;
kubectl delete all --all & wait;

echo "scenario 5";

kubectl apply -f 5-c-lb1-r1-s-r2-lb2-c/;
cd $quicrqdir;
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-server..."; external_ip=$(kubectl get pod -l app=1quicrq-server -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip';
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-relay..."; external_ip=$(kubectl get pod -l app=quicrq-relay -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip';
RELAY_IP=$(kubectl get pod -l app=quicrq-relay -o jsonpath="{.items[0].status.podIP}");
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-relay-in..."; external_ip=$(kubectl get pod -l app=quicrq-relay-in -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip'
RELAY_IP_IN=$(kubectl get pod -l app=quicrq-relay-in -o jsonpath="{.items[0].status.podIP}");
RECEIVE_POD=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[0].metadata.name}");
TRANSMIT_POD=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[1].metadata.name}");
sleep 5;
for id in {13..15}
do
  echo $id  
  kubectl exec -t $RECEIVE_POD -- ./quicrq_app client $RELAY_IP d 30900 get:videotest$id:/video1_source.bin > LOGS-$where/$id-get.csv & \
  kubectl exec -t $TRANSMIT_POD -- ./quicrq_app client $RELAY_IP_IN d 30901 post:videotest$id:./tests/video1_source.bin > LOGS-$where/$id-post.csv & \
  wait;
done

cd $yamldir;
kubectl delete all --all & wait;

echo "scenario 6";

kubectl apply -f 6-c-lb1-r1-s-r2-r3-lb2-c/;
cd $quicrqdir;

bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-server..."; external_ip=$(kubectl get pod -l app=quicrq-server -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip';
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-relay-between..."; external_ip=$(kubectl get pod -l app=quicrq-relay-between -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip';
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-relay-out..."; external_ip=$(kubectl get pod -l app=quicrq-relay-out -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip';
RELAY_IP_OUT=$(kubectl get pod -l app=quicrq-relay-out -o jsonpath="{.items[0].status.podIP}");
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-relay-in..."; external_ip=$(kubectl get pod -l app=quicrq-relay-in -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip';
RELAY_IP_IN=$(kubectl get pod -l app=quicrq-relay-in -o jsonpath="{.items[0].status.podIP}");
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-relay-in..."; external_ip=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip';
RECEIVE_POD=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[0].metadata.name}");
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-relay-in..."; external_ip=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[1].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip';
TRANSMIT_POD=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[1].metadata.name}");
sleep 5;
for id in {16..18}
do
  echo $id  
  kubectl exec -t $RECEIVE_POD -- ./quicrq_app client $RELAY_IP_OUT d 30902 get:videotest$id:/video1_source.bin > LOGS-$where/$id-get.csv & \
  kubectl exec -t $TRANSMIT_POD -- ./quicrq_app client $RELAY_IP_IN d 30901 post:videotest$id:./tests/video1_source.bin > LOGS-$where/$id-post.csv & \
  wait;
done

cd $yamldir;
kubectl delete all --all & wait;

echo "scenario 7-8-9";

kubectl apply -f 1-7-8-9-client-lb-server-lb-client/;
cd $quicrqdir;
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-server..."; external_ip=$(kubectl get pod -l app=quicrq-server -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip';
SERVER_IP=$(kubectl get pod -l app=quicrq-server -o jsonpath="{.items[0].status.podIP}");
TRANSMIT_POD=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[0].metadata.name}");
RECEIVE_POD1=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[1].metadata.name}");
RECEIVE_POD2=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[2].metadata.name}");
RECEIVE_POD3=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[3].metadata.name}");
sleep 5;
for id in {19..21}
do
    echo $id    
    kubectl exec -t $RECEIVE_POD1 -- ./quicrq_app client $SERVER_IP d 4433 get:videotest$id:/video1_source.bin > LOGS-$where/$id-get-1.csv  & \
    kubectl exec -t $RECEIVE_POD1 -- ./quicrq_app client $SERVER_IP d 4433 get:videotest$id:/video1_source.bin > LOGS-$where/$id-get-2.csv  & \
    kubectl exec -t $RECEIVE_POD1 -- ./quicrq_app client $SERVER_IP d 4433 get:videotest$id:/video1_source.bin > LOGS-$where/$id-get-3.csv  & \
    kubectl exec -t $TRANSMIT_POD -- ./quicrq_app client $SERVER_IP d 4433 post:videotest$id:./tests/video1_source.bin > LOGS-$where/$id-post.csv & \
    wait;
done
cd $yamldir ;
kubectl delete all --all & wait;
cd $quicrqdir/LOGS-$where/;
cp ../quicrq_eval_script.py .
for i in {1..18}; do echo -n "$i :"; python3 quicrq_eval_script.py -p $i-post.csv -g $i-get.csv >> endyendy.csv; done >> endyendy.csv
for i in {19..21}; do for j in {1..3}; do echo -n "$i.$j: "; python3 quicrq_eval_script.py -p $i-post.csv -g $i-get-$j.csv ; done;done >> endyendy.csv

