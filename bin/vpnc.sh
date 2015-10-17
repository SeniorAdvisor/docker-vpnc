#!/bin/sh

cat > /etc/vpnc/default.conf <<EOF
IPSec gateway ${VPNC_GATEWAY}
IPSec ID ${VPNC_ID}
IPSec secret ${VPNC_SECRET}
Xauth username ${VPNC_USERNAME}
Xauth password ${VPNC_PASSWORD}
Domain ${VPNC_DOMAIN}
DPD idle timeout (our side) 0
EOF

cat > /sql.rb <<EOF
require "rubygems"
require "tiny_tds"
client = TinyTds::Client.new username: '${SQL_USER}', password: '${SQL_PASSWORD}', host: '${SQL_HOST}', port:'${SQL_PORT}', appname:'${SQL_APPNAME}', database: '${SQL_DATABASE}'
puts client.active?
EOF

exec /usr/sbin/vpnc default --no-detach --non-inter
exec /usr/bin/ruby /sql.rb
