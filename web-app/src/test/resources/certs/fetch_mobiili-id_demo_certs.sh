#!/bin/bash
set -e
set -x

# fetch_mobiili-id_demo_certs.sh  -- Fetch Estonian mobile-ID test certs and prepare the trust store

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

function import_root() {
  local basefilename=$1
  keytool -import -storepass ${TEST_PW} -v -noprompt -trustcacerts \
          -file ${basefilename}.pem.cer -alias ${basefilename} \
          -keystore ${TRUST_STORE_FILE}.jks

}

rm -f ${TRUST_STORE_FILE}.jks
rm -f ${TRUST_STORE_FILE}.p12

download_pem tsp_demo_sk_ee.pem.cer https://www.skidsolutions.eu/upload/files/tsp_demo_sk_ee.pem
import_root tsp_demo_sk_ee

download_pem  sk_root_2018_crt.pem    https://sk.ee/upload/files/TEST_of_EE-GovCA2018.pem.crt
import_pem_crt sk_root_2018

download_pem sid_demo_sk_ee_2021_crt.pem https://www.skidsolutions.eu/upload/files/sid_demo_sk_ee_2021.cer
import_pem_crt sid_demo_sk_ee_2021

download_pem sk_ocsp_responder_2020_crt.pem https://www.skidsolutions.eu/upload/files/TEST_of_SK_OCSP_RESPONDER_2020.pem.cer
import_pem_crt sk_ocsp_responder_2020

download_pem  sk_esteid_2018_crt.pem  https://sk.ee/upload/files/TEST_of_ESTEID2018.pem.crt
import_pem_crt sk_esteid_2018

download_pem EE_Certification_Centre_Root_CA_crt.pem https://www.sk.ee/upload/files/TEST_of_EE_Certification_Centre_Root_CA.pem.crt
import_pem_crt EE_Certification_Centre_Root_CA

download_pem  sk_esteid_2015_crt.pem  https://www.sk.ee/upload/files/TEST_of_ESTEID-SK_2015.pem.crt
import_pem_crt sk_esteid_2015

download_pem  sk_esteid_2011_crt.pem  https://www.sk.ee/upload/files/TEST_of_ESTEID-SK_2011.pem.crt
import_pem_crt sk_esteid_2011

keytool -importkeystore -srcstorepass ${TEST_PW} -deststorepass ${TEST_PW} -noprompt -srckeystore ${TRUST_STORE_FILE}.jks -destkeystore ${TRUST_STORE_FILE}.p12 \
        -srcstoretype JKS -deststoretype PKCS12

rm -f *.crt
rm -f *.cer
rm -f *.pem
