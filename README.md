DockerGate (scandalous, right?)
===============
A pre-installed, self-configuring Docker image of Gatewayd (Did I say that right?)

This is the Dockerfile, our image ~~will be published on completion~~ has been published as ninobrooks/dockergate:dev.

##Esplain, please
Gatewayd is FREAKING AWESOME but it can be a bit tedious to install. So the great and powerful Oz (a.k.a. Steven Zeiler) had an idea:
[here](https://www.bountysource.com/issues/4161110-publish-docker-image-of-fully-configured-gateway)

Ours is built on ubuntu:14.04. Dockerfile generates passwords and updates configs.

##Progress

(Steven's list, re-ordered)

~~Install all gatewayd dependencies~~ *DONE*

~~Configure the gatewayd postgresql database~~ *DONE*

~~Include automatic startup scripts for ripple rest~~ and gatewayd *in progress* 

Start gatewayd with admin webapp and export gateway webapp and http api port *queued*

Published to the Docker Registry Hub and clone-able by the general public *testing*

##Image

https://registry.hub.docker.com/u/ninobrooks/dockergate/

#TO-DO

  -Install rest *verifying*

  -startup script (~~rest~~, gatewayd)

  -configure gatewayd to start rest-client
  
  -admin app, export ports
  
  
