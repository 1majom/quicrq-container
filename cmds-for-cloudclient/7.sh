source 0.sh;
cd $yamldir;
kubectl delete all --all & wait;

echo "scenario 7-8-9";

kubectl apply -f 1-7-8-9-client-lb-server-lb-client/;
cd $quicrqdir;
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-server..."; external_ip=$(kubectl get pod -l app=1quicrq-server -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip';
SERVER_IP=$(kubectl get pod -l app=1quicrq-server -o jsonpath="{.items[0].status.podIP}");
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-client..."; external_ip=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip';
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-client..."; external_ip=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[1].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip';
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-client..."; external_ip=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[2].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip';
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-client..."; external_ip=$(kubectl get pod -l app=quicrq-client -o jsonpath="{.items[3].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip';
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