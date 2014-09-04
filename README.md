DockerGate (scandalous, right?)
===============
A pre-installed, self-configuring Docker image of Gatewayd (Did I say that right?)

This is the Dockerfile, our image will be published on completion.

##Esplain, please
Gatewayd is FREAKING AWESOME but it can be a bit tedious to install. So the great and powerful Oz (a.k.a. Steven Zeiler) had an idea:
[here](https://www.bountysource.com/issues/4161110-publish-docker-image-of-fully-configured-gateway)

Ours is built on ubuntu:14.04. Dockerfile generates passwords and updates configs.

##Progress
Install all gatewayd dependencies *DONE*
Include automatic startup scripts for gatewayd and ripple rest *in progress* 
Configure the gatewayd postgresql database *DONE*
Start gatewayd with admin webapp and export gateway webapp and http api port
Published to the Docker Registry Hub and clone-able by the general public *testing*
