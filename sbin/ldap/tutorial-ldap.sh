# Terms
DIT	Directory Information Tree
DN 	Distinguished Name
CN	Common Name
DC	Domain component
OU	Organizational Unit
LDIF 	LDAP Data Inerchange Format
Suffix	The top level of the DIT

# START and STOP
	sudo systemctl status slapd
	sudo systemctl stop slapd
	sudo systemctl start slapd

# TESTING CONFIG 
# Test configuration, you can ignore files with incorrect check sums
	sudo slaptest -u

# Testing SSL
# Test SSL certificate on ldap host
	openssl s_client -connect HOST:PORT
	openssl s_client -connect infra01.cloudair.lan:636 

# To grab the certificate if required
openssl s_client -connect <AD_HOST_NAME_OR_IP_ADDRESS>:636 -showcerts </dev/null 2>/dev/null | openssl x509 -outform PEM > ad_ldap_server.pem

Example:
openssl s_client -connect infra01.cloudair.lan:636 -showcerts </dev/null 2>/dev/null | openssl x509 -outform PEM > ldap-cert.pem

# Test test SSL connection
ldapsearch -ZZ -h <AD_HOST_NAME_OR_IP_ADDRESS> -D <BIND_DN> -W -b <BASE_DN> dn
               -ZZ: Start TLS (for LDAPS)
               -h: IP/hostname of Active Directory server
               -D: BindDN or User principal name
               -W: Password (to be provided interactively)
               -b: Base DN for search (where in the LDAP tree to start looking) 

ldapsearch -ZZ -h  infra01.cloudair.lan -D cn=ldapadmin,dc=cloudair,dc=lan -W -b ou=users,dc=cloudair,dc=lan dn

# SEARCHING
# Searching through LDAP DIT
	ldapsearch -h infra01.cloudair.lan -p 389 -D cn=ldapadmin,dc=cloudair,dc=lan -w BadPass%1 -b dc=cloudair,dc=com ou=users 
	-h host
	-p port
	-D binddn bind DN
	-w Password
	-W prompt for Password
	-b basedn identify where to start search
	-H URI LDAP Uniform Resource Identifier
	-x Simple authentication
	-Y mech SASL mechanism EXTERNAL
	search object

# Searching objects classes
	ldapsearch -x -b "dc=cloudair,dc=lan" objectclass=* 

# Searching organizational units
	ldapsearch -x -b "dc=cloudair,dc=lan" ou=users
	ldapsearch -x -b "dc=cloudair,dc=lan" ou=hdpusers
	ldapsearch -x -b "dc=cloudair,dc=lan" ou=groups
	ldapsearch -x -b "dc=cloudair,dc=lan" ou=biz

# Searching users
	ldapsearch -x -b "dc=cloudair,dc=lan" uid=prose
	ldapsearch -x -b "dc=cloudair,dc=lan" uid=slee

# ADDING RECORDS
# First you must create a LDIF and then use the ldapadd command.
# Records are separted by new line. Once the LDIF is used it can be deleted
# Example LDIF for adding records
# ldapadd command 
	ldapadd -D cn="ldapadmin,dc=cloudair,dc=lan" -w BadPass%1 -f addusers.ldif
	ldapadd -D cn="ldapadmin,dc=cloudair,dc=lan" -w BadPass%1 -f addgroups.ldif

# DELETING RECORDS
# The LDIF command for running a change file
	ldapmodify -x -D "cn=ldapadmin,dc=cloudair,dc=lan" -w BadPass%1 -H ldap://infra01.cloudair.lan -f delusers.ldif
	ldapmodify -x -D "cn=ldapadmin,dc=cloudair,dc=lan" -w BadPass%1 -H ldap://infra01.cloudair.lan -f delgroups.ldif

# Examples of LDIF delete file format:
	# Delete an entry
	dn: cn=Joe Bloe,ou=admin,dc=cloudair,dc=lan
	chansl s_client -connect HOST:PORTetype: delete

# CHANGING RECORDS
# The LDIF command for running a change file
	ldapmodify -x -D "cn=ldapadmin,dc=cloudair,dc=lan" -w BadPass%1 -H ldap://infra01.cloudair.lan -f delusers.ldif

# Examples of LDIF change file format:
	# Change attributes
	dn: cn=Kris Louis,ou=finance,dc=cloudair,dc=lan
	changetype: modify
	replace: telephoneNumber
	telephoneNumber: 4085551212

	# Add John Smith to the organization
	dn: uid=jsmith1,ou=People,dc=example,dc=com
	changetype: add
	objectClass: ilanOrgPerson
	description: John Smith from Accounting.
	cn: John Smith
	sn: Smith
	uid: jsmith1

	# Delete an attribute
	dn: ou=othergroup,dc=example,dc=com
	changetype: delete

	# Delete an attribute
	dn: uid=jsmith1,ou=People,dc=example,dc=com
	changetype: modify
	delete: mail
	mail: jsmith1@example.com

	
# TROUBLESHOOTING
# There are two main methods that I know of and for both you have to be logged in as root. First:
  	slapcat -b cn=config

# Slapd does not even have to be running. This command will dump the entire configuration, but you can also filter its output:
# This will show only the root object. 
  	slapcat -b cn=config -a cn=config

# This will show both the root object and the hdb database definition.
  	slapcat -b cn=config -a "(|(cn=config)(olcDatabase={1}hdb))"

# Second method:
  	ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config

# Again, you can also filter the output:
  	ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config "(|(cn=config)(olcDatabase={1}hdb))"

# You can search for specific parameters
  	ldapsearch -Y EXTERNAL -H ldapi:/// -b "cn=config" olcTLSCACertificatePath 

  	ldapsearch -Y EXTERNAL -H ldapi:/// -b "cn=config" \
   olcTLSCACertificateFile olcTLSCertificateFile olcTLSCertificateKeyFile

# Trouble Shooting Tips
# Make sure your slapd.conf is being used and is correct (as root)
	slapd -T test -f slapd.conf -d 65535

# You may have a left-over or default slapd.d configuration directory which 
# takes preference over your slapd.conf (unless you specify your config
# explicitly with -f, slapd.conf is officially deprecated in OpenLDAP-2.4). 
# If you don't get several pages of output then your binaries were built 
# without debug support.  
# stop OpenLDAP, then manually start slapd in a separate terminal/console 
# with debug enabled (as root, ^C to quit)
	slapd -h ldap://localhost -d 481

# then retry the search and see if you can spot the problem (there will be 
# a lot of schema noise in the start of the output unfortunately). (Note: 
# running slapd without the -u/-g options can change file ownerships which 
# can cause problems, you should usually use those options, probably 
# -u ldap -g ldap )
# if debug is enabled, then try also
	ldapsearch -v -d 63 -W -D 'cn=ldapadmin,dc=cloudair,dc=lan' -b "" -s base

# Schema files
# The schema defines the set of rules. They list the objectclass and the 
# attributes assigned to each object class. You must always define the 
# attibute with objective class and the attribute. 
# core.schema is the base schema


# Deleting Users from Ambari
curl --insecure -u admin:admin -H 'X-Requested-By:ambari' -X DELETE https://admin01.cloudair.lan:8443/api/v1/users/devuser
