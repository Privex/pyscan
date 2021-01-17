FROM oraclelinux:8.3
VOLUME /app
WORKDIR /app
VOLUME /data

# COPY requirements.txt /app/
# RUN python3 -m pip install -U -r requirements.txt

COPY . /app/

# WORKDIR /data

ENTRYPOINT [ "/bin/bash" ]

