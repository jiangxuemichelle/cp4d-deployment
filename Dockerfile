FROM phusion/baseimage:bionic-1.0.0

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

################################
# Download and install packages
################################

RUN install_clean wget unzip jq nano
WORKDIR /tmp

# terraform
RUN wget --no-verbose https://releases.hashicorp.com/terraform/1.2.9/terraform_1.2.9_linux_amd64.zip \
 && unzip terraform_1.2.9_linux_amd64.zip \
 && mv terraform /usr/bin/ \
 && echo 'alias tf=terraform' >> $HOME/.profile

# cloudctl
RUN wget --no-verbose https://github.com/IBM/cloud-pak-cli/releases/download/v3.7.1/cloudctl-linux-amd64.tar.gz \
 && tar -xzf cloudctl-linux-amd64.tar.gz \
 && mv cloudctl-linux-amd64 /usr/bin/cloudctl

# terraform-provider-ibm
RUN wget --no-verbose https://github.com/IBM-Cloud/terraform-provider-ibm/releases/download/v1.33.0/terraform-provider-ibm_1.33.0_linux_amd64.zip \
 && unzip terraform-provider-ibm_1.33.0_linux_amd64.zip \
 && mkdir -p $HOME/.terraform.d/plugins \
 && mv terraform-provider-ibm_v1.33.0 $HOME/.terraform.d/plugins/

# oc and kubectl
RUN wget --no-verbose https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-4.6/openshift-client-linux.tar.gz \
 && tar -xzf openshift-client-linux.tar.gz \
 && mv oc /usr/bin/ \
 && mv kubectl /usr/bin/

# ibmcloud cli
RUN curl -fsSL https://clis.cloud.ibm.com/install/linux | sh \
 && echo 'alias ic=ibmcloud' >> $HOME/.profile

# ibmcloud plugins
RUN ibmcloud plugin install container-registry \
&& ibmcloud plugin install container-service

# install jq
RUN wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64  -O /usr/bin/jq && chmod +x /usr/bin/jq

# install podman

RUN sh -c "echo 'deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_18.04/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"
RUN wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_18.04/Release.key -O- | apt-key add -
RUN apt-get update -y
RUN apt-get -y upgrade
RUN apt-get -y install podman


#RUN apt-get update -y
RUN apt-get install -y python
RUN apt-get install -y python-yaml

###################################
# Dir for mounting template files
###################################
RUN mkdir -p $HOME/templates \
 && echo "$HOME/.terraform" > /etc/container_environment/TF_DATA_DIR

WORKDIR /root/templates

############
# Clean up
############
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
