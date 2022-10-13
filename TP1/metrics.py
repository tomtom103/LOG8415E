import boto3
import matplotlib.pyplot as plt
from datetime import date, timedelta, datetime
cloudwatch_client = boto3.client('cloudwatch')

yesterday=date.today() - timedelta(days=1)
tomorrow=date.today() + timedelta(days=1)

elb_name = "app/elb/b57c92b6ef0de49a"
target_group_m4 = "targetgroup/m4/67ce59432e327420"
target_group_t2 = "targetgroup/t2/2d298dcfdab6976d"
st = datetime(yesterday.year, yesterday.month, yesterday.day)
et = datetime(tomorrow.year, tomorrow.month, tomorrow.day)
    
def get_request_count(tg) :
    response = cloudwatch_client.get_metric_data(
            MetricDataQueries=[
                {
                    'Id': 'myrequest',
                    'MetricStat': {
                        'Metric': {
                            'Namespace': 'AWS/ApplicationELB',
                            'MetricName': 'RequestCount',
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
                        'Period': 300,
                        'Stat': 'Sum',
                        'Unit': 'Count'
                    }
                },
            ],
            StartTime=st, 
            EndTime=et,    
        )
    return sum(response['MetricDataResults'][0]['Values'])



#print(get_request_count(target_group_m4))
#print(get_request_count(target_group_t2))

x = [get_request_count(target_group_m4),get_request_count(target_group_t2)]
plt.bar(['m4','t2'],x)
plt.title('Number of requests per target group')
plt.show()

