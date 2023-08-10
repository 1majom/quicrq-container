
source 0.sh;
mkdir $quicrqdir/LOGS-$where/;
cd $quicrqdir/LOGS-$where/;
cp ../quicrq_eval_script.py .
rm endyendy.csv 
for i in {1..18}; do echo -n "$i :"; python3 quicrq_eval_script.py -p $i-post.csv -g $i-get.csv; done > endyendy.csv
for i in {19..21}; do for j in {1..3}; do echo -n "$i.$j: "; python3 quicrq_eval_script.py -p $i-post.csv -g $i-get-$j.csv ; done;done >> endyendy.csv
cd $yamldir
kubectl apply -f ../debug/ultraping.yaml 

bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for end point..."; external_ip=$(kubectl get svc ultraping-server-lb-u --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip;'
SERVER_IP=$(kubectl get svc ultraping-server-lb-u --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
cd $quicrqdir
cd ../..
cd ultra_ping
python3 echo.py --client $SERVER_IP --output_filename logs/$where
awk -F' ' '{sum+=$2; ++n} END { print "Avg: "sum"/"n"="sum/n }' < logs/$where 

kubectl apply -f $yamldir/debug/net-debug.yaml 
cd $quicrqdir
bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for end point..."; external_ip=$(kubectl get svc net-debug-lb-u --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip;'
SERVER_IP=$(kubectl get svc net-debug-lb-u --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
iperf -c $SERVER_IP  -i 1 -u -b 80000 -l 100