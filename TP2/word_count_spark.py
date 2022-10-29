from pyspark.sql import SparkSession
import sys
import time



time_f = open("./files/time.txt", "a")

#start a spark session
session= SparkSession.builder.getOrCreate()

#Initialize the context
spark = session.sparkContext

#read the file from the path sent from the command line
file = spark.textFile(sys.argv[1])

start_time = time.time()

#Map : emitting each word with a value of one
wordList = file.flatMap(lambda l: l.split(" ")).map(lambda w : (w,1))

#Reduce : summing the count for each word
count = wordList.reduceByKey(lambda c1,c2: c1+c2)

end_time = time.time() - start_time


#print 
result = count.collect()
for w in result :
    print(w)

time_f.write(str(end_time) + '\n')
time_f.close()



