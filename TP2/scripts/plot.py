import matplotlib.pyplot as plt

f = open('../files/time.txt', 'r')
lines = f.readlines()
f.close()

data = {}

for l in lines :
    file,time = l.split(' ')
    file = file.split(':')[1]
    time = float(time.split(':')[1].rstrip())
    if file not in data.keys() :
        data[file] = []
    data[file].append(time)

data = dict(map(lambda kv : (kv[0],sum(kv[1])/len(kv[1])), data.items()))

plt.rcParams["figure.figsize"] = (13,5)
fig, ax = plt.subplots()
bars = ax.bar(list(data.keys()),list(data.values()))
ax.bar_label(bars)
plt.title('Average time of the spark wordcount on each input file')
plt.savefig('../metrics/spark_avg_time.png')