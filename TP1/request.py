import requests
import time
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
    # should get this info in terraform or directly from the ui ? 
    url = ""

    # need to add /cluster1 and /cluster2 for the good thread
    first_thread = Thread(target=run_thread1_requests, args=(url))
    second_thread = Thread(target=run_thread2_requests, args=(url))

    start_threads([first_thread, second_thread])

    join_threads([first_thread, second_thread])
