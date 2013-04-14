#!/bin/sh

check() {
	retval=$1
	if [ $retval -eq 0 ]
	then
		printf "\r%-58s [\033[32m  OK  \033[0m]\n" "$2"
	else
		printf "\r%-58s [\033[31mFAILED\033[0m]\n" "$2"
		exit 1
	fi
}

echo -n 'Username: '
read USER
echo -n 'Password: '
read -s PASSWD
echo
echo -n 'Server URL [http://localhost:8080/]: '
read URL

[ "$URL" = '' ] && URL='http://localhost:8080/'

echo Creating mediapackage...
curl -# -f --digest -u "${USER}:${PASSWD}" -H 'X-Requested-Auth: Digest' "${URL}ingest/createMediaPackage" -o ingestMediaPackage.xml
check $? 'Creating mediapackage:'

echo 'Adding metadata...'
curl -# -f --digest -u "${USER}:${PASSWD}" -H 'X-Requested-Auth: Digest' "${URL}ingest/addDCCatalog" \
	-F 'flavor=dublincore/episode' -F 'mediaPackage=<ingestMediaPackage.xml' -F 'dublinCore=@dc.xml' -o ingestMediaPackageWithDC.xml
check $? 'Adding metadata:'

echo 'Adding track...'
curl -# -f --digest -u "${USER}:${PASSWD}" -H 'X-Requested-Auth: Digest' "${URL}ingest/addTrack" -F 'flavor=presentation/source' -F 'mediaPackage=<ingestMediaPackageWithDC.xml' -F 'BODY=@test.mkv' -o ingestMediaPackageWithDCAndTrack.xml
check $? 'Adding track:'

echo 'Ingesting...'
curl -# -f --digest -u "${USER}:${PASSWD}" -H 'X-Requested-Auth: Digest' "${URL}ingest/ingest/WebM-FLV-HQ" -F presenterType=camera -F presentationType=screen -F scaleFullsize=true -F scale480p=true -F archiveOp=true -F 'mediaPackage=<ingestMediaPackageWithDCAndTrack.xml' -o ingestMediaPackageWithDCAndTrackIngested.xml
check $? 'Ingesting:'

# curl -# -f --digest -u digestadmin:opencast -H "X-Requested-Auth: Digest" 'http://localhost:8080/ingest/addMediaPackage/WebM-FLV-HQ'  -F 'flavor=presentation/source' -F 'title=test-ingest-via-curl' -F 'presentationType=screen' -F 'scaleFullsize=true' -F "BODY=@test.mkv" -o m.xml
