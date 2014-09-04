#!/bin/sh
#Copy of my my dev env start-rest script. Modify for use.

cd /opt/ripple-rest
export DATABASE_URL=postgres://ripple_rest_user:kTzkbwyZwC@localhost:5432/ripple_rest_db
sudo -E -u restful /usr/bin/node server.js

