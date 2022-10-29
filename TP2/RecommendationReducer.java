import java.util.Map;
import java.util.List;
import java.util.HashMap;
import java.io.IOException;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

public class RecommendationReducer extends Reducer<IntWritable, RecommendationWritable, IntWritable, Text> {

    public void reduce(IntWritable key, Iterable<RecommendationWritable> values, Context context) 
        throws IOException, InterruptedException {
        
        Map<Integer, List<Integer>> mutualFriends = new HashMap<Integer, List<Integer>>();

        for(RecommendationWritable rec : values) {
            final Integer friendId = rec.user;
            final Integer mutualFriend = rec.mutualFriend;
            final Boolean alreadyFriend = (mutualFriend == -1);
            
            if(alreadyFriend){
                mutualFriends.put(friendId, null);
            } else {
                if(mutualFriends.containsKey(friendId)) {
                    if(mutualFriends.get(friendId) != null) {
                        mutualFriends.get(friendId).add(mutualFriend);
                    }
                }
            }
        }
    }

    public static Map<Integer, List<Integer>> decreasingMutualFriendsResult(Map<Integer, List<Integer>> mutualFriends) {
        
    }
}