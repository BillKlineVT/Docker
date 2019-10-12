FROM jenkins/jenkins:lts

USER root

ENV JENKINS_OPTS -Djenkins.install.runSetupWizard=false -Dorg.apache.commons.jelly.tags.fmt.timeZone=America/Chicago

RUN apt-get update && \
apt-get -y install qt5-qmake && \
apt-get -y install qt5-default && \
apt-get -y install build-essential && \
apt-get -y install cppcheck && \
apt-get -y install sqlite3 && \
apt-get -y install vim && \
apt-get -y install xvfb && \
apt-get -y install apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common && \
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey && \
add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
     $(lsb_release -cs) \
     stable" && \
apt-get update && \
apt-get -y install docker-ce

USER jenkins
