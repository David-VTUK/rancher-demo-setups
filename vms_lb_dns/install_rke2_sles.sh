set -xe

$(terraform output -state=terraform.tfstate -json node_ips | jq -r 'keys[] as $k | "export IP\($k)=\(.[$k])"')

ssh -o StrictHostKeyChecking=no ec2-user@$IP0 sudo mkdir -p /etc/rancher/rke2
ssh -o StrictHostKeyChecking=no ec2-user@$IP1 sudo mkdir -p /etc/rancher/rke2
ssh -o StrictHostKeyChecking=no ec2-user@$IP2 sudo mkdir -p /etc/rancher/rke2

ssh -o StrictHostKeyChecking=no ec2-user@$IP0 sudo mkdir -p /var/lib/rancher/rke2/server/manifests
ssh -o StrictHostKeyChecking=no ec2-user@$IP1 sudo mkdir -p /var/lib/rancher/rke2/server/manifests
ssh -o StrictHostKeyChecking=no ec2-user@$IP2 sudo mkdir -p /var/lib/rancher/rke2/server/manifests

dd if=rke2-ingress-nginx-config.yaml | ssh -o StrictHostKeyChecking=no ec2-user@$IP0 sudo dd of=/var/lib/rancher/rke2/server/manifests/rke2-ingress-nginx-config.yaml
dd if=rke2-ingress-nginx-config.yaml | ssh -o StrictHostKeyChecking=no ec2-user@$IP1 sudo dd of=/var/lib/rancher/rke2/server/manifests/rke2-ingress-nginx-config.yaml
dd if=rke2-ingress-nginx-config.yaml | ssh -o StrictHostKeyChecking=no ec2-user@$IP2 sudo dd of=/var/lib/rancher/rke2/server/manifests/rke2-ingress-nginx-config.yaml

dd if=rke2_config_initial.yaml | ssh -o StrictHostKeyChecking=no ec2-user@$IP0 sudo dd of=/etc/rancher/rke2/config.yaml
dd if=rke2_config_additional.yaml | ssh -o StrictHostKeyChecking=no ec2-user@$IP1 sudo dd of=/etc/rancher/rke2/config.yaml
dd if=rke2_config_additional.yaml | ssh -o StrictHostKeyChecking=no ec2-user@$IP2 sudo dd of=/etc/rancher/rke2/config.yaml

ssh -o StrictHostKeyChecking=no ec2-user@$IP0 curl -sfL https://get.rke2.io --output install_rke2.sh
ssh -o StrictHostKeyChecking=no ec2-user@$IP1 curl -sfL https://get.rke2.io --output install_rke2.sh
ssh -o StrictHostKeyChecking=no ec2-user@$IP2 curl -sfL https://get.rke2.io --output install_rke2.sh
ssh -o StrictHostKeyChecking=no ec2-user@$IP0 sudo bash install_rke2.sh
ssh -o StrictHostKeyChecking=no ec2-user@$IP1 sudo bash install_rke2.sh
ssh -o StrictHostKeyChecking=no ec2-user@$IP2 sudo bash install_rke2.sh

ssh -o StrictHostKeyChecking=no ec2-user@$IP0 sudo systemctl enable rke2-server.service
ssh -o StrictHostKeyChecking=no ec2-user@$IP0 sudo systemctl start rke2-server.service
sleep 120
ssh -o StrictHostKeyChecking=no ec2-user@$IP1 sudo systemctl enable rke2-server.service
ssh -o StrictHostKeyChecking=no ec2-user@$IP1 sudo systemctl start rke2-server.service
sleep 120
ssh -o StrictHostKeyChecking=no ec2-user@$IP2 sudo systemctl enable rke2-server.service
ssh -o StrictHostKeyChecking=no ec2-user@$IP2 sudo systemctl start rke2-server.service

sleep 10

ssh -o StrictHostKeyChecking=no ec2-user@$IP0 sudo dd if=/etc/rancher/rke2/rke2.yaml | dd of=kubeconfig

sed -i "s/127.0.0.1/kubernetes.plgrnd.be/g" kubeconfig

export KUBECONFIG=$(pwd)/kubeconfig

watch kubectl get nodes,pods -A

