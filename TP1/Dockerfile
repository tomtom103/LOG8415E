FROM python:3.8

WORKDIR /usr/app/src

ENV VIRTUAL_ENV=/.venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install dependencies:
COPY requirements.txt .
RUN pip install -r requirements.txt

# Add AWS credentials
RUN mkdir -p ~/.aws
COPY ~/.aws/credentials ~/.aws/credentials

# Run the script:
COPY metrics.py .
RUN mkdir metrics && \
    python metrics.py