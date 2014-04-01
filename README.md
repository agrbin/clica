clica
=====

command line interface certificate authority, scripts for self-signing certificates.
these scripts ressemble small certificate authoritiy manager.

how to
------

this should be ran on a local computer (preferable not connected to internet)

passphrases are echoed on stdout and not kept on disk, you should write them
down somehow.

these nginx confs you may find helpful.

```
ssl            on;
ssl_certificate cert/DEFAULT.com.crt;
ssl_certificate_key cert/DEFAULT.com.key;
ssl_session_timeout 5m;
ssl_protocols SSLv3 TLSv1;
ssl_ciphers
ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv3:+EXP;
ssl_prefer_server_ciphers on;
ssl_client_certificate /etc/nginx/cert/DEFAULT.crt;

ssl_verify_client optional;

fastcgi_param  VERIFIED $ssl_client_verify;
fastcgi_param  DN $ssl_client_s_dn;
```

distribute .p12 and passphrases separately.

inside
------

all functionality is written in
  clica.sh (command line interface certificate authority)

all generated certificates are stored in dir 'ca'.
you can find server certificates in ca/server and client certificates in
ca/client.

rebuild.sh will rebuild everything from scratch backuping 'ca' dir in
backup.%RAND%.

update.sh will add sign new certificates in current 'ca' dir. passphrases are
displayed on stdout and should be written down somewhere.

to enable debug kill "2> /dev/null" in rebuild.sh and update.sh

