
source 0.sh;


mkdir $quicrqdir/LOGS-$where/;
cd $quicrqdir/LOGS-$where/;
cp ../quicrq_eval_script_v2.py .
rm endyendy.csv 
touch endyendy.csv 
for i in {1..18}; do
 echo -n "$i," >> endyendy.csv;
  if [[ -f "${i}-get.csv" ]]; then
     if [[ -f "${i}-post.csv" ]]; then
       echo "$i";
       rm tmp.csv;
       python3 quicrq_eval_script_v2.py -p $i-post.csv -g $i-get.csv -l $where -f tmp.csv;
       cat tmp.csv >> endyendy.csv;
     fi
  else
    echo  "none"
  fi
done 

for j in {1..3}; do 
  for i in {19..21}; do 

    echo -n "$i.$j," >> endyendy.csv; 
    if [[ -f "${i}-get-${j}.csv" ]]; then
      if [[ -f "${i}-post.csv" ]]; then
       rm tmp.csv;

       echo "$i $j";
       python3 quicrq_eval_script_v2.py -p $i-post.csv -g $i-get-$j.csv  -l $where -f tmp.csv;
       cat tmp.csv >> endyendy.csv;
     fi
    else
     echo  "none"
    fi
  done;
done
