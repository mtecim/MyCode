#!/usr/bin/bash

declare -a marks
declare -a lastlogfiles
for i in {1..3}; do
   marks[$i]=1
   lastlogfiles[$i]=`ls -alrt /data/workspaces/mtecim/elasticsearch_$i/example_log_file.log | tail -1 | awk {'print $NF'}`
done

restart_es() {
  for i in {1..3}
  do
    lastlogfile=`ls -alrt /data/workspaces/mtecim/elasticsearch_$i/example_log_file.log | tail -1 | awk {'print $NF'}`
    mark=${marks[$i]}
    #echo "Fetched mark = $mark"
    #if [ lastlogfile is not equal to lastlogfiles[i]
    if [ $lastlogfile != ${lastlogfiles[$i]} ]; then
      mark=1
    fi
   

    lc=`wc -l $lastlogfile | awk {'print $1'}`;
    num_gc=`sed -n $mark,$lc"p" $lastlogfile | grep -ine "\[2...gb\]->\[....gb\]\/\[32gb\]" | wc -l`
    # If number of gc is bigger than specified (e.g: 10) number, restart es service.
    if [ $num_gc -gt 10 ]; then
        echo $num_gc " is greater then 10, restarting..." 
        #systemctl restart elasticsearch_$i.service
        #echo 'elasticsearch_'$i'.service is RESTARTED'
            # After restart
        mark=`sed -n $mark,$lc"p" $lastlogfile | grep -ine "\[2...gb\]->\[....gb\]\/\[32gb\]" | tail -1 | awk -F ':' {'print $1'}`
        mark=$(( mark+1 ))
        #echo "mark = $mark"
        marks[$i]=$mark
        #echo "$i th mark is updated as ${marks[$i]}.." 
    else
        #echo 'not detected '
    fi
  done
}

while true
  do
    # Every 20 minutes run procedure
    restart_es
    sleep 1200
  done
