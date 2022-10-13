import boto3
import matplotlib.pyplot as plt
from datetime import date, timedelta, datetime
cloudwatch_client = boto3.client('cloudwatch')


#TO CHANGE FOR EACH NEW SESSION
elb_name = "app/elb/b57c92b6ef0de49a"
target_group_m4 = "targetgroup/m4/b071354a3aa6b304"
target_group_t2 = "targetgroup/t2/98b30930c87eb97e"

#TIME

    
def get_metric(tg,metric_name,stat) :
    response = cloudwatch_client.get_metric_data(
            MetricDataQueries=[
                {
                    'Id': 'myrequest',
                    'MetricStat': {
                        'Metric': {
                            'Namespace': 'AWS/ApplicationELB',
                            'MetricName': metric_name,
                            'Dimensions': [
                                {
                                    'Name': 'TargetGroup',
                                    'Value': tg
                                },
                                {                        
                                    'Name': 'LoadBalancer',
                                    'Value': elb_name
                                },
                            ]
                        },
                        'Period': 300, #5 min period
                        'Stat': stat,
                    }
                },
            ],
            StartTime= datetime.utcnow()- timedelta(days=1), 
            EndTime= datetime.utcnow()+timedelta(days=1),    
        )

  
    return response['MetricDataResults'][0]['Values']



x = [sum(get_metric(target_group_m4,'RequestCount','Sum')),sum(get_metric(target_group_t2,'RequestCount','Sum'))]
plt.bar(['m4','t2'],x)
plt.title('Number of requests per target group')
plt.show()

m4 = get_metric(target_group_m4,'TargetResponseTime','Average')
t2 = get_metric(target_group_t2,'TargetResponseTime','Average')
x = [sum(m4)/len(m4), sum(t2)/len(t2)]
plt.bar(['m4','t2'],x)
plt.title('Average response time per target group')
plt.show()

# m4 = get_metric(target_group_m4,'RequestCountPerTarget','Sum')
# t2 = get_metric(target_group_t2,'RequestCountPerTarget','Sum')



