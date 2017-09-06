#!/bin/bash

####pkgs


sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Install dependencies
sudo yum -y install python-pip git python2-boto \
python-netaddr python-httplib2 python-devel \
gcc libffi-devel openssl-devel python2-boto3 \
python-click python-six pyOpenSSL httpd-tools \
java-1.8.0-openjdk-headless python-passlib PyYAML python-jinja2 python-keyczar python-paramiko sshpass

# Upgrade pip
sudo pip install --upgrade pip

# Install ansible v2.2, setuptools and graffiti_monkey
sudo pip install --upgrade setuptools graffiti_monkey

# Clone repository
sudo rm -rf /usr/share/ansible
sudo mkdir -p /usr/share/ansible
cd /usr/share/ansible
sudo git clone https://github.com/openshift/openshift-ansible.git openshift-ansible
cd openshift-ansible && sudo git checkout release-1.5



#sudo rpm -Uvh https://kojipkgs.fedoraproject.org//packages/ansible/2.2.0.0/3.fc25/noarch/ansible-2.2.0.0-3.fc25.noarch.rpm
sudo rpm -Uvh https://kojipkgs.fedoraproject.org//packages/ansible/2.2.2.0/1.fc25/noarch/ansible-2.2.2.0-1.fc25.noarch.rpm
sudo rm -rf /usr/share/ansible-contrib
sudo mkdir -p /usr/share/ansible-contrib
cd /usr/share/ansible-contrib
sudo git clone https://github.com/openshift/openshift-ansible-contrib openshift-ansible-contrib
cd openshift-ansible-contrib/reference-architecture/aws-ansible

sudo rm -f /usr/share/ansible-contrib/openshift-ansible-contrib/reference-architecture/aws-ansible/ansible.cfg
sudo cp /home/vagrant/ocaws-design/ansible.cfg /usr/share/ansible-contrib/openshift-ansible-contrib/reference-architecture/aws-ansible/ansible.cfg

sudo chown -R vagrant /usr/share/ansible*


#run before script
#export AWS_ACCESS_KEY_ID=XXXX
#export AWS_SECRET_ACCESS_KEY=XXXX
#export GITHUB_CLIENT_ID=XXXX
#export GITHUB_CLIENT_SECRET=XXXX
#export GITHUB_ORGANIZATION=sctechnology
#export PUBLIC_HOSTED_ZONE=aws.sc.technology
#export REGION=us-east-1


./ose-on-aws.py --keypair=OSE-key --create-key=yes --key-path=/home/vagrant/.ssh/OSE-key.pub --public-hosted-zone=aws.sc.technology \
--deployment-type=origin --ami=ami-6d1c2007 --github-client-secret=XXXX \
--github-organization=openshift --github-organization=sctechnology --github-client-id=XXXX --deployment-type origin --stack-name santiagoinfra --containerized=false --no-confirm


# set image streams
# oadm policy add-cluster-role-to-user cluster-admin santiagoangel --config=/etc/origin/master/admin.kubeconfig
#oc create -f https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/v3.6/xpaas-streams/jboss-image-streams.json -n openshift 
#oc create -f https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/v3.6/xpaas-streams/fis-image-streams.json -n openshift
#oc create -f https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/v3.6/image-streams/image-streams-centos7.json -n openshift
#oc create -f https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/v3.6/image-streams/dotnet_imagestreams.json -n openshift
#oc create -f https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/v3.6/quickstart-templates/jenkins-ephemeral-template.json -n openshift
