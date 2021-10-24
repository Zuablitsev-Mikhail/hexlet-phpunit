FROM nginx:1.16.1

RUN groupadd -g 1000 app \
 && useradd -g 1000 -u 1000 -d /var/www -s /bin/bash app

RUN apt-get update && apt-get install --no-install-recommends -y \
        nano
RUN ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

ENV PHP_HOST phpfpm
ENV PHP_PORT 9000
#ENV APP_MAGE_MODE default
#ENV APP_MAGE_MODE developer
ENV APP_MAGE_MODE production
ENV APP_MAGE_RUN_TYPE website
ENV APP_DEFAULT_MAGE_RUN_CODE base

#ENV APP_DEFAULT_SERVER_NAME www.parfuemerie.de
#ENV APP_B2B_MAGE_RUN_CODE b2b
#ENV APP_B2B_SERVER_NAME b2b.parfuemerie.de
#ENV APP_BASE_SERVER_NAME parfuemerie.de

ENV APP_DEFAULT_SERVER_NAME parfuemerie-stg.intexsoft.com
ENV APP_B2B_MAGE_RUN_CODE b2b
ENV APP_B2B_SERVER_NAME b2b-parfuemerie-stg.intexsoft.com
ENV APP_BASE_SERVER_NAME www.parfuemerie-stg.intexsoft.com

ENV SEO_EXCLUDE_LOCATION_REGEXP (robots.txt|googlef54caadf7ac6a10e.html|google1a0842e4865f65c1.html)
ENV SITEMAP_EXCLUDE_LOCATION_REGEXP sitemap(.*).xml

COPY ./conf/nginx.conf /etc/nginx/
#COPY ./conf/default.conf /etc/nginx/conf.d/

COPY ./conf/seo.map /etc/nginx/
COPY ./conf/affiliate.map /etc/nginx/
COPY ./conf/seo_map.js /etc/nginx/

COPY ./conf/upstream.conf /etc/nginx/conf.d/
COPY ./conf/bestellung.parfuemerie.de.conf /etc/nginx/conf.d/
COPY ./conf/affiliate.conf /etc/nginx/conf.d/
COPY ./conf/default_ssl.conf /etc/nginx/conf.d/
COPY ./conf/b2b_ssl.conf /etc/nginx/conf.d/
COPY ./bin/start.sh /usr/local/bin/start.sh
#COPY ./conf/maintenance.conf /etc/nginx/conf.d/

WORKDIR /var/www/html

CMD ["/usr/local/bin/start.sh"]