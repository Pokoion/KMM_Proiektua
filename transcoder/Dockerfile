FROM jrottenberg/ffmpeg:6.1-ubuntu

WORKDIR /workspace
COPY ./transcoder.sh /usr/local/bin/transcoder.sh
RUN apt-get update && apt-get install -y dos2unix && \
    dos2unix /usr/local/bin/transcoder.sh && \
    chmod +x /usr/local/bin/transcoder.sh