FROM ubuntu:latest

RUN apt update -y && apt install -y git python3 python3-pip

RUN python3 -m pip install --user ansible

RUN cp /root/.local/bin/* /usr/local/bin/

RUN ansible --version

CMD sleep 1000


## Image built and pushed to Docker Hub

    # docker build -t deploy-playbook .
    # docker tag deploy-playbook:latest <dockerhub-username>/deploy-playbook:latest
    # docker push <dockerhub-username>/deploy-playbook:latest