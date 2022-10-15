FROM python:3.8

WORKDIR /usr/app/src

ENV VIRTUAL_ENV=/.venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install dependencies:
COPY ./requirements.txt .
RUN pip install -r requirements.txt

# Run the script:
COPY ./requests/do_requests.py .

ENTRYPOINT [ "python", "do_requests.py" ]