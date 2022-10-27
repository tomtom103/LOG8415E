from pyspark.sql import SparkSession

#start a spark session
session= SparkSession.builder.getOrCreate()

#Initialize the context
spark = session.sparkContext

#read the file
file = spark.textFile('pg4300.txt')

#Map
wordList = file.flatMap(lambda l: l.split(" ")).map(lambda w : (w,1))

#Reduce
count = wordList.reduceByKey(lambda w1,w2: w1+w2).collect()

#print 
for w in count :
    print(w)



