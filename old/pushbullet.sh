# pushbullet v0.1 06/12/2014 by Fanfan Lefou
# Script using Pushbullet API for sending note notification with Curl request
# Call the script with 2 arguments: arg1: note title, arg2: note body 




#!/bin/bash


# var statement
v_apikey='8R301A2cEC1FkMTPHhOCCHMQvrxlnMMq'
v_URL="https://api.pushbullet.com/v2/pushes"
v_URL_header='Content-Type: application/json'
v_URL_data="{\"type\": \"note\", \"title\": \"$1\", \"body\": \"$2\"}"


# main block
sudo curl -u $v_apikey: -X POST $v_URL --header "$v_URL_header" --data-binary "$v_URL_data"

exit 0