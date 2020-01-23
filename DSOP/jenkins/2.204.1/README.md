# Jenkins v2.204.1

This is derived from https://github.com/jenkinsci/docker/blob/master/Dockerfile

## Ports
This container requires port 8080 to be exposed in order to effectively run. 50000
is used as the Jenkins Agent port.

## Volumes
This container relies on a volume specified by the environment variable JENKINS_HOME
which has the value '/var/jenkins_home'.

## Running the container
In order to run the container, enter the following command inside this directory:
`docker run -dit -p 8080:8080 <image id>`. This will run the container with port
8080 exposed.

## Preferred run command: 
`docker run --name jenkins --env JENKINS_OPTS="-Dorg.apache.commons.jelly.tags.fmt.timeZone=America/New_York" -d -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock -v /data/jenkins:/var/jenkins_home billklinefelter/dsop-jenkins-2.204.1:latest`

## Scan Artifacts
Artifacts from the scan on the this container may be found [here](https://dsop-pipeline-artifacts.s3-us-gov-west-1.amazonaws.com/testing/container-scan-reports/opensource/jenkins-ubi7-stigd/repo_map.html).

## Other Info
This container has a default set of plugins which it pulls as a zip file from a 
nexus. These default plugins are installed and available on launch in the case
that outside internet access is unavailable.
