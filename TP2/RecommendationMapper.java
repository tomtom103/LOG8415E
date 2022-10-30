import java.io.IOException;
import java.util.List;
import java.util.ArrayList;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.io.Text;

public class RecommendationMapper extends Mapper<IntWritable, Integer, IntWritable, RecommendationWritable> {

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
                            context.write(new IntWritable(friendId2),
                                    new RecommendationWritable((friendId1), userId));
                        }
                    }
                }   
            } catch(Exception e) {
            	e.printStackTrace();
            }
        }
    }
}