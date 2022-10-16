"""
This script is used to simulate a load on the ALB
"""
import requests
import time
import boto3
from tqdm import tqdm
from threading import Thread

def run_thread1_requests(url):
    print("Doing 1000 requests: " + url)
    for i in tqdm(range(1000)):
        requests.get(url)

def do_500_request(url):
    print("Doing 500 requests: " + url)
    for i in tqdm(range(500)):
        requests.get(url)

def run_thread2_requests(url):
    do_500_request(url)
    print("Sleeping for 60 seconds")
    time.sleep(60)
    run_thread1_requests(url)

if __name__ == "__main__":

    client = boto3.client('elbv2', region_name='us-east-1')
    url = client.describe_load_balancers()['LoadBalancers'][0]['DNSName']

    first_thread = Thread(target=run_thread1_requests, args=(("http://" + url + "/cluster1"),))
    second_thread = Thread(target=run_thread2_requests, args=(("http://" + url + "/cluster2"),))

    first_thread.start()
    second_thread.start()

    first_thread.join()
    second_thread.join()
