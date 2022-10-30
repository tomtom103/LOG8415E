package RecommendationMR;

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
    public static Map<Integer, List<Integer>> decreasingMutualFriendsResult(Map<Integer, List<Integer>> mutualFriends) {
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