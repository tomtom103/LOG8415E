from pyspark.sql import SparkSession
import sys
import time

path = sys.argv[1]
input_file_name = path.split('/')[-1]
time_f = open("../files/time.txt", "a")

#start a spark session
session = SparkSession.builder.getOrCreate()

#Initialize the context
spark = session.sparkContext

start_time = time.time()

#read the file from the path sent from the command line
file = spark.textFile(path)

#Map : emitting each word with a value of one
wordList = file.flatMap(lambda l: l.split(" ")).map(lambda w : (w,1))

#Reduce : summing the count for each word
count = wordList.reduceByKey(lambda c1,c2: c1+c2)

end_time = time.time() - start_time

#print the words with their count in output file
output_file = open('../files/output/' + input_file_name.split('.')[0] + '_output_spark.txt', 'w')
result = count.collect()
for w in result :
    output_file.write(str(w) + '\n')

#writing the map reduce execution time in data file
time_f.write('Filename:' + input_file_name + " time:" + str(end_time) + '\n')

print(end_time)
output_file.close()
time_f.close()


