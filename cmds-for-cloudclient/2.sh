source 0.sh;
cd $yamldir ;
kubectl delete all --all & wait;

echo "scenario 2";
kubectl apply -f 2-3-client-lb1-r1-s1-lb2-client/deploy-server.yaml;
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-server..."; external_ip=$(kubectl get pod -l app=1quicrq-server -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip'
SERVER_IP=$(kubectl get pod -l app=1quicrq-server -o jsonpath="{.items[0].status.podIP}")


kubectl apply -f 2-3-client-lb1-r1-s1-lb2-client/relay.yaml;
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-relay..."; external_ip=$(kubectl get pod -l app=quicrq-relay -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip'
RELAY_IP=$(kubectl get pod -l app=quicrq-relay -o jsonpath="{.items[0].status.podIP}")


kubectl apply -f 2-3-client-lb1-r1-s1-lb2-client/client.yaml;
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-client0..."; external_ip=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip'
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-client1..."; external_ip=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[1].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip'
RECEIVE_POD=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[0].metadata.name}")
TRANSMIT_POD=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[1].metadata.name}")
sleep 5;
cd $quicrqdir ;
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

