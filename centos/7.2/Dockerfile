FROM centos:centos7
MAINTAINER IF Fulcrum "fulcrum@ifsight.net"

ADD dbclone.sh /usr/local/bin/dbclone.sh

# Enable EPEL Repos, update, install PHP 5.6, postdrop correct perms, add the user
RUN rpm --rebuilddb && \
    yum --noplugins install -y \
        https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
        http://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
    yum --noplugins --enablerepo=remi,remi-php56 -y install \
        openssh-clients postfix mariadb pv unzip nodejs nodejs-devel \
        php php-fpm php-gd php-imap php-ldap php-mbstring php-mysql php-opcache \
        php-pgsql php-soap php-xml php-mcrypt php-pecl-redis php-php-gettext && \
    yum --noplugins upgrade -y && \
    sed -i '/^listen = /clisten = 0.0.0.0:9000' /etc/php-fpm.d/www.conf && \
    sed -i '/^listen.allowed_clients/c;listen.allowed_clients =' /etc/php-fpm.d/www.conf && \
    sed -i '/^;catch_workers_output/ccatch_workers_output = yes' /etc/php-fpm.d/www.conf && \
    chmod g+s /usr/sbin/postqueue /usr/sbin/postdrop && \
    groupadd -g 1971 php && \
    useradd -d /var/www/html -g php -M -n -s /sbin/nologin -u 1971 php && \
    npm install -g commander aws-sdk && \
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o /tmp/awscli.zip && \
    unzip -d /tmp /tmp/awscli.zip && \
    /tmp/awscli-bundle/install -i /aws && \
    package-cleanup --dupes && \
    package-cleanup --cleandupes && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    ln -s /bin/bash /bin/rbash && chsh -s /bin/rbash php && \
    rm /tmp/awscli.zip

ENTRYPOINT ["/usr/sbin/php-fpm"]

CMD ["--nodaemonize"]
