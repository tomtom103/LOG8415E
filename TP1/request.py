import requests
import time
from threading import Thread

def call_endpoint_http():
    url = "http://alb-test-1171701604.us-east-1.elb.amazonaws.com"
    headers = {'content-type': 'application/json'}
    r = requests.get(url, headers=headers)
    print(r.status_code)

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
