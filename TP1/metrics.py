import boto3
from datetime import date, timedelta, datetime
cloudwatch_client = boto3.client('cloudwatch')

yesterday=date.today() - timedelta(days=days)
tomorrow=date.today() + timedelta(days=1)
    
    
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
                                'Value': "TARGET GROUP NAME"
                            },
                            {                        
                                'Name': 'LoadBalancer',
                                'Value': "ELB NAME"
                            },
                        ]
                    },
                    'Period': 300,
                    'Stat': 'Sum',
                    'Unit': 'Count'
                }
            },
        ],
        StartTime=datetime(yesterday.year, yesterday.month, yesterday.day), 
        EndTime=datetime(tomorrow.year, tomorrow.month, tomorrow.day),    
    )

print(sum(response['MetricDataResults'][0]['Values']))