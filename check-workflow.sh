#/bin/sh

USER=digestadmin
PASSWD=opencast
URL='http://localhost:8080/'

ENDPOINT='workflow/instances.xml'
[ "$1" != "" ] && ENDPOINT="workflow/instance/$1.xml"

WORKFLOW_STATE='^.*<workflow.*state="\([^"]*\)".*\(="[0-9]*"\).*$'
WORKFLOW_TITLE='^.*<ns3:title>\([^<]*\)<\/ns3.*$'
OPERATION='^.*<operation.*description="\([^"]*\)".*state="\([^"]*\)".*$'

curl -s -f --digest -u "${USER}:${PASSWD}" -H "X-Requested-Auth: Digest" "${URL}${ENDPOINT}" | \
	xmllint --format - | \
	sed -n "s/${WORKFLOW_STATE}\|${WORKFLOW_TITLE}\|${OPERATION}/\1\2 \3 '  \5' '\4'/p" | \
	xargs printf "%-14s %s\n"
