#Milestone(MS) index:
#Milestone 1: system dependencies installed
#Milestone 2: postgres configured, gatewayd installed and configured

# Set the base image to Ubuntu
FROM ubuntu:14.04
# File Author / Maintainer
MAINTAINER Jacob McShane

#USERS
# Define password generator, create user pw
RUN useradd -U -m -r -s /dev/null restful
RUN useradd -U -m -r shell_user_gatewayd
RUN adduser shell_user_gatewayd sudo

RUN randpw(){ < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;}
RUN shell_user_gatewaydPW=`randpw 20`
RUN echo "shell_user_gatewayd:$shell_user_gatewaydPW" | chpasswd
RUN export SHELL_USER_GATEWAYDPW=$shell_user_gatewaydPW
RUN su shell_user_gatewayd
RUN cd ~

#DEPENDENCIES
# Update the repository sources list
RUN echo "$SHELL_USER_GATEWAYDPW" | sudo -S apt-get update
RUN unset SHELL_USER_GATEWAYDPW

RUN sudo apt-get install -y git python-software-properties python g++ make libpq-dev software-properties-common postgresql postgresql-client
# Add Node.js Repository, update, install
RUN sudo add-apt-repository -y ppa:chris-lea/node.js
RUN sudo apt-get update
RUN sudo apt-get -y install nodejs

#########Milestone 1: system dependencies installed>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#Download Gatewayd, use known compatible release
#BE IN USER'S HOME!
RUN git clone https://github.com/ripple/gatewayd.git
RUN cd gatewayd/
#git checkout cd92ad3
#INSTALL gatewayd dependencies, pm2 separately, save
RUN sudo npm install --global pg grunt grunt-cli forever db-migrate jshint

RUN sudo npm install --global --unsafe-perm pm2
RUN sudo npm install --save

#generate other passwords
RUN randpw(){ < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;}

RUN db_user_postgresPW=`randpw 20`
RUN db_user_gatewaydPW=`randpw 20`
RUN db_user_ripple_restPW=`randpw 20`

#CONFIGURE postgres, users, DBs
RUN sudo service postgresql start
RUN sudo su - postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD '$db_user_postgresPW';\""

#change postgres template: http://stackoverflow.com/questions/16736891/pgerror-error-new-encoding-utf8-is-incompatible
RUN sudo su - postgres -c "psql -c \"UPDATE pg_database SET datistemplate = FALSE WHERE datname = 'template1';\""
RUN sudo su - postgres -c "psql -c \"DROP DATABASE template1;\""
RUN sudo su - postgres -c "psql -c \"CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UNICODE';\""
RUN sudo su - postgres -c "psql -c \"UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template1';\""
RUN sudo su - postgres -c "psql -c \"\\c template1\""
RUN sudo su - postgres -c "psql -c \"VACUUM FREEZE;\""
RUN sudo su - postgres -c "psql -c \"CREATE USER db_user_gatewayd WITH PASSWORD '$db_user_gatewaydPW';\""
#db_user_ripple_rest should be created with -E -S -R -D flags but they're breaking so...
RUN sudo su - postgres -c "psql -c \"CREATE USER db_user_ripple_rest WITH PASSWORD '$db_user_ripple_restPW';\""

RUN sudo su - postgres -c "psql -c \"CREATE DATABASE gatewayd_db WITH OWNER db_user_gatewayd encoding='utf8';\""
RUN sudo su - postgres -c "psql -c \"CREATE DATABASE ripple_rest_db WITH OWNER db_user_ripple_rest encoding='utf8';\""
RUN sudo su - postgres -c "psql -c \"GRANT ALL ON DATABASE gatewayd_db TO db_user_gatewayd;\""
RUN sudo su - postgres -c "psql -c \"GRANT ALL ON DATABASE ripple_rest_db TO db_user_ripple_rest;\""

#Set users, passwords, DBs in configs
RUN sed -i "s/postgres:password/db_user_gatewayd:$db_user_gatewaydPW/g" ./config/config.js
RUN sed -i "s/\/ripple_gateway/\/gatewayd_db/g" ./config/config.js
RUN cp lib/data/database.example.json lib/data/database.json
RUN sed -i "s/DATABASE_URL/postgres:\/\/db_user_gatewayd:$db_user_gatewaydPW@localhost:5432\/gatewayd_db/g" ./lib/data/database.json

RUN grunt migrate

######MILESTONE2: POSTGRES CONFIGURED, GATEWAYD INSTALLED AND CONFIGURED>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

RUN git clone https://github.com/ripple/ripple-rest.git
RUN cd ripple-rest
#an old version that worked
RUN git checkout 1.0.1
###chown -R restful:restful ../ripple-rest

