
source 0.sh;
mkdir $quicrqdir/LOGS-$where/;
cd $quicrqdir/LOGS-$where/;
cp ../quicrq_eval_script.py .
rm endyendy.csv 
for i in {1..18}; do echo -n "$i :"; python3 quicrq_eval_script.py -p $i-post.csv -g $i-get.csv; done > endyendy.csv
for i in {19..21}; do for j in {1..3}; do echo -n "$i.$j: "; python3 quicrq_eval_script.py -p $i-post.csv -g $i-get-$j.csv ; done;done >> endyendy.csv