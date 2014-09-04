DockerGate (scandalous, right?)
===============
A self-installing, self-configuring Docker image of Gatewayd (Did I say that right?)

Obviously the image is not hosted here, Docker has repos for that. This repository is to show our progress.

##Esplain, please
AFAIK, unless an image actually executes a gatewayd installation, it won't be "dynamic". At the very least, passwords should be generated on-the-fly.

Therefore, we're using a Dockerfile based on an ubuntu minimal image. The Dockerfile builds from scratch a complete Gatewayd and Postgresql installation as outline [here](https://www.bountysource.com/issues/4161110-publish-docker-image-of-fully-configured-gateway)

You know what? I just had a much better idea that should have occurred to me much sooner.
The image SHOULD contain everything pre-installed and just generate the passwords. That would save download and installation time, etc. *facepalm*

okay back to work now.
