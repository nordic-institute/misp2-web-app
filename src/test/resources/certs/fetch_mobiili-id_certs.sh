#!/bin/bash
set -e
set -x

# fetch_mobiili-id_certs.sh  -- Fetch Estonian mobile-ID test certs and prepare the trust store

TRUST_STORE_FILE=mobiili_id_trust_store
TEST_PW=secret

function download_pem {
		local pem_path="$1"
		local pem_url="$2"

		wget -O "$pem_path" "$pem_url"

		local wget_result="$?"
		if [ "$wget_result" != "0" ]
		then
			echo "ERROR: Downloading PEM file '$pem_path' from '$pem_url' failed (code: $wget_result)." >> /dev/stderr
			exit 1
		elif ! (head -n 1 "$pem_path" | grep -q "BEGIN CERTIFICATE")
		then
			echo "ERROR: PEM file '$pem_path' downloaded from '$pem_url' is not in correct format." >> /dev/stderr
			exit 2
		fi
		return 0
	}

function import_pem_crt() {
  local basefilename=$1
  keytool -import -storepass ${TEST_PW} -v -noprompt -trustcacerts \
          -file ${basefilename}_crt.pem -alias ${basefilename} \
          -keystore ${TRUST_STORE_FILE}.jks

}
download_pem  sk_root_2018_crt.pem    https://sk.ee/upload/files/TEST_of_EE-GovCA2018.pem.crt
import_pem_crt sk_root_2018

download_pem  sk_esteid_2018_crt.pem  https://sk.ee/upload/files/TEST_of_ESTEID2018.pem.crt
import_pem_crt sk_esteid_2018

download_pem  sk_esteid_2015_crt.pem  https://www.sk.ee/upload/files/TEST_of_ESTEID-SK_2015.pem.crt
import_pem_crt sk_esteid_2015

download_pem  sk_esteid_2011_crt.pem  https://www.sk.ee/upload/files/TEST_of_ESTEID-SK_2011.pem.crt
import_pem_crt sk_esteid_2011

keytool -importkeystore -srcstorepass ${TEST_PW} -deststorepass ${TEST_PW} -noprompt -srckeystore ${TRUST_STORE_FILE}.jks -destkeystore ${TRUST_STORE_FILE}.p12 \
        -srcstoretype JKS -deststoretype PKCS12