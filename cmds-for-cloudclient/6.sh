source 0.sh;
cd $yamldir;
kubectl delete all --all & wait;

echo "scenario 6";

kubectl apply -f 6-c-lb1-r1-s-r2-r3-lb2-c/;

bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-server..."; external_ip=$(kubectl get pod -l app=1quicrq-server -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip';
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-relay-between..."; external_ip=$(kubectl get pod -l app=quicrq-relay-between -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip';
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-relay-out..."; external_ip=$(kubectl get pod -l app=quicrq-relay-out -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip';
RELAY_IP_OUT=$(kubectl get pod -l app=quicrq-relay-out -o jsonpath="{.items[0].status.podIP}");
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-relay-in..."; external_ip=$(kubectl get pod -l app=quicrq-relay-in -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip';
RELAY_IP_IN=$(kubectl get pod -l app=quicrq-relay-in -o jsonpath="{.items[0].status.podIP}");
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-relay-in..."; external_ip=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip';
RECEIVE_POD=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[0].metadata.name}");
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-relay-in..."; external_ip=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[1].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip';
TRANSMIT_POD=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[1].metadata.name}");
cd $quicrqdir;

sleep 5;
for id in {16..18}
do
  echo $id  
  kubectl exec -t $RECEIVE_POD -- ./quicrq_app client $RELAY_IP_OUT d 30902 get:videotest$id:/video1_source.bin > LOGS-$where/$id-get.csv & \
  kubectl exec -t $TRANSMIT_POD -- ./quicrq_app client $RELAY_IP_IN d 30901 post:videotest$id:./tests/video1_source.bin > LOGS-$where/$id-post.csv & \
  wait;
done
