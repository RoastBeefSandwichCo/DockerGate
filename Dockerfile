# Set the base image to Ubuntu
FROM ubuntu:14.04
# File Author / Maintainer
MAINTAINER Jacob McShane
# Update the repository sources list
RUN apt-get update
# Install command wget
RUN apt-get install wget
# Download Gatewayd
RUN wget https://github.com/ripple/gatewayd/archive/v3.25.1.tar.gz
# Unzip gatewayd file
RUN tar xvfz v3.25.1.tar.gz
# Remove zip file
RUN rm v3.25.1.tar.gz
# Switch to gatewayd directory
RUN cd gatewayd-3.25.1/
# Install nodejs dependencies
RUN apt-get -y install git python-software-properties python g++ make libpq-dev software-properties-common
# Node.js Repository
RUN add-apt-repository -y ppa:chris-lea/node.js
# Update the repository list
RUN apt-get update
# Install postgres and nodejs
RUN apt-get -y install nodejs postgresql postgresql-client
# Install gatewayd dependencies
RUN npm install --global pg grunt grunt-cli forever db-migrate jshint
# Install pm2 dependency
RUN npm install --global pm2 --unsafe-perm
# Save npm changes
RUN npm install --save
# Define create password function
RUN randpw(){ < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;}
# Generate password
RUN VAR=`randpw 20`
# Create postgres user
RUN psql -U postgres -c "create user gatewayd_user with password '$VAR'" -h localhost
# Create database and grant user access
RUN psql -U postgres -c "create database gatewayd_db with owner gatewayd_user encoding='utf8'" -h localhost
