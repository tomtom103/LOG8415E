import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.GenericOptionsParser;

import java.io.IOException;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.LinkedHashMap;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.io.Text;

import java.io.DataInput;
import java.io.DataOutput;
import org.apache.hadoop.io.Writable;

import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.io.Text;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

public class Recommendation {
    public static class RecommendationMapper extends Mapper<IntWritable, Integer, IntWritable, RecommendationWritable> {

        /*
        * Map function where we will find all the relations between the users. 
        */
        public void map(IntWritable user, Text value, Context context) throws IOException, InterruptedException{
            if(value.toString() != null) {
                String line[] = value.toString().split("\t");
                try {
                    Integer userId = Integer.parseInt(line[0]);
                    String friends[] = line[1].split(",");
                    List<Integer> friendsId = new ArrayList<Integer>(); 
    
                    if(friends.length > 0) {
                        for (String friend : friends) {
                            int friendId = Integer.parseInt(friend);
                            friendsId.add(friendId);
    
                            // We put -1 to indicate that they are already friends
                            context.write(new IntWritable(userId), new RecommendationWritable(friendId, -1));
                        }
                        // For each combination of friends, creates a writable
                        for (Integer friendId1 : friendsId) {
                            for (Integer friendId2 : friendsId) {
                                if (friendId1 == friendId2) continue;
                                context.write(new IntWritable(friendId1),
                                        new RecommendationWritable((friendId2), userId));
                            }
                        }
                    }   
                } catch(Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public static class RecommendationReducer extends Reducer<IntWritable, RecommendationWritable, IntWritable, Text> {

        /*
         * Reduce function where for the users the top 10 recommendations
         */
        public void reduce(IntWritable key, Iterable<RecommendationWritable> values, Context context) 
            throws IOException, InterruptedException {
            
            Map<Integer, List<Integer>> mutualFriends = new HashMap<Integer, List<Integer>>();
    
            for(RecommendationWritable rec : values) {
                final Integer friendId = rec.user;
                final Integer mutualFriend = rec.mutualFriend;
                
                if(mutualFriend == -1){
                    mutualFriends.put(friendId, null);
                } else {
                    if(mutualFriends.containsKey(friendId)) {
                        if(mutualFriends.get(friendId) != null) {
                            mutualFriends.get(friendId).add(mutualFriend);
                        }
                    } else {
                        mutualFriends.put(friendId, new ArrayList<Integer>() {{ add(mutualFriend); }});
                    }
                }
            }
    
            Map<Integer, List<Integer>> sortedFriends = decreasingMutualFriendsResult(mutualFriends);
    
            Integer counter = 0;
            StringBuilder output = new StringBuilder();
            for (Map.Entry<Integer, List<Integer>> entry : sortedFriends.entrySet()) {
                if (counter == 10) break;
                
                if (entry.getValue() != null) {
                    output.append(entry.getKey().toString() + " (" + entry.getValue() + ")");
                } else {
                    break;
                }
                output.append(",");
                counter++;
            }
            String outputStr = output.toString();
            
            if (outputStr.endsWith(",")) {
                outputStr = outputStr.substring(0, output.length() - 1);
            }
            
            context.write(key, new Text(outputStr));
        }
    
        /*
         * Sort the friends recommendation in decreasing, from the user with the most mutual friends to less mutual friends
         */
        public Map<Integer, List<Integer>> decreasingMutualFriendsResult(Map<Integer, List<Integer>> mutualFriends) {
            List<Map.Entry<Integer, List<Integer>> > mutualFriendsEntrySet = new ArrayList<Map.Entry<Integer, List<Integer>> >(mutualFriends.entrySet());
            
            /* If set1 has a larger mutual friends list than set2, set1 is before set2
             * If both lists are equals in size and set1's key is smaller, set1 is before set2
             * Otherwise, set2 is before set1
             */
            mutualFriendsEntrySet.sort(
                (Map.Entry<Integer, List<Integer>> set1, Map.Entry<Integer, List<Integer>> set2) -> {
                    Integer key1 = set1.getKey();
                    Integer key2 = set1.getKey();
                    Integer friendsListSize1 = (set1.getValue() != null)? 0 : set1.getValue().size();
                    Integer friendsListSize2 = (set1.getValue() != null)? 0 : set1.getValue().size();
                    if(friendsListSize1>friendsListSize2 || (friendsListSize1.equals(friendsListSize2) && key1 < key2)) {
                        return -1;
                    } else {
                        return 1;
                    }
                }
            );
    
            // LinkedHashMap filled with the sorted result
            Map<Integer, List<Integer>> sortedMutFr = new LinkedHashMap<Integer, List<Integer>>();
            for(Map.Entry<Integer, List<Integer>> sortedEntries : mutualFriendsEntrySet) {
                sortedMutFr.put(sortedEntries.getKey(), sortedEntries.getValue());
            }
    
            return sortedMutFr;
        }
    }

    public static class RecommendationWritable implements Writable {
        public Integer user;
        public Integer mutualFriend;
    
        public RecommendationWritable(Integer user, Integer mutualFriend) {
            this.user = user;
            this.mutualFriend = mutualFriend;
        }
    
        public RecommendationWritable() {
            this(-1, -1);
        }
    
        @Override
        public void write(DataOutput output) throws IOException {
            output.writeInt(user);
            output.writeInt(mutualFriend);
        }
    
        @Override
        public void readFields(DataInput input) throws IOException {
            user = input.readInt();
            mutualFriend = input.readInt();
        }
    
        @Override
        public String toString() {
            return Integer.toString(user) + "\\t" + Integer.toString(mutualFriend);
        }
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
        recJob.setCombinerClass(RecommendationReducer.class);
        recJob.setReducerClass(RecommendationReducer.class);
        recJob.setOutputKeyClass(IntWritable.class);
        recJob.setMapOutputKeyClass(IntWritable.class);
        recJob.setOutputValueClass(Text.class);
        recJob.setMapOutputValueClass(RecommendationWritable.class);

        for(int i = 0; i< pathArgs.length-1; ++i) {
            FileInputFormat.addInputPath(recJob, new Path(pathArgs[i]));
        }

        FileOutputFormat.setOutputPath(recJob, new Path(pathArgs[pathArgs.length-1]));

        System.exit(recJob.waitForCompletion(true) ? 0 : 1);
    }
}
