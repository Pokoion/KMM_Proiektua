FROM jrottenberg/ffmpeg:6.1-ubuntu

RUN apt-get update && apt-get install -y --no-install-recommends \
    gpac bash && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY ./transcoder.sh /usr/local/bin/transcoder.sh
RUN chmod +x /usr/local/bin/transcoder.sh