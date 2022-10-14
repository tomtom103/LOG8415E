FROM python:3.8

ENV VIRTUAL_ENV=/.venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install dependencies:
COPY requirements.txt .
RUN pip install -r requirements.txt

# Add AWS credentials
COPY login.sh .
RUN chmod +x login.sh && ./login.sh

# Run Flask startup script
COPY scripts/startup.sh .
RUN chmod +x startup.sh && ./startup.sh

# Run the application:
COPY metrics.py .
CMD ["python", "metrics.py"]