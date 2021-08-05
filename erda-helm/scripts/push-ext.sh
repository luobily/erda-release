#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE[0]}")"

yum install git -y

if [[ -z $ERDA_NAMESPACE ]]; then
	export ERDA_NAMESPACE="default"
fi

if ! cat /etc/hosts | grep openapi.${ERDA_NAMESPACE}.svc.cluster.local; then
    echo `kubectl get svc -n default | grep openapi | awk '{print $3}'` openapi.${ERDA_NAMESPACE}.svc.cluster.local >> /etc/hosts
else
    sed -i "s/.*openapi.${ERDA_NAMESPACE}.svc.cluster.local.*/`kubectl get svc -n default | grep openapi | awk '{print $3}'` openapi.${ERDA_NAMESPACE}.svc.cluster.local/g" /etc/hosts
fi

ls -1d ./erda-actions/actions/*/* | while read i; do
    ./dice ext push -d "$i" -f -a ${r} --host "http://openapi.${ERDA_NAMESPACE}.svc.cluster.local:9529" -u ${ERDA_ADMIN_USERNAME} -p ${ERDA_ADMIN_PASSWORD}
done

ls -1d ./erda-addons/addons/*/* | while read i; do
    ./dice ext push -d "$i" -f -a ${r} --host "http://openapi.${ERDA_NAMESPACE}.svc.cluster.local:9529" -u ${ERDA_ADMIN_USERNAME} -p ${ERDA_ADMIN_PASSWORD}
done