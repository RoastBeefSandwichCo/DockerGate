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
RUN git checkout cd92ad3
#INSTALL gatewayd dependencies, pm2 separately, save
RUN npm install --global pg grunt grunt-cli forever db-migrate jshint && npm install --global pm2 --unsafe-perm && npm install --save

#CONFIGURE postgres
# Define password generator, generate passwords
RUN randpw(){ < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;}
RUN postgresPW=`randpw 20`
RUN gatewayd_userPW=`randpw 20`
RUN rest_userPW=`randpw 20`
# Create & configure database
#change postgres template: http://stackoverflow.com/questions/16736891/pgerror-error-new-encoding-utf8-is-incompatible
RUN service postgresql start
RUN su - postgres -c "psql -c \"UPDATE pg_database SET datistemplate = FALSE WHERE datname = 'template1';\""
RUN su - postgres -c "psql -c \"DROP DATABASE template1;\""
RUN su - postgres -c "psql -c \"CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UNICODE';\""
RUN su - postgres -c "psql -c \"UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template1';\""
RUN su - postgres -c "psql -c \"\\c template1\""
RUN su - postgres -c "psql -c \"VACUUM FREEZE;\""
RUN su - postgres -c "psql -c \"alter user postgres with password '$postgresPW';\""
RUN su - postgres -c "psql -c \"create user gatewayd_user with password '$gatewayd_userPW';\""
RUN su - postgres -c "psql -c \"create user ripplerest_user with password '$rest_userPW';\""
RUN su - postgres -c "psql -c \"CREATE DATABASE gatewayd_db with OWNER gatewayd_user encoding='utf8';\""
RUN su - postgres -c "psql -c \"GRANT ALL ON DATABASE gatewayd_db TO ripplerest_user;\""
RUN su - postgres -c "psql -c \"GRANT ALL ON DATABASE gatewayd_db TO gatewayd_user;\""

#Edit config files with paths, passwords
RUN sed -i "s/postgres:password/gatewayd_user:$gatewayd_userPW/g" ./config/config.js
RUN sed -i "s/\/ripple_gateway/\/gatewayd_db/g" ./config/config.js
RUN cp lib/data/database.example.json lib/data/database.json
RUN sed -i "s/DATABASE_URL/postgres:\/\/gatewayd_user:$gatewayd_userPW@localhost:5432\/gatewayd_db/g" ./lib/data/database.json

RUN grunt migrate
#>>>>>>>>>>>>>>>>>>>EVERYTHING ABOVE THIS LINE IS IN THE IMAGE >>>>>>>>>>>>>>>>>
#pushed to ninobrooks/dockergate, tagged dev

#start gatewayd, add wallets, currencies (point to our daemon
#
#Documentation for that has moved, perhaps the process has changed. We'll cross that bridge when we get to it.


#ISSUES:
#sed replaces ALL instances of database_url in database.json
