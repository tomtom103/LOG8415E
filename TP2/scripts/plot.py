import matplotlib.pyplot as plt

def plot_data_from_file(path, app_name) :
    f = open(path, 'r')
    lines = f.readlines()
    f.close()

    data = {}

    #reading from the data file and putting the relevant info in data structure
    for l in lines :
        file,time = l.split(' ')
        file = file.split(':')[1]
        time = float(time.split(':')[1].rstrip())
        if file not in data.keys() :
            data[file] = []
        data[file].append(time)

    #Reorganizing the data structure to get the average time for each file
    data = dict(map(lambda kv : (kv[0],sum(kv[1])/len(kv[1])), data.items()))

    #plotting a bar chart
    plt.rcParams["figure.figsize"] = (13,5)
    fig, ax = plt.subplots()
    bars = ax.bar(list(data.keys()),list(data.values()))
    ax.bar_label(bars)
    plt.title('Average time of the ' + app_name + ' wordcount on each input file')
    plt.savefig('../out/'+app_name+'_avg_time.png')

plot_data_from_file('../out/spark.txt', 'spark')
plot_data_from_file('../out/hadoop.txt', 'hadoop')