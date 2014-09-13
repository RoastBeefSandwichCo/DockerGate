DockerGate (scandalous, right?)
===============
A pre-installed, fully configured Docker image of Gatewayd (Did I say that right?)



##Progress

(Steven's list, re-ordered)

~~Install all gatewayd dependencies~~ *DONE*

~~Configure the gatewayd postgresql database~~ *DONE*

~~Include automatic startup scripts for ripple rest and gatewayd~~ *DONE*

~~Published to the Docker Registry Hub and clone-able by the general public~~ DONE

Start ~~gatewayd with~~ admin webapp ~~and expose gateway webapp and http api port~~ *testing*



##Image

Image: https://registry.hub.docker.com/u/roastbeefsandwichco/dockergate/

Autobuild: https://registry.hub.docker.com/u/roastbeefsandwichco/dockergate-auto/

##USAGE
```sudo docker run -p 5990:5990 -p 5000:5000 -i -t roastbeefsandwichco/dockergate:FULL-dev /bin/bash```

In order to use the exposed ports outside of the docker image, you must run with ```-p <map-this-port:to-this-port>```

```-i /bin/bash``` for interactive mode with shell

```-t <tag>``` 

Once you have a shell, use ```passwd shell_user_gatewayd``` to change the default password, then  ```su shell_user_gatewayd```

```start-rest``` starts ripple-rest

```start-gatewayd``` starts... gatewayd

```start-all``` starts both, in order.


##Notes:
webapp not yet working
