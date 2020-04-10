import os
import glob
import time

marks =[1,1,1,1]
lastlogfiles= ["","","",""]

for i in range (1,4):
    marks[i]=1
    list_of_files = glob.glob('/data/workspaces/mtecim/elasticsearch_'+str(i)+'/example_log_file.log*')  # * means all if need specific format then *.csv
    latest_file = max(list_of_files, key=os.path.getctime)
    lastlogfiles[i]=latest_file


def restart_es():
    for i in range (1,4):
        list_of_files = glob.glob('/data/workspaces/mtecim/elasticsearch_' + str(
            i) + '/example_log_file.log*')  # * means all if need specific format then *.csv
        lastlogfile = max(list_of_files, key=os.path.getctime)
        mark=marks[i]

        if lastlogfile != lastlogfiles[i]:
            mark = 1

        count = 0
        num_gc = 0
        lookup ="gb]->[2"

        with open(lastlogfile, 'r') as f:
            data = f.readlines()
            for line in data:
                count += 1
            print(count)

            for k in range(mark, count):
                checking_data = data[k]
                if checking_data.find(lookup) != (-1):
                    num_gc += 1
                    x=k
            print("num_gc=" +str(num_gc))

        if num_gc>10:
            print(str(num_gc) + " is greater then 10, restarting..." )
            # os.system('systemctl restart elasticsearch_'+i+'.service')
            mark=x
            mark=mark+1
            marks[i]=mark
            print(marks)
        else:
            print ("not detected ")

while True:
    restart_es()
    time.sleep(60)





