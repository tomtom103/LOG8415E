# Setup

## Important steps

1. verify the credentials in login.sh
2. chmod the updated labsuser.pem

## Command to ssh to an instance:

**Don't forget to put the rules to accept everyone**

``` 
ssh -i labsuser.pem ubuntu@publicDNSname 
```

## SCP file to instance:

```
scp -i labsuser.pem app.py ubuntu@publicDNSname:~/.
```

## In the instance:

```
sudo apt update
```
```
sudo apt install python3-pip
```
```
sudo pip3 install flask
``` 
```
sudo python3 yourFile.py
```