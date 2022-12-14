FROM python:3.8

WORKDIR /code

# Install dependencies:
COPY ./requirements.txt /code/requirements.txt
RUN pip3 install --no-cache-dir --upgrade -r /code/requirements.txt

# Copy the code:
COPY ./proxy /code/proxy
COPY .env /code/.env

# Install fping
RUN apt-get update && apt-get install -y fping

COPY ./labsuser.pem /code/labsuser.pem

ENTRYPOINT ["uvicorn", "proxy.main:app", "--host", "0.0.0.0", "--port", "8000"]