FROM python:3.8-alpine

VOLUME /app
WORKDIR /app
VOLUME /data

# COPY requirements.txt /app/
# RUN python3 -m pip install -U -r requirements.txt

COPY . /app/

WORKDIR /data

ENTRYPOINT [ "/app/run.py" ]

