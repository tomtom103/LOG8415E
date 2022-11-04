import matplotlib.pyplot as plt

def plot_data_from_file(path, app_name) :
    """
    Take the data from the file at the path and plot it

    format of the file is:
    Filename<name> time:<time>
    ...
    """
    f = open(path, 'r')
    lines = f.readlines()
    f.close()

    data = process_data(lines)

    #plotting a bar chart
    plt.rcParams["figure.figsize"] = (13,5)
    fig, ax = plt.subplots()
    bars = ax.bar(list(data.keys()),list(data.values()))
    ax.bar_label(bars)
    plt.title('Average time of the ' + app_name + ' wordcount on each input file')
    plt.savefig('../out/'+app_name+'_avg_time.png')



def process_data(lines) :
    data = {}
    #reading from the data file and putting the relevant info in data structure
    for l in lines :
        file,time = l.split(' ')
        file = file.split(':')[1]
        time = float(time.split(':')[-1].rstrip())
        if file not in data.keys() :
            data[file] = []
        data[file].append(time)

    #Reorganizing the data structure to get the average time for each file
    return dict(map(lambda kv : (kv[0],sum(kv[1])/len(kv[1])), data.items()))


def linux_vs_hadoop_plt(paths) :
    f = open(paths[0], 'r')
    lines_hadoop = f.readlines()
    f.close()

    f = open(paths[1], 'r')
    lines_linux = f.readlines()
    f.close()

    data_linux = process_data(lines_linux)
    data_hadoop = process_data(lines_hadoop)

    fig, ax = plt.subplots()
    bars = ax.bar(['Linux','Hadoop'],[data_linux['pg4300.txt'],data_hadoop['pg4300.txt']])
    ax.bar_label(bars)
    plt.title('Linux vs Hadoop average time')
    plt.savefig('../out/linux_vs_hadoop_avg_time.png')


# Plotting the data from spark and hadoop
plot_data_from_file('../out/spark.txt', 'spark')
plot_data_from_file('../out/hadoop.txt', 'hadoop')
linux_vs_hadoop_plt(['../out/hadoop_metrics.txt', '../out/linux_metrics.txt'])
