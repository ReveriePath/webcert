# webcert
A wrapper bash script to easily create an RSA private key and certificate request file for signing by a CA of your choosing, without having to fiddle around with openssl command details and trickery (in particular with generating a subjectAltName with the request).

The intention is to use the key pair for web TLS connections.

Before you use this script, unblock port 4444.
- iptables -A INPUT -p tcp --dport 4444 -j ACCEPT

I recommend copying the script to /opt/webcert/webcert.sh and creating a symbolic link
- ln -s /opt/webcert/webcert.sh /usr/bin/webcert

Running webcert will present you with a wizard to create the files you need. It will place them under /srv/webcert/$LABEL/ under appropriately labeled directories and files.

webcert uses the .pem file extension for the private key that's generated, and the .req extension for the request to present to your CA. After your CA processes the request, I recommend copying your public key to /srv/webcert/$LABEL/public.
