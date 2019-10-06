FROM jenkins/jenkins:lts

USER root

RUN apt-get update && \
apt-get -y install qt5-qmake && \
apt-get -y install qt5-default && \
apt-get -y install build-essential

USER jenkins
