FROM ubuntu:latest

RUN apt update -y && apt install -y git python3 python3-pip

RUN python3 -m pip install --user ansible

RUN cp /root/.local/bin/ansible /usr/local/bin/ansible

RUN ansible --version

CMD sleep 1000
