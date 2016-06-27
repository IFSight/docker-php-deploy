FROM fulcrum/php-ssh
MAINTAINER IF Fulcrum "fulcrum@ifsight.net"

# install mysqldump from mariadb and pv
RUN rpm --rebuilddb && \
    yum --noplugins install -y mariadb pv unzip && \
    yum --noplugins install -y https://rpm.nodesource.com/pub_0.12/el/7/x86_64/nodejs-0.12.9-1nodesource.el7.centos.x86_64.rpm https://rpm.nodesource.com/pub_0.12/el/7/x86_64/nodejs-devel-0.12.9-1nodesource.el7.centos.x86_64.rpm && \
    yum --noplugins upgrade -y && \
    package-cleanup --dupes && \
    package-cleanup --cleandupes && \
    yum clean all && \
    npm install -g commander aws-sdk && \
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o /tmp/awscli-bundle.zip && \
    unzip -d /tmp /tmp/awscli-bundle.zip && \
    /tmp/awscli-bundle/install -i /aws 
