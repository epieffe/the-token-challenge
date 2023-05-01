FROM node:18.16-bullseye

RUN apt-get update && apt-get upgrade -y

# install ganache-cli
RUN npm install ganache-cli@6.12.2 --global

# install python3 and pip
RUN apt-get install -y python3 python3-dev python3-pip

# install brownie
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

WORKDIR /app

# install dependencies before importing sources to take advantage of Docker layers cache
RUN brownie pm install OpenZeppelin/openzeppelin-contracts@4.8.3

COPY brownie-config.yaml brownie-config.yaml
COPY scripts scripts
COPY contracts contracts
COPY tests tests

RUN brownie compile

ENTRYPOINT ["brownie"]
