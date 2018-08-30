# Author: Scott Willett
# Version: 30/08/18

# Run as root
# Ensure firewall has port 4444 unblocked
# RSA only at this time
# No additional SANs at this time

# Get the current user (to ensure the script is run as root, else exit)
USER=$(whoami)

# Exit with a message if not root
if  [ $USER != "root" ]
then
    echo 'You need to be root to run webcert.'
fi

if [ $USER = "root" ]
then

# Show a banner
echo ''
echo '---------------------'
echo '|      webcert      |'
echo '---------------------'
echo ''

# Create the webcert directory if it doesn't exist. If it does exist, do not throw an error
mkdir /srv/webcert 2>/dev/null

# Used when printing info about the webserver
IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/')

echo 'Please provide a name / label for your key pair'
read TITLE

echo 'Please specify an RSA key size - 2048 or 4096'
read KEY

echo 'Please specify country'
read COUNTRY

echo 'Please specify state:'
read STATE

echo 'Please specify company:'
read COMPANY

echo 'Please specify a primary domain'
read CN

# Create the appropriate directories
mkdir /srv/webcert/$TITLE
mkdir /srv/webcert/$TITLE/public
mkdir /srv/webcert/$TITLE/private
mkdir /srv/webcert/$TITLE/request

# Create a file for the SAN field
SANSTRING=$(cat /etc/ssl/openssl.cnf; echo "[SAN]\nsubjectAltName=DNS:$CN")
echo "$SANSTRING" >  /srv/webcert/$TITLE/request/request.conf

# Create the private key
openssl genrsa -out /srv/webcert/$TITLE/private/private.pem $KEY

# Create the request
openssl req -new -sha256 -key /srv/webcert/$TITLE/private/private.pem -subj "/C=$COUNTRY/ST=$STATE/O=$COMPANY/CN=$CN" -reqexts SAN -config /srv/webcert/$TITLE/request/request.conf -out /srv/webcert/$TITLE/request/request.req

# Enter the request directory
cd /srv/webcert/$TITLE/request

# Print a message about the http server
echo ''
echo 'Private key and request file created.'
echo "Your certificate server can access the request file at: http://$IP:4444/request.req"
echo 'Please press ctrl + C to stop hosting the file.'

# Serve up the request file via http
python -m SimpleHTTPServer 4444 2>/dev/null

fi
