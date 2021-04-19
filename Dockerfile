FROM ubuntu:20.04
COPY build.sh /tmp/build.sh
RUN chmod +x /tmp/build.sh && /tmp/build.sh && rm /tmp/build.sh
