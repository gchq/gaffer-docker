#!/bin/bash -e

until [ $(( ATTEMPTS++ )) -gt 30 ]; do
	result=$(curl -f -s ${HUB_API_URL})
	rc=$?
	echo "$(date) - rc: ${rc} result: ${result}"

	[ "${rc}" == "0" ] && exit 0

	sleep 1
done
exit 1
