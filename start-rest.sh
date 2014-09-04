#scratch this. script its creation.

#!/bin/sh
#Copy of my my dev env start-rest script. Modify for use.
#ONLY use with non-bundled ripple-rest. Bundled rest can-should
#be started by gatewayd


#example: cd /opt/ripple-rest
cd /path/to/ripple-rest

#hm, apply sed to this as well.
export DATABASE_URL=postgres://ripple_rest_user:kTzkbwyZwC@localhost:5432/ripple_rest_db

#if you are root, construct a su command instead
sudo -E -u restful /usr/bin/node server.js
