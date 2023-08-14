
source 0.sh;

# cd $yamldir;

# if [ -z "$1" ]; then
#     kubectl config use-context $clusterA;
#     kubectl delete all --all & wait;
#     kubectl config use-context $clusterB;
#     kubectl delete all --all & wait;
# fi

# kubectl config use-context $clusterA;
# kubectl apply -f ../debug/ultraping.yaml
# bash -c 'external_ip=""; while [ -z $external_ip ]; do echo "Waiting for end point..."; external_ip=$(kubectl get svc ultraping-server-lb-u --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready" && echo $external_ip;'
# SERVER_IP=$(kubectl get svc ultraping-server-lb-u --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
# kubectl config use-context $clusterB;






mkdir $quicrqdir/LOGS-$where/;
cd $quicrqdir/LOGS-$where/;
cp ../quicrq_eval_script.py .
rm endyendy.csv 
touch endyendy.csv 
for i in {1..18}; do
 echo -n "$i :" >> endyendy.csv;
  if [[ -f "${i}-get.csv" ]]; then
    # Process "${i}-get.csv" here
    # echo "Processing ${i}-get.csv"
     if [[ -f "${i}-post.csv" ]]; then
       # Process "${i}-post.csv" here
       echo $i;
       python3 quicrq_eval_script.py -p $i-post.csv -g $i-get.csv >> endyendy.csv;
     fi
  else
    # echo "File ${i}-get.csv not found, skipping..."
    echo  "none"
  fi
done 


for i in {19..21}; do 
  for j in {1..3}; do 
    echo -n "$i.$j: " >> endyendy.csv; 
    if [[ -f "${i}-get-${j}.csv" ]]; then
      # Process "${i}-get.csv" here
      # echo "Processing ${i}-get.csv"
      if [[ -f "${i}-post.csv" ]]; then
       # Process "${i}-post.csv" here
       echo "$i $j";
       python3 quicrq_eval_script.py -p $i-post.csv -g $i-get-$j.csv  >> endyendy.csv;
     fi
    else
     # echo "File ${i}-get.csv not found, skipping..."
     echo  "none"
    fi
  done;
done