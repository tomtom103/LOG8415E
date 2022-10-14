import requests
import time
import boto3
from threading import Thread

def run_thread1_requests(url):
    for i in range(1000):
        r = requests.get(url)

def do_500_request(url):
    for i in range(500):
        r = requests.get(url)

def run_thread2_requests(url):
    do_500_request(url)
    time.sleep(60)
    run_thread1_requests(url)

def start_threads(threads):
    for thread in threads:
        thread.start()

def join_threads(threads):
    for thread in threads:
        thread.join()

if __name__ == "__main__":

    client = boto3.client('elbv2', region_name='us-east-1')
    url = client.describe_load_balancers()['LoadBalancers'][0]['DNSName']

    first_thread = Thread(target=run_thread1_requests, args=(url + "/cluster1"))
    second_thread = Thread(target=run_thread2_requests, args=(url + "/cluster2"))

    start_threads([first_thread, second_thread])

    join_threads([first_thread, second_thread])
