#!/bin/bash
CA=DEFAULT

root=/etc/ssl/$CA/ca
umask 0077

defaults=$(cat << EOF
/countryName=HR\
/stateOrProvinceName=Grad Zagreb\
/localityName=Zagreb\
/organizationName=clica example
EOF
)

default_email="test1@example.com"

function backup  {
  rand=$(openssl rand -hex 5)
  dir=$root/..
  mkdir $dir/backup.$rand
  mv $root $dir/backup.$rand 2> /dev/null
  rmdir $dir/backup.$rand 2> /dev/null # will fail if not empty
}

function random_pass {
  openssl rand -out $1 -base64 5
}

function init_ca {
  mkdir -p $root $root/server $root/client $root/newcerts

  # gen random passphrase
  random_pass $root/passphrase.txt

  # create private key for CA
  openssl genrsa \
    -des3 \
    -passout file:$root/passphrase.txt \
    -out $root/$CA.key \
    1024

  # create certificate for CA
  openssl req \
    -new \
    -subj "$defaults/commonName=Anton Grbin/emailAddress=$default_email" \
    -passin file:$root/passphrase.txt \
    -key $root/$CA.key -x509 \
    -days 1095 \
    -out $root/$CA.crt

  # init db.
  echo "01" > $root/serial
  touch $root/index.txt
}

function init_passphrase {
  echo -n Enter passphrase:
  read -s pass
  echo
  echo $pass > $root/passphrase.txt
}

function new_server {
  # assert number of args is one
  if [ $# -ne 1 ]; then
    echo "One argument, the server name"
    exit
  fi

  rm -rf $root/server/$1
  mkdir $root/server/$1
  cd $root/..

  # generatep private key
  openssl genrsa\
    -out $root/server/$1/$1.key 1024

  # create sign request
  openssl req -new\
    -subj "$defaults/commonName=$1/emailAddress=$default_email" \
    -key $root/server/$1/$1.key\
    -out $root/server/$1/$1.csr

  # sign the key
  openssl ca \
    -in $root/server/$1/$1.csr \
    -cert $root/$CA.crt \
    -batch \
    -keyfile $root/$CA.key \
    -passin file:$root/passphrase.txt \
    -out $root/server/$1/$1.crt

  # concatenate everything to .pem file, for servers
  cat \
    $root/server/$1/$1.key \
    $root/server/$1/$1.crt \
    $root/$CA.crt \
    >> \
      $root/server/$1/$1.pem
}

function new_client {
  # assert number of args is one
  if [ $# -ne 2 ]; then
    echo "two arguments, client username and email"
    exit
  fi
  username=$1
  email=$2
  cd $root/..

  rm -rf $root/client/$1
  mkdir $root/client/$1

  # gen random passphrase
  random_pass $root/clientpass.txt

  # generatep private key
  openssl genrsa \
    -passout file:$root/clientpass.txt \
    -out $root/client/$1/$1.key 1024

  # create sign request
  openssl req -new \
    -subj "$defaults/commonName=$1/emailAddress=$email" \
    -key $root/client/$1/$1.key \
    -passin file:$root/clientpass.txt \
    -out $root/client/$1/$1.csr

  # sign the key
  openssl ca \
    -in $root/client/$1/$1.csr \
    -cert $root/$CA.crt \
    -batch \
    -keyfile $root/$CA.key \
    -passin file:$root/passphrase.txt \
    -out $root/client/$1/$1.crt

  # concat to p12
  openssl pkcs12 \
    -export -clcerts \
    -in $root/client/$1/$1.crt \
    -inkey $root/client/$1/$1.key \
    -password file:$root/clientpass.txt \
    -out $root/client/$1/$1.p12

  echo -n "$1 has passphrase (gone now): "
  cat $root/clientpass.txt
  rm $root/clientpass.txt
}


function delete_passphrase {
  echo
  echo -n "CA private key passphrase is (gone now): "
  cat $root/passphrase.txt
  rm $root/passphrase.txt
}

