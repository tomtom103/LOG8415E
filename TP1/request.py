import json
import requests

def call_endpoint_http():
    url = "http://alb-test-1171701604.us-east-1.elb.amazonaws.com"
    headers = {'content-type': 'application/json'}
    r = requests.get(url, headers=headers)
    print(r.status_code)

def do_1000_request(url):
    for i in range(1000):
        r = requests.get(url)

def do_1000_request(url):
    for i in range(500):
        r = requests.get(url)
