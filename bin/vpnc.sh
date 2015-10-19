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
client = TinyTds::Client.new username: '${SQL_USER}', password: '${SQL_PASSWORD}', host: '${SQL_HOST}', port:'${SQL_PORT}', appname:'${SQL_APPNAME}', database: '${SQL_DATABASE}', timeout: 60 
testsql = "select 
dim_lead.lead_id,
dim_date_key_activity,
sub_status,
contact_phone,
REPLACE(REPLACE(contact_city,',',' '), '\"','') as contact_city,
REPLACE(REPLACE(contact_state,',',' '), '\"','') as contact_state,
contact_zip,
REPLACE(REPLACE(contact_country, ',', ' '), '\"','') as contact_country,
total_referrals,
dim_property.property_id,
care_types,
REPLACE(REPLACE(org_name,',',' '), '\"','') as org_name,
REPLACE(REPLACE(property_name,',',' '), '\"','') as property_name,
REPLACE(REPLACE(resident_first_name,',',' '), '\"','') as resident_first_name,
REPLACE(REPLACE(resident_last_name,',',' '), '\"','') as resident_last_name,
REPLACE(REPLACE(resident_first_last_name,',',' '), '\"','') as resident_first_last_name,
REPLACE(REPLACE(contact_first_name,',',' '), '\"','') as contact_first_name,
REPLACE(REPLACE(contact_last_name,',',' '), '\"','') as contact_last_name,
REPLACE(REPLACE(contact_first_last_name,',',' '), '\"','') as contact_first_last_name
from 
fact_lead_activity
join dim_lead on fact_lead_activity.lead_id = dim_lead.lead_id
join dim_property on dim_property.property_id = fact_lead_activity.property_id
where total_referrals = 1 and 
      dim_lead.date_end ='2099-12-31' and 
            dim_property.date_end ='2099-12-31' and 
                  care_types like '%h%' and
                        substring(cast(dim_date_key_activity as varchar(8)),0,5) = '2015' and 
                              substring(cast(dim_date_key_activity as varchar(8)),5,2) = '09'
                              "
puts "SQL CLIENT ACTIVE: #{client.active?}"
result = client.execute(testsql)
result.each(:as => :array, :cache_rows => false) do |row|
puts row.join(',')
end
EOF

exec /usr/sbin/vpnc default --no-detach --non-inter
exec /usr/bin/ruby /sql.rb
