package RecommendationMR;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.GenericOptionsParser;

public class Recommendation {
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
    }
}
