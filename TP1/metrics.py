import boto3
import matplotlib.pyplot as plt
from datetime import date, timedelta, datetime
cloudwatch_client = boto3.client('cloudwatch')


#TO CHANGE FOR EACH NEW SESSION
elb_name = "app/elb/51522bcfff79521a"
target_group_m4 = "targetgroup/m4/b957d794ac969e41"
target_group_t2 = "targetgroup/t2/55a1add456a22dc4"

#TIME

    
def get_metric(tg,metric_name,stat,get_value) :
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

    if get_value : 
        return response['MetricDataResults'][0]['Values']
    else :
        return response



# x = [sum(get_metric(target_group_m4,'RequestCount','Sum',True)),sum(get_metric(target_group_t2,'RequestCount','Sum',True))]
# plt.bar(['m4','t2'],x)
# plt.title('Number of requests per target group')
# plt.show()

# m4 = get_metric(target_group_m4,'TargetResponseTime','Average',True)
# t2 = get_metric(target_group_t2,'TargetResponseTime','Average',True)
# x = [sum(m4)/len(m4), sum(t2)/len(t2)]
# plt.bar(['m4','t2'],x)
# plt.title('Average response time per target group')
# plt.show()

m4 = get_metric(target_group_m4,'RequestCountPerTarget','Sum',False)
t2 = get_metric(target_group_t2,'RequestCountPerTarget','Sum',False)


val_m4 = m4['MetricDataResults'][0]['Values']
time_m4 = m4['MetricDataResults'][0]['Timestamps']
val_t2 = t2['MetricDataResults'][0]['Values']
time_t2 = t2['MetricDataResults'][0]['Timestamps']

figure, axis = plt.subplots(1, 2, sharey=True)
axis[0].plot(time_m4,val_m4)
axis[0].set_title('Average request count per instances in target group M4')
axis[1].plot(time_t2,val_t2)
axis[1].set_title('Average request count per instances in target group T2')
plt.gcf().autofmt_xdate()
plt.show()