FROM nginx:1.16.1

RUN groupadd -g 1000 app \
 && useradd -g 1000 -u 1000 -d /var/www -s /bin/bash app

RUN apt-get update && apt-get install --no-install-recommends -y \
        nano
RUN ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

ENV SEO_EXCLUDE_LOCATION_REGEXP (robots.txt|googlef54caadf7ac6a10e.html|google1a0842e4865f65c1.html)
ENV SITEMAP_EXCLUDE_LOCATION_REGEXP sitemap(.*).xml

COPY ./conf/nginx.conf /etc/nginx/
#COPY ./conf/default.conf /etc/nginx/conf.d/

COPY ./conf/seo.map /etc/nginx/
COPY ./conf/affiliate.map /etc/nginx/
COPY ./conf/seo_map.js /etc/nginx/

COPY ./conf/upstream.conf /etc/nginx/conf.d/
#COPY ./conf/affiliate.conf /etc/nginx/conf.d/
COPY ./conf/default_ssl.conf /etc/nginx/conf.d/
COPY ./conf/b2b_ssl.conf /etc/nginx/conf.d/
#COPY ./conf/bestellung.parfuemerie.de.conf /etc/nginx/conf.d/
COPY ./conf/maintenance.conf /etc/nginx/conf.d/

COPY ./bin/start.sh /usr/local/bin/start.sh

WORKDIR /var/www/html

CMD ["/usr/local/bin/start.sh"]