FROM jenkins/jenkins:lts

USER root

RUN apt-get update && \
apt-get -y install qt5-qmake && \
apt-get -y install qt5-default && \
apt-get -y install build-essential && \
apt-get -y install cppcheck && \
apt-get -y install sqlite3 && \
apt-get -y install vim && \
apt-get -y install xvfb

USER jenkins
