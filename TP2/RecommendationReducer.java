import java.util.Map;
import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
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
                } else {
                    mutualFriends.put(friendId, new ArrayList<Integer>() {{ add(mutualFriend); }});
                }
            }
        }

        Map<Integer, List<Integer>> sortedFriends = decreasingMutualFriendsResult(mutualFriends);

        Integer i = 0;
        StringBuilder output = new StringBuilder();
        for (Map.Entry<Integer, List<Integer>> entry : sortedFriends.entrySet()) {
        	if (i == 10) break;
        	
        	if (entry.getValue() != null) {
        		output.append(entry.getKey().toString() + " (" + entry.getValue() + ")");
        	} else {
        		break;
        	}
        	output.append(",");
        	i++;
        }
        String outputStr = output.toString();
        
        if (outputStr.endsWith(",")) {
        	outputStr = outputStr.substring(0, output.length() - 1);
        }
        
        context.write(key, new Text(outputStr));
    }

    public static Map<Integer, List<Integer>> decreasingMutualFriendsResult(Map<Integer, List<Integer>> mutualFriends) {
        List<Map.Entry<Integer, List<Integer>> > list = new ArrayList<Map.Entry<Integer, List<Integer>> >(mutualFriends.entrySet());
        
        list.sort(
            (Map.Entry<Integer, List<Integer>> i1, Map.Entry<Integer, List<Integer>> i2) -> {
                Integer key1 = i1.getKey();
                Integer key2 = i2.getKey();
                Integer s1 = (i1.getValue() != null)? 0 : i1.getValue().size();
                Integer s2 = (i2.getValue() != null)? 0 : i2.getValue().size();
                if(s1>s2 || (s1.equals(s2) && key1 < key2)) {
                    return -1;
                } else {
                    return 1;
                }
            }
        );

        Map<Integer, List<Integer>> sortedMutFr = new LinkedHashMap<Integer, List<Integer>>();
        
        for(Map.Entry<Integer, List<Integer>> sortedEntries : list) {
            sortedMutFr.put(sortedEntries.getKey(), sortedEntries.getValue());
        }

        return sortedMutFr;

    }
}