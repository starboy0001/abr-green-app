#!/usr/bin/env bash
set -e

KEYSTORE_PATH="android/app/upload-keystore.jks"
CERT_PATH="upload_certificate.pem"
ALIAS="upload"

echo "=== Generating New Upload Keystore ==="
keytool -genkeypair -v -storetype PKCS12 \
  -keystore "$KEYSTORE_PATH" \
  -alias "$ALIAS" \
  -keyalg RSA -keysize 2048 -validity 10000

echo "=== Exporting PEM Certificate for Google Play Console ==="
keytool -export -rfc \
  -keystore "$KEYSTORE_PATH" \
  -alias "$ALIAS" \
  -file "$CERT_PATH"

echo "Done!"
echo "1. Keystore created at: $KEYSTORE_PATH"
echo "2. Certificate for Google Play Console saved at: $CERT_PATH"
