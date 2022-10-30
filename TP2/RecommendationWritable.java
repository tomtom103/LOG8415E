import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import org.apache.hadoop.io.Writable;

/*
 * This class need to be created because the emitted value is not a primitive value in hadoop
 */
public class RecommendationWritable implements Writable {
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