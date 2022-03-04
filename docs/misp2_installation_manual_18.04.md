| ![European Union / European Regional Development Fund / Investing in your future](img/eu_rdf_75_en.png "Documents that are tagged with EU/SF logos must keep the logos until 1.1.2022, if it has not stated otherwise in the documentation. If new documentation is created  using EU/SF resources the logos must be tagged appropriately so that the deadline for logos could be found.") |
| -------------------------: |

# MISP2 Installation and Configuration Guide

Version: 2.19

## Version history <!-- omit in toc -->

 Date       | Version | Description                                                               | Author
 ---------- | ------- | ------------------------------------------------------------------------- | --------------------
 25.05.2021 | 2.13    | Convert from Word to Markdown                                             | Raido Kaju
 17.06.2021 | 2.14    | Update MISP2 package repository info                                      | Petteri Kivimäki
 30.06.2021 | 2.15    | Added information about additional mobileID parameters and upgrade notice | Raido Kaju
 01.07.2021 | 2.16    | Update 3rd party key server                                               | Petteri Kivimäki
 12.07.2021 | 2.17    | Added manual Estonian ID-card installation instructions                   | Raido Kaju
 17.02.2022 | 2.18    | Added instructions on configuring ID-card authentication on `<Location/>` | Raido Kaju
 03.03.2022 | 2.19    | Added instructions on updating EHAK classifiers for Estonian users        | Raido Kaju

## License <!-- omit in toc -->

This document is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
To view a copy of this license, visit <https://creativecommons.org/licenses/by-sa/4.0/>

## Table of content <!-- omit in toc -->

