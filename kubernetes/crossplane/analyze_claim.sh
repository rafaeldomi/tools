#!/bin/bash

# $1 - tipo composition (ex. xekscluster)
# $2 - name do claim (ex. jonathans-cluster-d679x)

if [ -z $1 ] ||
   [ -z $2 ]; then
	echo "Não foi informado parametros"
	exit 1
fi

JS=$(kubectl get $1 $2 -o json)

# Loop nos resourceRefs
TOT=$(echo "$JS" | jq '.spec.resourceRefs | length')

echo "Avaliar $TOT resources"

for (( i = 0; i<$TOT; i++ )); do
	JSRES=$(echo "$JS" | jq ".spec.resourceRefs[$i]")
	API=$(echo "$JSRES"| jq -r ".apiVersion" | cut -d'/' -f1)
	kind=$(echo "$JSRES" | jq -r ".kind")
	name=$(echo "$JSRES" | jq -r ".name")

	echo "------"
	echo " Object: $kind . $API"
	echo "   Name: $name"

	# Remover depois do /
	JSRES=$(kubectl get ${kind,,}.$API $name -o json)
	ReadyStatus=$(echo "$JSRES" | jq -r '.status.conditions | .[] | select(.type=="Ready") | .status')
	SyncStatus=$(echo "$JSRES" | jq -r '.status.conditions | .[] | select(.type=="Synced") | .status')

	echo " Ready | $ReadyStatus"
	echo " Sync  | $SyncStatus"
done
