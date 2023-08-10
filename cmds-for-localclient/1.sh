source 0.sh;
cd $quicrqdir ;
mkdir LOGS-$where;
cd $yamldir ;
# kubectl delete all --all & wait;


kubectl apply -f 1-7-8-9-client-lb-server-lb-client/deploy-server.yaml;


bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for end point..."; external_ip=$(kubectl get svc quicrq-server-lb --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip;'
SERVER_IP=$(kubectl get svc quicrq-server-lb --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")


echo "frick (scenario 1)";
echo $SERVER_IP
sleep 5;
cd $quicrqdir ;
for id in {1..3}
do
  echo $id
  ./quicrq_app client $SERVER_IP d 4433 get:videotest$id:./me_tests/test1.bin > LOGS-$where/$id-get.csv  & \
  ./quicrq_app client $SERVER_IP d 4433 post:videotest$id:./tests/video1_source.bin > LOGS-$where/$id-post.csv & \
  wait;
done