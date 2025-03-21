#!/bin/sh
# Replace placeholders in bundle.js with the actual environment variables
POD_NAME=${MY_POD_NAME:-"unknown-pod"}
POD_IP=${MY_POD_IP:-"unknown-ip"}

# Replace the placeholders in bundle.js
sed -i "s/POD_NAME_PLACEHOLDER/$POD_NAME/g" /usr/share/nginx/html/bundle.js
sed -i "s/POD_IP_PLACEHOLDER/$POD_IP/g" /usr/share/nginx/html/bundle.js

echo "Updated bundle.js with POD_NAME=$POD_NAME and POD_IP=$POD_IP"