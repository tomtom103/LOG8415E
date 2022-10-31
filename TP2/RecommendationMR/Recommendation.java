import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.GenericOptionsParser;

import java.io.IOException;
import java.util.Arrays;
import java.util.Comparator;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.HashMap;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;

public class Recommendation {
    
    public static class RecommendationMapper extends Mapper<LongWritable, Text, Text, Text> {
        Text userId = new Text();
        Text friendsList = new Text();

        /*
        Map function that produce the mapping of the relations between the users.
        */
        public void map(LongWritable key, Text value, Context context)
                throws IOException, InterruptedException {
            
            // Splitting line between userId and friend list (split[0] is the userId and split[1] is his friends list)
            String[] line = value.toString().split("\\t");
            String userId = line[0];
            this.userId.set(userId);
            
            // Emit the current friends of the user with an indicator or when the user doesn't have a friend
            // The indicator /EN 
            if (line.length == 1) {
                // This case handles when the user doesn't have a friend
                friendsList.set("/CURRENT");
                context.write(this.userId, this.friendsList);
                return;
            } else {
                friendsList.set(line[1] + "/CURRENT");
                context.write(this.userId, this.friendsList);
            }

            String[] friendsIdList = line[1].split(",");
            
            // for each friends, emit potential mutual friend
            for (String friend : friendsIdList) {
                String friendsInCommon = Arrays.stream(friendsIdList).filter(compFr -> !compFr.equals(friend)).collect(Collectors.joining(","));
                this.friendsList.set(friendsInCommon + "/POTMUTFRIEND");
                this.userId.set(friend);
                context.write(this.userId, this.friendsList);
            }
        }
    }

    /*
    Reduce function that groups all recommendations by users
    */
    public static class RecommendationReducer extends Reducer<Text, Text, Text, Text> {

            public void reduce(Text key, Iterable<Text> values, Context context) 
                throws IOException, InterruptedException {
                    
                HashMap<String, Integer> recommendations = new HashMap<String, Integer>();
                String[] currentFriends = {};

                // Populate dict (key is userId, value are the mutual friend they have with them)
                for (Text value : values) {
                    String[] line = value.toString().split("/");
                    String[] friends = line[0].split(",");

                    if(friends.length > 1 || !friends[0].equals("")){
                        if (line[1].equals("CURRENT")) {
                            currentFriends = friends;
                        } else {
                            for (String friend : friends) {
                                recommendations.put(friend, recommendations.getOrDefault(friend, 0) + 1);
                            }
                        }
                    } else {
                        continue;
                    }
                }
                
                // Remove own friends for the user
                recommendations.remove("");
                for (String friend : currentFriends) {
                    recommendations.remove(friend);
                }

                context.write(key, new Text(getTop10Recommendations(recommendations)));
        }
    }

    /*
    This function trim the list of recommendations to get only the top 10 recommendations and sort
    the list in a decreasing order.AbstractMap
     */
    public static String getTop10Recommendations(HashMap<String, Integer> recommendations) {
        Comparator<Map.Entry<String, Integer>> sortLogic = ((a, b) -> b.getValue().compareTo(a.getValue()));
        sortLogic = sortLogic.thenComparing(a -> a.getKey());
        return recommendations.entrySet()
                .stream()
                .sorted(sortLogic)
                .limit(10)
                .map(Map.Entry::getKey)
                .collect(Collectors.joining(","));
    }

    public static void main(String[] args) throws Exception {
        Configuration config = new Configuration();
        String[] pathArgs = new GenericOptionsParser(config, args).getRemainingArgs();
        
        if (pathArgs.length < 2) {
            System.err.println("MR Project Usage : recommendation <input-path> {...] <output_path>");
            System.exit(2);
        }

        Job recJob = Job.getInstance(config, "MapReduce Friends Recommendation");
        recJob.setJarByClass(Recommendation.class);
        recJob.setMapperClass(RecommendationMapper.class);
        recJob.setReducerClass(RecommendationReducer.class);
        recJob.setOutputKeyClass(Text.class);
        recJob.setOutputValueClass(Text.class);

        for(int i = 0; i< pathArgs.length-1; ++i) {
            FileInputFormat.addInputPath(recJob, new Path(pathArgs[i]));
        }

        FileOutputFormat.setOutputPath(recJob, new Path(pathArgs[pathArgs.length-1]));

        System.exit(recJob.waitForCompletion(true) ? 0 : 1);
    }
}