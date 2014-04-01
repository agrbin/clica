#!/bin/bash

. clica.sh

(

  backup
  init_ca

  new_server DEFAULT.com
  new_server dev.DEFAULT.com

  new_client test1 test1@gmail.com
  new_client test2 test2@gmail.com

  delete_passphrase

) 2> /dev/null
