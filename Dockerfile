#TODO: addusers gatewayd and ripple-rest, run with appropriate permissions

# Set the base image to Ubuntu
FROM ubuntu:14.04
# File Author / Maintainer
MAINTAINER Jacob McShane

#DEPENDENCIES
# Update the repository sources list
RUN apt-get update
RUN apt-get install -y git python-software-properties python g++ make libpq-dev software-properties-common postgresql postgresql-client
# Add Node.js Repository, update, install
RUN add-apt-repository -y ppa:chris-lea/node.js && apt-get update && apt-get -y install nodejs


#Download Gatewayd, use known compatible release
RUN git clone https://github.com/ripple/gatewayd.git
RUN cd gatewayd/
RUN git checkout v3.4.0
#INSTALL gatewayd dependencies, pm2 separately, save
RUN npm install --global pg grunt grunt-cli forever db-migrate jshint && npm install --global pm2 --unsafe-perm && npm install --save

#CONFIGURE postgres
# Define password generator, generate password
RUN randpw(){ < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;}
RUN PASSWORD=`randpw 20`
RUN service postgresql start
#FIXME: NEEDS POSTGRES PASSWORD SET
# Create postgres user
RUN psql -U postgres -c "create user gatewayd_user with password '$PASSWORD'" -h localhost
# Create database and grant user access
RUN psql -U postgres -c "create database gatewayd_db with owner gatewayd_user encoding='utf8'" -h localhost
