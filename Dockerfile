FROM centos:centos7

# MySQL image for OpenShift.
#
# Volumes:
#  * /var/lib/mysql/data - Datastore for MySQL
# Environment:
#  * $MYSQL_USER - Database user name
#  * $MYSQL_PASSWORD - User's password
#  * $MYSQL_DATABASE - Name of the database to create
#  * $MYSQL_ROOT_PASSWORD (Optional) - Password for the 'root' MySQL account

# Image metadata
ENV MYSQL_VERSION           5.5
ENV IMAGE_DESCRIPTION       MySQL 5.5
ENV IMAGE_TAGS              mysql,mysql55
ENV IMAGE_EXPOSE_SERVICES   3306:mysql

MAINTAINER  Martin Nagy <mnagy@redhat.com>
EXPOSE 3306

# This image must forever use UID 27 for mysql user so our volumes are
# safe in the future. This should *never* change, the last test is there
# to make sure of that.
RUN rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
    yum -y --setopt=tsflags=nodocs install https://www.softwarecollections.org/en/scls/rhscl/mysql55/epel-7-x86_64/download/rhscl-mysql55-epel-7-x86_64.noarch.rpm && \
    yum -y --setopt=tsflags=nodocs install gettext hostname bind-utils mysql55 && \
    yum clean all && \
    mkdir -p /var/lib/mysql/data && chown mysql.mysql /var/lib/mysql/data && \
    ls -la /opt/rh/mysql55/root/usr/bin/resolveip && \
    test "$(id mysql)" = "uid=27(mysql) gid=27(mysql) groups=27(mysql)"

COPY run-*.sh /usr/local/bin/

COPY contrib /var/lib/mysql/

VOLUME ["/var/lib/mysql/data"]

USER mysql

ENTRYPOINT ["run-mysqld.sh"]
CMD ["mysqld"]
