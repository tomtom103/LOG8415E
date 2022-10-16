"""
This script is used to plot different cloudwatch metrics from the ALB 
"""
import boto3
import matplotlib.pyplot as plt
from datetime import timedelta, datetime

#SET UP
region = 'us-east-1'
lb_client = boto3.client('elbv2',region_name = region)
cloudwatch_client = boto3.client('cloudwatch', region_name = region)
response_lb = lb_client.describe_load_balancers()
raw_arn = response_lb['LoadBalancers'][0]['LoadBalancerArn'].split(':')[-1].split('/')
response_tg = lb_client.describe_target_groups()

elb_name = raw_arn[1] + '/'  + raw_arn[2] + '/' + raw_arn[3] 
target_group_m4 = response_tg['TargetGroups'][0]['TargetGroupArn'].split(':')[-1]
target_group_t2 = response_tg['TargetGroups'][1]['TargetGroupArn'].split(':')[-1]


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
    fig, ax = plt.subplots()
    x = [sum(get_metric(target_group_m4,'RequestCount','Sum',True)),sum(get_metric(target_group_t2,'RequestCount','Sum',True))]
    plt.bar(['m4','t2'],x)
    plt.title('Number of requests per target group')
    plt.savefig('metrics/target-group-reqs.png', bbox_inches='tight')

    m4 = get_metric(target_group_m4,'TargetResponseTime','Average',True)
    t2 = get_metric(target_group_t2,'TargetResponseTime','Average',True)
    fig, ax = plt.subplots()
    if len(m4) > 0 :
        x = [sum(m4)/len(m4), sum(t2)/len(t2)]
        plt.bar(['m4','t2'],x)
        plt.title('Average response time per target group')
        plt.savefig('metrics/target-group-avg-res.png')

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
    plt.savefig('metrics/elb-plots.png', bbox_inches='tight')


plot_elb_table()
target_group_plots()

