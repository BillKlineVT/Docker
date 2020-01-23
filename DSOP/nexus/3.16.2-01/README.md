# sonatype nexus v3.15

This is derived from https://github.com/CMYanko/ubi-nexus3 provided by the Sonatype team

## Ports
This container requires port 8081 to be exposed in order to effectively run. 8081
is used to serve up the nexus HTML frontend.

## Volumes
This container relies on a volume specified by the environment variable NEXUS_DATA
which has the value '/nexus-data'.

## Running the container
In order to run the container, enter the following command inside this directory:
`docker run -d -p8081:8081 <image name>`.

