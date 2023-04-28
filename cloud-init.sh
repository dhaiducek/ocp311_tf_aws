#! /bin/bash

# Update node
sudo yum -y update

# Register system with Red Hat
sudo subscription-manager unregister
sudo subscription-manager register --username "${rh_subscription_username}" --password "${rh_subscription_password}"
sudo subscription-manager refresh
sudo subscription-manager attach --pool "${rh_subscription_pool_id}"
sudo subscription-manager config --rhsm.manage_repos=1
sudo subscription-manager repos --enable="rhel-7-server-rpms" --enable="rhel-7-server-extras-rpms" --enable="rhel-7-server-ansible-2.9-rpms" --enable="rhel-server-rhscl-7-rpms" --enable="rhel-7-server-ose-3.11-rpms"

# Signal to Terraform that update is complete and reboot
touch /home/ec2-user/cloud-init-complete

# Signal to Terraform to skip the OCP install steps (prerequisites and deploy_cluster)
${skip_install ? "" : "#"}touch /home/ec2-user/ocp-prereq-complete
${skip_install ? "" : "#"}touch /home/ec2-user/ocp-install-complete
reboot