* [1 Introduction](#1-introduction)
* [2 Environment requirements](#2-environment-requirements)
* [3 AdoptOpenJDK 8 installation (recommended)](#3-adoptopenjdk-8-installation-recommended)
* [4 MISP2 installation](#4-misp2-installation)
  * [4.1 Setup package repository](#41-setup-package-repository)
    * [4.1.1 Doing a version upgrade](#411-doing-a-version-upgrade)
  * [4.2 MISP2 database package](#42-misp2-database-package)
  * [4.3 MISP2 application](#43-misp2-application)
    * [4.3.1 Apache Tomcat + Apache HTTP Server + MISP2 base package](#431-apache-tomcat--apache-http-server--misp2-base-package)
    * [4.3.2 MISP2 web application](#432-misp2-web-application)
* [5 Configuration](#5-configuration)
  * [5.1 Configuring an HTTPS certificate for the MISP2 Apache web server](#51-configuring-an-https-certificate-for-the-misp2-apache-web-server)
  * [5.2 MISP2 configuration file](#52-misp2-configuration-file)
  * [5.3 Configuring HTTPS connection between MISP2 application and X-Road Security Server](#53-configuring-https-connection-between-misp2-application-and-x-road-security-server)
  * [5.4 Configuration of Mobile-ID](#54-configuration-of-mobile-id)
    * [5.4.1 Service parameters](#541-service-parameters)
  * [5.5 Other settings](#55-other-settings)
    * [5.5.1 Configuration of the JAVA VM](#551-configuration-of-the-java-vm)
    * [5.5.2 Logging settings](#552-logging-settings)
    * [5.5.3 Adding a HTTPS certificate](#553-adding-a-https-certificate)
  * [5.6 Enabling the Orbeon inspector](#56-enabling-the-orbeon-inspector)
  * [5.7 Configuring support for the Estonian ID-card](#57-configuring-support-for-the-estonian-id-card)
    * [5.7.1 Additional ID-card configuration options](#571-additional-id-card-configuration-options)
  * [5.8 Updating EHAK classifiers to EHAK2021v4](#58-updating-ehak-classifiers-to-ehak2021v4)
* [6 MISP2 administration interface](#6-misp2-administration-interface)
  * [6.1 Administration of MISP2 administrator accounts from the command line](#61-administration-of-misp2-administrator-accounts-from-the-command-line)
  * [6.2 Additions to the Apache web server configuration](#62-additions-to-the-apache-web-server-configuration)
    * [6.2.1 Using the tool](#621-using-the-tool)
    * [6.2.2 Editing manually](#622-editing-manually)
  * [6.3 Portal administration](#63-portal-administration)
    * [6.3.1 Creating portal](#631-creating-portal)
    * [6.3.2 Modifying portal](#632-modifying-portal)
    * [6.3.3 Deleting portal](#633-deleting-portal)
    * [6.3.4 Adding portal manager](#634-adding-portal-manager)
    * [6.3.5 Removing a portal administrator](#635-removing-a-portal-administrator)
  * [6.4 Administration of global XLSs](#64-administration-of-global-xlss)

## 1 Introduction

This document describes the installation and configuration of the MISP2
application.

## 2 Environment requirements

* Supported operating system: Ubuntu Server 18.04 Long-Term Support (LTS),
  64-bit.
* Supported Java version: 8, AdoptOpenJDK 8 is recommended after April 2021.
* Needs connection with an X-Road Security Server (internal interface), which
  has an X-Road setup in place; MISP2 operates through X-Road.
* Recommended hardware requirements: 64-bit processor, 4 GB of RAM
* Optional requirements:
  * OCSP validation service contract with Estonian Certification Center if you
    enable query response signing in MISP2 web application and use OSCP to check
    user certificates during ID-card identification.
  * OCSP responder certificate for OCSP response signature check.

## 3 AdoptOpenJDK 8 installation (recommended)

Ubuntu provides Java via OpenJDK delivery. Support for Java version 8 ends at
April in the OpenJDK delivery. For that reason it`s recommended to install Java
8 from AdoptOpenJDK distribution, where it will be supported until 2026.

AdoptOpenJDK Java 8 installation is described below.

These steps require root privileges. These can be gained using the following
command:

```bash
sudo -i
```

Import the AdoptOpenJDK GPG key:

```bash
wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | sudo apt-key add -
```

Configure AdoptOpenJDK's apt repository:

```bash
echo "deb https://adoptopenjdk.jfrog.io/adoptopenjdk/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/adoptopenjdk.list
```

Install the Java runtime environment and set it as the default java:

```bash
sudo apt-get update
sudo apt install adoptopenjdk-8-hotspot-jre
sudo update-java-alternatives -s adoptopenjdk-8-hotspot-jre-amd64
```

Then add it as tomcat8 default Java installation:

```bash
update-java-alternatives -l | cut --delimiter=" " --fields=9 | xargs -I{} sudo echo "JAVA_HOME={}" >> /etc/default/tomcat8
```

After that the MISP2 will use the AdoptOpenJDK Java after installation

## 4 MISP2 installation

This chapter describes the installation of MISP2 portal components. Installation
requires root privileges. These can be gained using the following command:

```bash
sudo -i
```

### 4.1 Setup package repository

Add the MISP2 repository’s signing key to the list of trusted keys:

```bash
wget -qO - https://artifactory.niis.org/api/gpg/key/public | apt-key add -
```

The following information can be used to verify the key:

* key hash: `935CC5E7FA5397B171749F80D6E3973B`
* key fingerprint: `A01B FE41 B9D8 EAF4 872F  A3F1 FB0D 532C 10F6 EC5B`
* 3rd party key server: [Ubuntu key server](https://keyserver.ubuntu.com/pks/lookup?search=0xfb0d532c10f6ec5b&fingerprint=on&op=index)

Add MISP2 package repository:

```bash
apt-add-repository "https://artifactory.niis.org/xroad-extensions-release-deb main"
```

The package list should then be updated with the command:

```bash
apt-get update
```

#### 4.1.1 Doing a version upgrade

Due to a known issue in the installation package, please perform the following
action after upgrading your MISP2 installation:

* Open the file /var/lib/tomcat8/webapps/misp2/WEB-INF/classes/config.cfg.
* Uncomment the line mobileID.rest.trustStore.path = MOBILE_ID_TRUST_STORE_PATH
  by removing the # symbol from the beginning of the line (the value can remain
  as is).

### 4.2 MISP2 database package

The MISP2 database package `xtee-misp2-postgresql` is installed with default
settings using the command:

```bash
apt-get install xtee-misp2-postgresql
```

Below is a list of questions and answers displayed after this command is run.
The default role i.e. username is `misp2` and only the password is queried.

```text
Creating database 'misp2db'
Enter password for new role: 
Enter it again:
```

The same password is needed again during MISP2 application installation.

### 4.3 MISP2 application

Install the package `xtee-misp2-application`.

```bash
apt-get install xtee-misp2-application
```

This package is dependent on the `xtee-misp2-base` and `xtee-misp2-orbeon`
packages, which, in turn, are dependent on the `apache2`, `libapache2-mod-jk`,
and `tomcat8` packages. These packages will be installed automatically.

The installation utility will ask a number of questions, which will be explained
in the chapters below.

#### 4.3.1 Apache Tomcat + Apache HTTP Server + MISP2 base package

If you installed the alternative AdoptOpenJDK, as instructed above, you will be
presented question about `/etc/default/tomcat8`.

```bash
tomcat8: A new version (...) of configuration file /etc/default/tomcat8 is available, but the version 
installed currently has been locally modified.

What do you want to do about modified configuration file tomcat8?
```

Select that you want to “keep the local version currently installed”.

Overview of operations performed by the installation package:

1. Configures memory for Tomcat in the file `/etc/default/tomcat8`:

   ```bash
   JAVA_OPTS="${JAVA_OPTS} –Xms512m –Xmx512m -XX:MaxPermSize=256m"
   ```

2. Opens the Tomcat AJP connector on port 8009: removes comment symbols from the
   line `<Connector port="8009" protocol="AJP/1.3" redirectPort="8443" />` in
   the Tomcat configuration file `server.xml`.
3. Prohibits access to the Tomcat port 8080 in the server.xml configuration
   file.
4. Creates the mod_jk configuration file and stores it in the
   `/etc/apache2/mods- available` directory (see the supplied example file:
   jk.conf) and adds the corresponding link in the `/etc/apache2/mods-enabled`
   directory (e.g.: `a2enmod jk`).
5. In addition, activates the following modules: rewrite (`a2enmod rewrite`),
   ssl (`a2enmod ssl`), headers (`a2enmod headers`) and proxy_http (– the proxy
   module required for proxy_http is activated automatically).
6. Creates a virtualhost using an SSL connection in the Apache configuration
   file.
7. Allows only SSL connections: redirects HTTP connections to HTTPS (443) port
   (to 4443 in the case of software-initiated queries).
8. Configures the mod_jk module in the Apache configuration file.
9. Installs the HTTPS server (generated) certificates.
10. Estonian ID-card root certificates, and the Mobile-ID security certificate
    if estonian installation is selected.
11. InstallsthecertificatesofrevocationlistsandOCSPquery.
12. Restarts Apache (`apache2ctl restart`).

Configuration files and directories installed:

* /etc/apache2/sites-available/ssl.conf
* /etc/apache2/ssl/
* /etc/apache2/ssl/create_server_cert.sh
* /etc/apache2/ssl/create_ca_cert.sh
* /etc/apache2/ssl/cleanXFormsDir.sh
* /etc/apache2/ssl/create_sslproxy_cert.sh
* /etc/apache2/ssl/updatecrl.sh
* /var/lib/tomcat8/conf/server.xml

#### 4.3.2 MISP2 web application

Answer `y` to the next question to configure MISP2 as an international (EU)
version or `n` to configure it as an Estonian version (see below for the
configuration parameters corresponding to each):

```bash
Configure international version instead of Estonian? [y/n] [default: n]:
```

In the case of the international version, the following configuration is used:

```properties
languages = en
countries = GB
auth.IDCard=false
auth.certificate=true
xrd.namespace=http://x-road.eu/xsd/x-road.xsd
```

In the case of the Estonian version, the following configuration is used:

```properties
languages = et
countries = EE 
xrd.namespace=http://x-road.ee/xsd/x-road.xsd
```

The next question will ask for the following MISP2 database parameters: database
server IP, port, database name, database username, and password. In general, all
the default values fit, except for the database password.

NB! These parameters must match the ones given during xtee-misp2-postgresql
package installation.

```bash
Please provide a database host IP to be used [default: 127.0.0.1]:
Please provide a database port to be used [default: 5432]:
Please provide a database name to be used [default: misp2db]:
Please provide a username to be communicating with the database [default: misp2]:
Please enter a password for the database user 'misp2':
```

Answer `y` to the following question to enable Estonian mobile-ID authentication
(also assumes a respective service contract):

```bash
Do you want to enable authentication with Mobile-ID? [y/n]
```

When answering `yes` to the previous question, a mobile-ID service UUID and name
must be entered:

```bash
Please provide your Mobile-ID relying party UUID: (format: 00000000-0000-0000-0000-000000000000)
Please provide your Mobile-ID relying party name:
```

Next, e-mail related parameters are specified (SMTP server address, e-mail
address used by MISP2):

```bash
Please provide a SMTP host address [default: smtp.domain.ee]: 
Please provide a server email address: [default: info@domain.ee]:
```

In the case of the international version, the user is also asked to provide
X-Road version 6 instances and member classes. Both must be provided in a comma
separated list.

```bash
Please provide x-road v6 instances (comma separated list)? [default: eu-dev,eu- test,eu]
Please provide x-road v6 member classes (comma separated list)? [default: COM,NGO,GOV]
```

After installing the web application you can proceed to configure MISP2
administrator account and IP addresses from where administrator web interface
can be accessed as described in Section
[6.1](#61-administration-of-misp2-administrator-accounts-from-the-command-line)
of this guide.

In a production environment, the particular institution’s certificate should
also be added to the Apache HTTP server to allow for HTTPS connections. This is
described in Section
[5.3](#53-configuring-https-connection-between-misp2-application-and-x-road-security-server)
of this guide.

If the Estonian ID-card based authentication needs to be supported, please read
Section [5.7](#57-configuring-support-for-the-estonian-id-card) of this guide.

## 5 Configuration

### 5.1 Configuring an HTTPS certificate for the MISP2 Apache web server

During initial installation, a self-signed certificate is generated for the
Apache HTTP server. In a production environment, it is advisory to replace this
with an actual CA- issued certificate.

By default, Apache uses the following certificate files:

```properties
 SSLCertificateFile /etc/apache2/ssl/httpsd.cert 
 SSLCertificateKeyFile /etc/apache2/ssl/httpsd.key
```

It is recommended to use the same filenames for your own certificates and use
these to replace the default files (changing the apache configuration file is
not recommended, as it is overwritten when MISP2 is updated, which can cause
changes to be lost). The contents of the DH parameter file
(`/etc/apache2/ssl/dhparams.pem`) should also be added at the end your
certificate file (`httpsd.cert`).

### 5.2 MISP2 configuration file

The MISP2 installation script will configure the database connection and other
parameters in the `config.cfg` configuration file. After installation, some
parameters can be changed in the configuration file. By default, its location
is:

```bash
/var/lib/tomcat8/webapps/misp2/WEB-INF/classes/config.cfg
```

Below is a list of some parameters which, though automatically set during
installation, may later need to be changed when the application is reconfigured.

**NB!** Due to a known issue in the installation package, please perform the
following action after completing your MISP2 installation:

* Open the file `/var/lib/tomcat8/webapps/misp2/WEB-INF/classes/config.cfg`.
* Uncomment the line `mobileID.rest.trustStore.path =
  MOBILE_ID_TRUST_STORE_PATH` by removing the `#` symbol from the beginning of
  the line (the value can remain as is).

After the configuration file is changed, tomcat must always be restarted using
the command:

```bash
service tomcat8 restart
```

Parameters for establishing a connection with a database server:

```properties
# DB Info – database server and user parameters 
jdbc.driver=org.postgresql.Driver 
jdbc.url=jdbc:postgresql://IP/DB-NAME 
jdbc.username=USERNAME
jdbc.password=PASSWORD
jdbc.databasePlatform=org.hibernate.dialect.PostgreSQLDialect
```

Language and country parameters:

```properties
# Languages to which the user is allowed to switch and in which can descriptions be set for different elements. Defined in http://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
# If no suitable languages are defined, then the system will use the default locale language
languages = et
# Countries which can be as the user’s country. Defined in http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
# If no suitable countries are defined, then the system will use the default locale country
countries = EE
```

Server ID-card parameters (for server-side digital signing and encryption):

```properties
# ID Card and its usage settings 
digidoc.config_file=jar://JDigiDocID.cfg
digidoc.PIN2=01497

email.allow.sign_query=false
email.allow.encrypt_query=false
```

Mail server parameters:

```properties
email.host = mailserver.domain.ee
email.sender.name = MISP2 Support 
email.sender.email = info@asutus.ee
```

Mobile-ID authentication setup parameters:

```properties
# Mobile ID and its usage settings 
mobileID.digidocServiceURL = https://digidocservice.sk.ee/ 
mobileID.serviceName = Testimine
mobileID.rest.trustStore.password = CHANGEME
mobileID.rest.trustStore.path = MOBILE_ID_TRUST_STORE_PATH
```

### 5.3 Configuring HTTPS connection between MISP2 application and X-Road Security Server

The steps for configuring HTTPS:

1. Export the Security Server’s certificate file `certs.tar.gz` from the
   Security Server (see Chapter 9 of the X-Road 6 Security Server user guide: `9
   Communication with the Client Information Systems`) and copy it to the MISP2
   server’s `/usr/xtee/apache2/` directory. The name of the certificate for
   X-Road v6 Security Server is `certs.tar.gz`.
2. Run the configuration script on the MISP2 server:

   ```bash
   /usr/xtee/app/create_https_certs_security_server.sh
   ```

   The script checks for the existence of the certs.tar.gz or `proxycert.tar.gz`
   security certificate archives in the MISP2 server’s `/usr/xtee/apache2/`
   directory, creates key repository misp2truststore.jks, generates the
   certificate for communication with the Security Server, installs the private
   key and certificate obtained in the `misp2keystore.jks` key repository,
   creates the key repository and imports the PKCS12 file obtained, sets the
   necessary system parameters for the MISP2 server in the Tomcat configuration
   file `/etc/default/tomcat8`, and restarts Tomcat.

   The script uses following prompting when started: If the file has been copied
   to the MISP2 server, the user should answer `y`. Answer `n` if you wish to
   cancel the operation, in which case the HTTPS configuration can be performed
   again later as described in chapter [4.3](#43-misp2-application).

   ```bash
   Please add the Security Server certificate archive 'certs.tar.gz' to the MISP2 server directory '/usr/xtee/apache2/'.

   Proceed with HTTPS configuration? (Answering 'no' means that HTTPS configuration will not be done this time) [y/n] [default: n]
   ```

   Once this has been completed, the passwords for the truststore and keystore
   certificate repositories must be entered. These must be at least 6 characters
   long. The passwords will not be displayed while typing.

   ```bash
   Enter the truststore password: 
   Enter the keystore password:
   ```

   When the Security Server’s certificate is added to the certificate
   repository, the user will be asked if they trust the certificate. You should
   answer yes.

   ```bash
   Trust this certificate? [no]: yes
   ```

   The installation script will then generate a MISP2 certificate file and
   display its location to the user.

   ```bash
   Get '/usr/xtee/app/cert.cer' and add it to your Security Server.
   ```

   The certificate file (`/usr/xtee/app/cert.cer` in this example) should be
   copied to the Security Server.
3. Configure the Security Server to use HTTPS to connect to the information
   system and add the certificate generated in step 2 (for X-Road v6
   `/usr/xtee/app/cert.cer`) to the Security Server (see the Security Server’s
   user manual for additional instructions).
4. Open the administrator interface of the MISP2 portal and change the address
   of the institution’s Security Server and the address of sending queries
   options from HTTP→HTTPS. If the Security Server’s IP or domain name is
   `SEC_SERVER_IP`, then replace:
     * http://SEC_SERVER_IP → https://SEC_SERVER_IP
     * http:// SEC_SERVER_IP/cgi-bin/consumer_proxy → https://
       SEC_SERVER_IP/cgi-bin/consumer_proxy

### 5.4 Configuration of Mobile-ID

#### 5.4.1 Service parameters

Before moving forward with the configuration, create a `p12` trust store
containing the correct certificate based on the documentation provided in [SK-s
JAVA client source
repository](https://github.com/SK-EID/mid-rest-java-client#how-to-obtain-server-certificate).

Once the trust store is created, move it to the
`/var/lib/tomcat8/webapps/misp2/WEB-INF/classes` folder and update the file
permissions so that it is accessible by the system user `tomcat8`. This can be
done with the following command:

```bash
# In this example, the truststore was created with the name mid_trust_store.p12
sudo chown tomcat8:tomcat8 mid_trust_store.p12
```

In the configuration file, parameters `mobileID.rest.relyingPartyUUID` and
`mobileID.rest.relyingPartyName` must be set up with the correct value. The
Certification Centre ([SK ID
Solutions](https://www.skidsolutions.eu/en/services/mobile-id/technical-information-mid-rest-api/))
assigns the respective service name value to every institution.

The parameters `mobileID.rest.trustStore.password` and
`mobileID.rest.trustStore.path` should be updated so that the path variable
refers to the trust store created before (e.g `/mid_trust_store.p12`) and
password contains the key needed to access it.

### 5.5 Other settings

#### 5.5.1 Configuration of the JAVA VM

If required, Java system parameters can be modified in the file
`/etc/default/tomcat8`.

The installation script configures the memory usage parameters as follows but
increase the values provided, if required, for example:

```bash
JAVA_OPTS="${JAVA_OPTS} –Xms2048m –Xmx2048m-XX:MaxPermSize=256m"
```

#### 5.5.2 Logging settings

Logging settings are set in the file
`/var/lib/tomcat8/webapps/misp2/WEB-INF/classes/log4j2.xml`

The mainly used properties in the file are `<Root level="info">`, `<Logger
name="org.hibernate" level="info" additivity="false">`, and `<Logger
name="ee.aktors.misp2" level="info" additivity="false">`.

If there is a need to see more information in the log, set the level of these
parameters as DEBUG.

For example, instead of `<Root level=”info”>` use `<Root level="debug">`

#### 5.5.3 Adding a HTTPS certificate

HTTPS certificates can be added using the keytool command.

```bash
keytool -import -keystore /etc/ssl/certs/java/cacerts -storepass changeit -file [CERT_PATH] -alias
[CERT_ALIAS]
```

Restart the Tomcat service for the changes to take affect.

```bash
service tomcat8 restart
```

### 5.6 Enabling the Orbeon inspector

The inspector (Orbeon inspector) is an Orbeon module, which allows the user to
inspect X-Road messages and other application data sent and received by
services.

In MISP2, the inspector can be enabled by changing the value of the
`oxf.epilogue.xforms.inspector` parameter in the
`/var/lib/tomcat8/webapps/orbeon/WEB-INF/resources/config/properties-local.xml`
file.

By default, after MISP2 installation this line is set to false.

To enable the inspector, its value needs to be true:

```xml
<property as="xs:boolean" name="oxf.epilogue.xforms.inspector" value="true"/>
```

Once changed, the file must be saved and the inspector should appear in the
interface.

The Tomcat server does not need to be restarted.

### 5.7 Configuring support for the Estonian ID-card

In order to configure the Estonian ID-card based authentication to work
properly, please complete the following steps after the package has been
installed (if you have upgraded from version 2.5.0 and had the ID-card
previously set up, only step 6 is required):

These steps require root privileges. These can be gained using the following
command:

```bash
sudo -i
```

1. Download the required certificates from the Certificate Authority:

    ```bash
    cd /etc/apache2/ssl
    wget -O sk_root_2011_crt.pem https://www.sk.ee/upload/files/EE_Certification_Centre_Root_CA.pem.crt
    wget -O sk_root_2018_crt.pem https://c.sk.ee/EE-GovCA2018.pem.crt
    wget -O sk_esteid_2011_crt.pem https://www.sk.ee/upload/files/ESTEID-SK_2011.pem.crt
    wget -O sk_esteid_2015_crt.pem https://www.sk.ee/upload/files/ESTEID-SK_2015.pem.crt
    wget -O sk_esteid_2018_crt.pem https://c.sk.ee/esteid2018.pem.crt
    ```

2. Create the `client_ca` folder under `/etc/apache2/ssl` install the
   certificates there with the following commands:

    ```bash
    mkdir client_ca
    cp -v sk_esteid_2011_crt.pem sk_esteid_2015_crt.pem sk_esteid_2018_crt.pem client_ca/
    openssl x509 -addtrust clientAuth -trustout -in sk_esteid_2011_crt.pem -out sk_esteid_2011_client_auth_trusted_crt.pem
    openssl x509 -addtrust clientAuth -trustout -in sk_esteid_2015_crt.pem -out sk_esteid_2015_client_auth_trusted_crt.pem
    openssl x509 -addtrust clientAuth -trustout -in sk_esteid_2018_crt.pem -out sk_esteid_2018_client_auth_trusted_crt.pem
    rm sk_esteid_2011_crt.pem sk_esteid_2015_crt.pem sk_esteid_2018_crt.pem
    c_rehash client_ca/
    ```

3. Install the root certificates by running the following commands under
   `/etc/apache2/ssl`:

    ```bash
    openssl x509 -addreject clientAuth -trustout -in sk_root_2011_crt.pem -out sk_root_2011_CA_trusted_crt.pem
    openssl x509 -addreject clientAuth -trustout -in sk_root_2018_crt.pem -out sk_root_2018_CA_trusted_crt.pem
    rm sk_root_2011_crt.pem sk_root_2018_crt.pem
    ```

4. Install the OCSP certificate by running the following command under
   `/etc/apache2/ssl`:

    ```bash
    wget -O sk_esteid_ocsp.pem https://www.sk.ee/upload/files/SK_OCSP_RESPONDER_2011.pem.cer
    ```

5. Update the CRL and rehash Apache symbolic links under `ssl` by running the
   following commands under `/etc/apache2/ssl`:

    ```bash
    ./updatecrl.sh "norestart"
    c_rehash ./
    ```

6. Open the file `/etc/apache2/sites-enabled/ssl.conf` and change the parameter
   `SSLCADNRequestPath` on line 164 to be the following (be sure to also remove
   the `#` from the beginning so that it isn't commented out):

    ```properties
    SSLCADNRequestPath /etc/apache2/ssl/client_ca/
    ```

7. After the configuration file is changed, Apache must be restarted using the
   following command:

    ```bash
    service apache2 restart
    ```

#### 5.7.1 Additional ID-card configuration options

It should be noted that the default configuration is set up so that the authentication certificate is requested on the
root of the application. This means that the session does not get terminated until the user has closed the browser
tab or navigated to a different webpage. If they do not do so, it might be possible to log in again without having the
ID-card in the reader (hence why the system shows a message asking the user to close the browser window after logging
out). If this behaviour is not appropriate for your use-case, it is possible to configure the `apache2` proxy in such a
way that the certificate request and renegotiation happens as a result of the ID-card login action itself.
To do this, please follow these steps:

* Open the `apache2` configuration file located at `/etc/apache2/sites-enabled/ssl.conf` with your preferred text
editor.
* Modify the line (160) `SSLProtocol All -SSLv2 -SSLv3` so that it reads `SSLProtocol -all +TLSv1.2` instead.
* Remove the following lines from the block `<VirtualHost *:443>`:
  * (line 168) SSLOptions +StdEnvVars +ExportCertData
  * (line 169) SSLVerifyClient optional
* Add the following `<Location>` block inside the `<VirtualHost *:443>` block:

```xml
<Location "/*/IDCardLogin.action">
  SSLVerifyClient require
  SSLOptions +StdEnvVars +ExportCertData
</Location>
```

* Reload the configuration: `service apache2 reload`.

**NB!** It should be noted that this approach configures the server so that it will only use TLS 1.2 and not TLS 1.3.
This is due to browsers currently not supporting `post-handshake authentication` that is required for this to work:

* https://bugs.chromium.org/p/chromium/issues/detail?id=911653
* https://bugzilla.mozilla.org/show_bug.cgi?id=1511989

### 5.8 Updating EHAK classifiers to EHAK2021v4

**NB!** The current EHAK classifiers in MISP2 are specific to Estonia, if you are using MISP2 in another country or are
not using the classifiers, you do not need to run the update.

To update the EHAK classifiers in the database, please follow these steps:

* Download the update file [EHAK2021v4.sql](./EHAK2021v4.sql) and move it to an appropriate location on the MISP2
  server
* Execute the following command on the server: `psql -p 5432 misp2db -U postgres -f /path/to/EHAK2021v4.sql`
  * If you chose a different database name during installation, substitue `misp2db` with that. If you are unsure, the
    details can be checked from `/var/lib/tomcat8/webapps/misp2/WEB-INF/classes/config.cfg`

## 6 MISP2 administration interface

Append `/admin` to the portal URL to enter the administration interface. For
example: `https://<portaali_aadress>/misp2/admin/`.

Before accessing the administration interface admin account needs to be created
and access to the interface has to be enabled from authorized ip-adresses in
apache web server configuration.

### 6.1 Administration of MISP2 administrator accounts from the command line

There is a tool for administrating the administrator accounts of the MISP2
application. This tool is launched from the command line as follows:

```bash
/usr/xtee/app/admintool.sh
```

The list of existing administrator accounts is displayed by default.

Add the `-add` parameter to the command line to add an administrator account:

```bash
/usr/xtee/app/admintool.sh -add
```

Add the `-delete` parameter to the command line to delete the administrator
account:

```bash
/usr/xtee/app/admintool.sh -delete
```

### 6.2 Additions to the Apache web server configuration

When administrator account has been created according to previous section, you
need to specify allowed IP addresses from where the admin web interface can be
accessed.

#### 6.2.1 Using the tool

This is done by modifying the Apache configuration file, but there is also a
tool for that. It provides you with good defaults. The tool can be started:

```bash
/usr/xtee/app/configure_admin_interface_ip.sh
```

Tool shows the current setting, and proposes to add ip address from where the
terminal is ssh accessed. Just press enter to accept the proposal and script
will restart apache2 for the change to take effect. Further options for the tool
usage can be obtained using:

```bash
/usr/xtee/app/configure_admin_interface_ip.sh help
```

#### 6.2.2 Editing manually

If you wish to change or edit the IP addresses allowed to access the
administrator interface, you can edit the Apache configuration file:

```bash
vi /etc/apache2/sites-available/ssl.conf
```

Find the following lines in this file:

```properties
<Location "/*/admin/*"> 
  Order deny,allow 
  Deny from all
  Allow from 127.0.0.1
</Location>
```

Add the address of your own computer `<Location>` to the end of the line below,
e.g.:

```bash
Allow from 127.0.0.1 192.168.215.233
```

Restart the web server:

```bash
/etc/init.d/apache2 restart
```

### 6.3 Portal administration

This chapter describes the administration of a portal in the MISP2 web
application.

#### 6.3.1 Creating portal

Enter the administration interface to create a portal. A form containing the
following fields is displayed to create a new portal:

* **Portal name** * – the name of the portal
* **Portal short name** * – a short name for the portal used to identify the
  portal for the application and saving the history of activities. The short
  name of the portal must be unique within the application.
* **Organization name** * and **Organization code** * are the name and the
  registry code of the main institution associated with the portal. The registry
  code of the main institution is included with every query. If the registry
  code of the main institution corresponds to an existing institution in the
  application, the portal is associated with the existing institution and the
  existing institution name is overwritten with the name entered last. X-Road
  version 6 also uses the institution’s registry code as the member code in the
  header of an X-Road query (xrd:client/iden:memberCode).
* **Portal type** – indicates the type of portal. Portal types are described in
  more detail in Chapter 1 of the user's guide. Possible options are as follows:
  * Open services portal
  * Organization's portal
  * Universal portal
* **X-Road protocol version** determines the message format for the portal’s
  users and meta services. This is used when communicating with the X-Road
  Security Server. It should always be set to 4.0 (X-Road version 6).
* **X-Road member class** – a configuration parameter, which determines the
  general category of the X-Road client, i.e. whether it is a government
  institution (GOV), commercial institution (COM) or some other kind of
  institution. The option becomes available if X-Road has been configured to use
  protocol 4.0. The parameter is included in the header of X-Road queries in the
  xrd:client/iden:memberClass line.
* **X-Road subsystem code** – a configuration parameter, which allows for the
  differentiation of various X-Road client and server applications within the
  same institution. The option becomes available if X-Road has been configured
  to use protocol 4.0. The parameter is included in the header of X-Road queries
  in the xrd:client/iden:subsystemCode line.
* **Security host** * – the address of your Security Server.
* **X-Road client instance** – a configuration parameter of X-Road version 6,
  which determines the X-Road environment used, e.g. ee-dev and EE denote the
  Estonian X-Road development environment and production environment,
  respectively. The option becomes available if X-Road has been configured to
  use protocol 4.0. The parameter is included in the header of X-Road queries in
  the xrd:client/iden:xRoadInstance field.
* **X-Road instances for services** – can be used to select from a predetermined
  list which X-Road instances are used when services are updated in the portal
  manager. Based on this selection, the manager can determine which X-Road
  instance services are included in the manager’s interface.

  By default, the list of instances is loaded from the portal’s configuration
  file.

  Pressing `load instances from Security Server` will add all federated X-Road
  instances from the X-Road security server to the list. After this, they can be
  used in the portal.

  Pressing `load default instances` will reload the list of instances from the
  configuration file.

  The service instance is included in X-Road queries in the
  xrd:service/iden:xRoadInstance line.
* **Services sending address** * – the address of the server through which all
  queries pass
* **Developer view** – if set to `On`, adds an `add database` (add database
  manually) button to the `Services` section of the service- or portal manager.
  A `From WDSL` button is added to the database subsection. This allows for a
  list of services to be updated by using WSDL.
* **Send audit log to Security Server** – determines whether a logOnly request
  will be sent to the Security Server, so that actions logged in the MISP2
  application are also included in the Security Server’s logs. The `logOnly`
  service data must also be entered: `logOnly` service member class, `logOnly
  service member code` and `logOnly service subsystem code`. These fields are
  only displayed in the administrator portal if X-Road version 6 is used.

  To start the `logOnly.v1` service, the `misp2-soap-service-v6.war` addon
  module is included in MISP2, which the manager can run in its environment.
  This is described in further detail in the installation guide for addon
  modules.
* **Topics in use** – if this is marked, services will be grouped for users
  according to topics. Portal administrator deals with topics administration.
  Topics administration will be discussed in another chapter. If topics are not
  used, services will be grouped per database as usual.
* **The folder field is used in the input of the service** – this field is no
  longer used in the lastest version of X-Road

After entering all of the required data, click on `Save portal configuration`.
The portal data is written to the database as a result.

Portal administration is somewhat different in the case of a universal portal.

The following fields must be completed for a universal portal in addition to the
standard fields:

* **Unit registering is allowed** – a check box indicating whether the
  registration of new units by users is allowed in the application. If marked,
  the following fields marked with ** must be filled in.
* **Auth query service name** ** – the name of the meta query used to check the
  unit’s representation rights. The protal presents the user with a selection of
  services previously defined in the configuration file. In a universal portal,
  services are defined in the `uniportal-conf.cfg` file. In a legal person
  portal, the services for sending queries to determine the right of
  representation are defined in the `orgportal-conf.cfg` file.
* **Check query service name*** – the name of the query used to check the unit’s
  validity. The portal presentsthe user with a selection of services previously
  defined in the `uniportal-conf.cfg` configuration file.
* **Auth query control time (hours)** ** – the period of time after which a new
  query must be performed as the validity of the old query ends.
* **Auth query maximum control time (hours)** ** – the maximum time period
  allowed during which users can perform queries related to an institution’s
  rights if the check query does not respond.* **Use permission manager** – if
  checked, the `user with representation rights` section will include an `access
  rights manager` menu option, provided that the current role has been accessed
  via the `registrar` role. If it has been accessed via the `portal manager`
  role, this option is always visible. Using this menu option, users with
  representation rights can assign query-performing rights to access rights
  managers and users in the course of registering a new unit. Otherwise,
  assigning managers is not allowed. This field is also displayed for legal
  person portals, as they are a sub- type of the universal portal. Note that for
  legal person portals this value is valid only if institutions have rights of
  exclusive representation.
* **Portal unit is X-Road organization** – if selected, the code of the active
  unit is included in service message headers in the `consumer` field. If left
  unselected, the code of the main institution is included in service message
  headers in the `consumer` field and the code of the active unit is included in
  the `unit` field.

#### 6.3.2 Modifying portal

Enter the administrator interface to modify a portal. The portal registered to
you is displayed. Click on `Save portal configuration` to save the changes. You
cannot change the portal type. To do this, you must delete the existing portal
and add a new one. The registry code of the main institution associated with the
portal cannot be changed.

#### 6.3.3 Deleting portal

You can delete a portal via the administration interface by clicking on `Remove
portal` on the portal administration form. The portal and all objects associated
with it are removed from the application if this button is pressed.

#### 6.3.4 Adding portal manager

Click on `Add new manager` on the portal configuration form to add a portal
administrator. As a result, you will be directed to the managers view, where you
can search for users from existing user accounts and add new portal managers. To
add one, the portal in question must first be saved.

The mandatory fields – personal identification code and family name – must be
filled in when adding a new administrator. The e-mail address and job title are
associated with the main institution and will not include subsequently added
units.

Click on `Add manager` after filling in the user form. The user is then granted
the roles of portal administrator and standard user of the main institution. The
`Remove user` button removes the user and all relationships of this user to
institutions and groups.

If a user search is used, a search is conducted among all system users to find
those matching the entered parameters. The matches found are then listed.

Clicking on a user’s name opens the edit user form filled in with the data of
the selected user, whereas the e-mail address and job title are associated with
the main institution.

Clicking on `Add as manager` immediately adds the user as a portal
administrator.

#### 6.3.5 Removing a portal administrator

Use the portal configuration form to remove a portal administrator. This form
includes the list of existing administrators.

The user is removed from the portal administrator role by clicking on the X-icon
in the administrator’s row.

### 6.4 Administration of global XLSs

In addition to managing the portal, administrator rights also include the adding
and administration of global XSLs used by the portal. Global XSLs are XSLs
applied last to all queries according to priorities. The administration of
global XSLs is similar to the administration of XSLs internal to the portal.
(See the description of the service administrator role in the User’s Guide.)
