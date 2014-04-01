#!/bin/bash

. clica.sh

(

init_passphrase 

# add commands here, check rebuild.sh for syntax
# you should append each such command into rebuild.sh body.

delete_passphrase

) 2> /dev/null
