DockerGate (scandalous, right?)
===============
A pre-installed, self-configuring Docker image of Gatewayd (Did I say that right?)



##Progress

(Steven's list, re-ordered)

~~Install all gatewayd dependencies~~ *DONE*

~~Configure the gatewayd postgresql database~~ *DONE*

~~Include automatic startup scripts for ripple rest and gatewayd~~ *DONE*

~~Published to the Docker Registry Hub and clone-able by the general public~~ DONE

Start gatewayd with admin webapp and export gateway webapp and http api port *testing*



##Image

Image: https://registry.hub.docker.com/u/roastbeefsandwichco/dockergate/

Autobuild: >insert<

##USAGE
```sudo docker run -p 5900:5900 -p 5000:5000 -i -t roastbeefsandwichco:FULL-dev /bin/bash```

In order to use the exposed ports outside of the docker image, you must run with ```-p <map-this-port:to-this-port>```

```-i /bin/bash``` for interactive mode with shell

```-t <tag>``` 

