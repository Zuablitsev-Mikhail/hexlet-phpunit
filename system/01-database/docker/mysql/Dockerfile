FROM mysql:5.7

RUN ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

COPY my.cnf /etc/mysql/conf.d/my.cnf
RUN chmod 0644 /etc/mysql/conf.d/my.cnf