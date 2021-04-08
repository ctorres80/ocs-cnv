# requirements for
sudo yum install -y python2-openshift.noarch
sudo yum install -y python2-openshift.noarch

# get worker nodes
oc get nodes -l node-role.kubernetes.io/worker= -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'
# discovery CPUs in workers
oc get nodes -l node-role.kubernetes.io/worker= -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | while read node; do oc debug node/$node -- lscpu|grep "^CPU(s)"; done
# discovery RAM
oc get nodes -l node-role.kubernetes.io/worker= -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | while read node; do oc debug node/$node -- free -h; done
# get the OCS workers
oc get nodes -l cluster.ocs.openshift.io/openshift-storage= -o jsonpath='{range .items[*]}{@.metadata.name}{"\n"}'
# label namespace openshift-storage for monitoring
oc label namespace openshift-storage "openshift.io/cluster-monitoring=true"
# enable ceph-tool in ocs
oc patch OCSInitialization ocsinit -n openshift-storage --type json --patch  '[{ "op": "replace", "path": "/spec/enableCephTools", "value": true }]'
oc -n openshift-storage patch StorageCluster ocs-storagecluster --type=json -p '[{"op": "replace", "path": "/spec/storageDeviceSets/1/dataPVCTemplate/spec/resources/requests/storage", "value":4Ti}]'
# delete files in fio pods
oc get pods -l app=fio-testing-performance -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | while read fiopod; do oc exec $fiopod -- find /usr/share/ocs-pvc/ -type f -name 'test*' -delete; done
