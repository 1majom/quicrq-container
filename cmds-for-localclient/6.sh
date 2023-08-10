source 0.sh;
cd $yamldir;
kubectl delete all --all & wait;

echo "scenario 6";

kubectl apply -f 6-c-lb1-r1-s-r2-r3-lb2-c/stateful-server.yaml;

bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-server..."; external_ip=$(kubectl get pod -l app=quicrq-server -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip';


kubectl apply -f 6-c-lb1-r1-s-r2-r3-lb2-c/

bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for quicrq-relay-between..."; external_ip=$(kubectl get pod -l app=quicrq-relay-between -o jsonpath="{.items[0].status.podIP}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip';

bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for end point..."; external_ip=$(kubectl get svc quicrq-relay-out-lb --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip;'
RELAY_IP_OUT=$(kubectl get svc quicrq-relay-out-lb --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")

bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for end point..."; external_ip=$(kubectl get svc quicrq-relay-in-lb --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip;'
RELAY_IP_IN=$(kubectl get svc quicrq-relay-in-lb --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")

cd $quicrqdir;

sleep 5;
for id in {16..18}
do
  echo $id  
  ./quicrq_app client $RELAY_IP_OUT d 30902  get:videotest$id:./me_tests/test1.bin > LOGS-$where/$id-get.csv & \
  ./quicrq_app client $RELAY_IP_IN d 30901 post:videotest$id:./tests/video1_source.bin > LOGS-$where/$id-post.csv & \
  wait;
done
