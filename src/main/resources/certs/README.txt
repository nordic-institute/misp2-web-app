Key and certificate are created with:
openssl req -new -x509 -days 3650 -extensions v3_ca -keyout MISP2_CA_key.pem -keyform pkcs8 -nodes -out MISP2_CA_cert.pem -config openssl.cnf

Key with der extension is created with:
openssl rsa -in MISP2_CA_key.pem -inform PEM -out MISP2_CA_key.der -outform DER

Certificate file should be put to servers trusted certificates.
For example in apache2 put MISP2_CA_cert.pem to /etc/apache2/ssl folder. Then activate "/usr/bin/c_rehash /etc/apache2/ssl" command in order to rehash certs.