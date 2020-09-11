#! /bin/bash

meta_host=`facter app_name``facter meta_name`
grid_host=`facter app_name``facter compute_name`
mid_host=`facter app_name``facter mid_name`
microservices_host=`facter app_name``facter microservices_vmname`
cascontroller_host=`facter app_name``facter cascontroller_vmname`
spre_host=`facter app_name``facter spre_vmname`
casworker_host=`facter app_name``facter casworker_vmname`
gridnode_host=`facter app_name`gridnode
casnodescount=`facter cas_nodes`
#gridnodescount=`facter grid_nodes`
gridnodescount=2
inventory_file="sas_services_status_inventory.ini"
sas_services_status_playbook="sas_services_status.yml"

for ((i=0; i < $casnodescount ; i++)); do
cat <<EOF >> casworkers.txt
$casworker_host$i
EOF
done

for ((i=1; i <= $gridnodescount ; i++)); do
cat <<EOF >> gridnodes.txt
$gridnode_host$i
EOF
done

sed -i "/\[sas94gridnodes\]/r gridnodes.txt" $inventory_file
sed -i "/\[sasviya\]/r casworkers.txt" $inventory_file
sed -i "s/metahost/$meta_host/g" $inventory_file
sed -i "s/gridhost/$grid_host/g" $inventory_file
sed -i "s/midhost/$mid_host/g" $inventory_file
sed -i "s/microserviceshost/$microservices_host/g" $inventory_file
sed -i "s/cascontrollerhost/$cascontroller_host/g" $inventory_file
sed -i "s/sprehost/$spre_host/g" $inventory_file

rm -rf gridnodes.txt casworkers.txt

export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook -i $inventory_file $sas_services_status_playbook -vv
