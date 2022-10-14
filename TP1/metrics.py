from statistics import mode
import boto3
import matplotlib.pyplot as plt
from datetime import timedelta, datetime
cloudwatch_client = boto3.client('cloudwatch')


#TO CHANGE FOR EACH NEW SESSION
elb_name = "app/elb/51522bcfff79521a"
target_group_m4 = "targetgroup/m4/b957d794ac969e41"
target_group_t2 = "targetgroup/t2/55a1add456a22dc4"


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

def get_lb_metrics(metric_name,stat) :
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

def target_group_plots() :

    x = [sum(get_metric(target_group_m4,'RequestCount','Sum',True)),sum(get_metric(target_group_t2,'RequestCount','Sum',True))]
    plt.bar(['m4','t2'],x)
    plt.title('Number of requests per target group')
    plt.show()

    m4 = get_metric(target_group_m4,'TargetResponseTime','Average',True)
    t2 = get_metric(target_group_t2,'TargetResponseTime','Average',True)
    x = [sum(m4)/len(m4), sum(t2)/len(t2)]
    plt.bar(['m4','t2'],x)
    plt.title('Average response time per target group')
    plt.show()

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

def plot_elb_table () :
    act = get_lb_metrics('ActiveConnectionCount','Sum')
    avg_act = sum(act)/len(act)
    pros_bytes = sum(get_lb_metrics('ProcessedBytes','Sum'))
    rq_count = sum(get_lb_metrics('RequestCount','Sum'))
    hs_m4 = max(get_metric(target_group_m4,'HealthyHostCount','Maximum', True))
    hs_t2 = max(get_metric(target_group_t2,'HealthyHostCount','Maximum', True))

    table_data=[
    ["Average active connection count", avg_act],
    ["Total bytes processed", pros_bytes],
    ["Total request count", rq_count],
    ["Number of healty hosts in M4", hs_m4],
    ['Number of healthy hosts in T2', hs_t2]
    ]

    fig, ax = plt.subplots()
    table = ax.table(cellText=table_data, loc='center')
    table.set_fontsize(14)
    table.scale(1,4)
    ax.axis('off')
    plt.title('Different elb metrics')
    plt.show()


plot_elb_table()
target_group_plots()


