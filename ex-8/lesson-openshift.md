# Lesson 2: OpenShift

use terraform to deploy openshift.

oc adm policy add-scc-to-user hostnetwork\
    system:serviceaccount:default:router \
    --config=/opt/openshift-server/openshift.local.config/master/admin.kubeconfig

oadm policy add-cluster-role-to-user \
    cluster-reader system:serviceaccount:default:router\
    --config=/opt/openshift-server/openshift.local.config/master/admin.kubeconfig

oc adm router router1 --replicas=1 --service-account=router --config=/opt/openshift-server/openshift.local.config/master/admin.kubeconfig