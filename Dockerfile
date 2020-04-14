FROM ubuntu:18.04

LABEL maintainer="Chris Boland <boland1776@gmail.com>"

# Make sure the package repository is up to date.
RUN apt-get update && \
    apt-get -qy full-upgrade && \
    apt-get install -qy vim && \
    apt-get install -qy net-tools && \
    apt-get install -qy git && \
# Install a basic SSH server
    apt-get install -qy openssh-server && \
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd && \
# Install JDK 8 (latest stable edition at 2019-04-01)
    apt-get install -qy openjdk-8-jdk && \
# Install maven
#    apt-get install -qy maven && \
# Cleanup old packages
    apt-get -qy autoremove && \
# Add user jenkins and cboland to the image
# Set passwords for the users (you may want to alter this).
    adduser --quiet jenkins && \
    echo "jenkins:jenkins" | chpasswd && \
    mkdir /home/jenkins/.m2 && \
    adduser --quiet cboland && \
    echo "cboland:cboland" | chpasswd && \
    mkdir /home/cboland/.m2

#ADD settings.xml /home/jenkins/.m2/
# Copy authorized keys
#COPY .ssh/authorized_keys /home/jenkins/.ssh/authorized_keys

# The key is local to THIS repo, so I created a .ssh/id_rsa file here
COPY .ssh/id_rsa.pub /home/jenkins/.ssh/authorized_keys
COPY .ssh/id_rsa.pub /home/jenkins/.ssh/id_rsa.pub
COPY .ssh/id_rsa /home/jenkins/.ssh/id_rsa
COPY .ssh/id_rsa.pub /home/cboland/.ssh/authorized_keys
COPY .ssh/id_rsa.pub /home/cboland/.ssh/id_rsa.pub
COPY .ssh/id_rsa /home/cboland/.ssh/id_rsa

RUN chown -R jenkins:jenkins /home/jenkins/.m2/ && \
    chown -R jenkins:jenkins /home/jenkins/.ssh/

RUN chown -R cboland:cboland /home/cboland/.m2/ && \
    chown -R cboland:cboland /home/cboland/.ssh/

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]

