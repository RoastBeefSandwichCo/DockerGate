RUN#TODO: addusers gatewayd and ripple-rest, run with appropriate permissions

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
# Define password generator, generate passwords
RUN randpw(){ < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;}
RUN postgresPW=`randpw 20`
RUN gatewayd_userPW=`randpw 20`
RUN rest_userPW=`randpw 20`

 service postgresql start
RUN su - postgres -c "psql -c \"alter user postgres with password '$postgresPW';\""
# Create postgres user
RUN su - postgres -c "psql -c \"create user gatewayd_user with password '$gatewayd_userPW';\""
# Create ripple rest user
RUN su - postgres -c "psql -c \"create user ripplerest_user with password '$rest_userPW';\""
#>>>>>>>>>>>>>>>>>>>EVERYTHING ABOVE THIS LINE IS IN THE IMAGE >>>>>>>>>>>>>>>>>

# Create database
#change postgres template: http://stackoverflow.com/questions/16736891/pgerror-error-new-encoding-utf8-is-incompatible
RUN su - postgres -c "psql -c \"UPDATE pg_database SET datistemplate = FALSE WHERE datname = 'template1';\""
RUN su - postgres -c "psql -c \"DROP DATABASE template1;\""
RUN su - postgres -c "psql -c \"CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UNICODE';\""
RUN su - postgres -c "psql -c \"UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template1';\""
RUN su - postgres -c "psql -c \"\\c template1\""
RUN su - postgres -c "psql -c \"VACUUM FREEZE;\""
RUN su - postgres -c "psql -c \"create database gatewayd_db with owner gatewayd_user encoding='utf8';\""
#>>>>>>>>>>>>>>>>>>>EVERYTHING ABOVE THIS LINE IS IN THE IMAGE >>>>>>>>>>>>>>>>>



#>UPDATE pg_database SET datistemplate = FALSE WHERE datname = 'template1';
#>DROP DATABASE template1;
#>CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UNICODE';
#>UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template1';
#>\c template1
#>VACUUM FREEZE;
# su - postgres -c "psql -c \"create database gatewayd_db with owner gatewayd_user encoding='utf8';\""
#grant users access
#grant all on such and such
#usd sed to update gatewayd configs
#
#gateway config/config.js
#'DATABASE_URL': 'postgres://gatewayd_user:password@localhost:5432/gatewayd_db',
#
#lib/data/database
#
#'development': {
#  'ENV': 'postgres://gatewayd_user:password@localhost:5432/gatewayd_db'
#}
#TODO: update to production when appropriate
#
#dont forget the bug here
#grunt migrate
#
#start gatewayd, add wallets, currencies (point to our daemon
#
#Documentation for that has moved, perhaps the process has changed. We'll cross that bridge when we get to it.
