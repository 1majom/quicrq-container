source 0.sh;
cd $yamldir;
kubectl delete all --all & wait;

echo "scenario 7-8-9";

kubectl apply -f 1-7-8-9-client-lb-server-lb-client/;
cd $quicrqdir;
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for end point..."; external_ip=$(kubectl get svc quicrq-server-lb --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip;'
SERVER_IP=$(kubectl get svc quicrq-server-lb --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")

sleep 5;
for id in {19..21}
do
    echo $id    
    ./quicrq_app client -p 8899 $SERVER_IP d 4433 get:videotest$id:./me_tests/test1.bin > LOGS-$where/$id-get-1.csv  & \
    ./quicrq_app client -p 8898  $SERVER_IP d 4433 get:videotest$id:./me_tests/test1.bin > LOGS-$where/$id-get-2.csv  & \
    ./quicrq_app client  -p 8897 $SERVER_IP d 4433 get:videotest$id:./me_tests/test1.bin > LOGS-$where/$id-get-3.csv  & \
    ./quicrq_app client $SERVER_IP d 4433 post:videotest$id:./tests/video1_source.bin > LOGS-$where/$id-post.csv & \
    wait;
done
cd $yamldir ;
kubectl delete all --all & wait;