#configure rest
#store pw in config
RUN cp config-example.json config.json
RUN sed -i "s/ripple_rest_user:password/db_user_ripple_rest:$db_user_ripple_restPW/g" ./config.json
RUN export DATABASE_URL=postgres://db_user_ripple_rest:$db_user_ripple_restPW@localhost:5432/ripple_rest_db

#create SSL certificates
RUN sudo /etc/init.d/ssl start
#set key file and path
RUN sed -i "s/.\/certs\/server.key/\/etc\/ssl\/server.key/g" ./config.json
RUN sed -i "s/.\/certs\/server.crt/\/etc\/ssl\/server.crt/g" ./config.json


#install dependencies, run migrations
RUN sudo npm install --global grunt grunt-cli pg
RUN sudo npm install


##MILESTONE 3! FULL RIPPLE-REST INSTALLATION!!! WOO!

#create ripple-rest startup script
RUN echo '#!/bin/sh' > ~/start-rest.sh
RUN echo "sudo service postgresql start" >> ~/start-rest.sh
RUN echo "cd /home/shell_user_gatewayd/gatewayd/ripple-rest" >> ~/start-rest.sh
RUN echo "export DATABASE_URL=postgres://db_user_ripple_rest:$db_user_ripple_restPW@localhost:5432/ripple_rest_db" >> ~/start-rest.sh
RUN echo "sudo -E -u restful /usr/bin/node server.js" >> ~/start-rest.sh
#NEIN do not use: su - restful -c /usr/bin/node server.js
#chown restful:restful /usr/bin/start-rest.sh &&
RUN chmod +x ~/start-rest.sh
RUN sudo cp ~/start-rest.sh /usr/bin && rm ~/start-rest.sh

#create gatewayd startup script
RUN echo '#!/bin/sh' > ~/start-gatewayd.sh
RUN echo "cd ~/gatewayd" >> ~/start-gatewayd.sh
RUN echo "bin/gateway start" >> ~/start-gatewayd.sh
RUN chmod +x ~/start-gatewayd.sh
RUN sudo cp ~/start-gatewayd.sh /usr/bin && rm ~/start-gatewayd.sh
#
##M3.2.2?
##start gatewayd, add wallets, currencies (point to our daemon VET THESE COMMANDS
#bin/gateway add_currency USD
#bin/gateway add_currency BTC
#bin/gateway add_currency LTC
#bin/gateway add_currency DOGE
#bin/gateway add_currency PHC
#bin/gateway set_cold_wallet rLWJBRXJFxd5RCyuFsiXd77bMQdPqe1ohu
#bin/gateway generate_wallet
#sudo service postgresql start
#export DATABASE_URL=postgres://db_user_gatewayd:Lki1AYjhKsEUJfhSAO4-@localhost:5432/gatewayd_db
#bin/gateway set_hot_wallet rDd4uWGejWShq54da56ce4zyn7TWeiGngT snRv5eL1h4m6RkJhAEzwCjk3yxxiN
#
#
#
##VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
##ISSUES:
##sed needs better regex for changing existing passwords
##ESRD flags in postgresql create user not working
##GATEWAYD HOTFIXES
##lib/processmanager, line 16 this.processesthingstuff
##config/config.js, add process.env['DATABASE_URL'] = nconf.get('DATABASE_URL');
##before exports. see: https://github.com/cornfeedhobo/gatewayd/blob/6f86926f79df2bed7399d626cb0b9966519efa32/config/config.js
#
#
#
#
##RESET USERS
##function
#randpw(){ < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;}
##gen PWs
#shell_user_gatewaydPW=`randpw 20`
#db_user_postgresPW=`randpw 20`
#db_user_gatewaydPW=`randpw 20`
#db_user_ripple_restPW=`randpw 20`
##apply changes
#
##just gatewayd:
#randpw(){ < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;}
##gen PWs
#shell_user_gatewaydPW=`randpw 20`
#
#echo "shell_user_gatewayd:$shell_user_gatewaydPW" | chpasswd
#export SHELL_USER_GATEWAYDPW=$shell_user_gatewaydPW
#su shell_user_gatewayd
#cd ~
#cd gatewayd
#echo $SHELL_USER_GATEWAYDPW
#
#
#
##just postgres
#randpw(){ < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;}
##gen PWs
##db_user_postgresPW=`randpw 20`
##db_user_gatewaydPW=`randpw 20`
#db_user_ripple_restPW=`randpw 20`
#
##sudo su - postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD '$db_user_postgresPW';\""
##sudo su - postgres -c "psql -c \"ALTER USER db_user_gatewayd WITH PASSWORD '$db_user_gatewaydPW';\""
#sudo su - postgres -c "psql -c \"ALTER USER db_user_ripple_rest WITH PASSWORD '$db_user_ripple_restPW';\""
##echo "$SHELL_USER_GATEWAYDPW" | sudo -S ddddd
