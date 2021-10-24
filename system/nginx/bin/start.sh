#!/bin/bash
[ ! -z "${PHP_HOST}" ] && sed -i "s/PHP_HOST/${PHP_HOST}/" /etc/nginx/conf.d/default.conf
[ ! -z "${PHP_PORT}" ] && sed -i "s/PHP_PORT/${PHP_PORT}/" /etc/nginx/conf.d/default.conf
[ ! -z "${APP_MAGE_MODE}" ] && sed -i "s/APP_MAGE_MODE/${APP_MAGE_MODE}/" /etc/nginx/conf.d/default.conf

[ ! -z "${PHP_HOST}" ]                  && sed -i "s/PHP_HOST/${PHP_HOST}/" /etc/nginx/conf.d/upstream.conf
[ ! -z "${PHP_PORT}" ]                  && sed -i "s/PHP_PORT/${PHP_PORT}/" /etc/nginx/conf.d/upstream.conf

[ ! -z "${APP_MAGE_MODE}" ]             && sed -i "s/APP_MAGE_MODE/${APP_MAGE_MODE}/" /etc/nginx/conf.d/default_ssl.conf
[ ! -z "${APP_MAGE_RUN_TYPE}" ]         && sed -i "s/APP_MAGE_RUN_TYPE/${APP_MAGE_RUN_TYPE}/" /etc/nginx/conf.d/default_ssl.conf
[ ! -z "${APP_DEFAULT_MAGE_RUN_CODE}" ] && sed -i "s/APP_DEFAULT_MAGE_RUN_CODE/${APP_DEFAULT_MAGE_RUN_CODE}/" /etc/nginx/conf.d/default_ssl.conf
[ ! -z "${APP_DEFAULT_SERVER_NAME}" ]   && sed -i "s/APP_DEFAULT_SERVER_NAME/${APP_DEFAULT_SERVER_NAME}/" /etc/nginx/conf.d/default_ssl.conf
[ ! -z "${APP_BASE_SERVER_NAME}" ]   && sed -i "s/APP_BASE_SERVER_NAME/${APP_BASE_SERVER_NAME}/" /etc/nginx/conf.d/default_ssl.conf
[ ! -z "${SEO_EXCLUDE_LOCATION_REGEXP}" ]   && sed -i "s/SEO_EXCLUDE_LOCATION_REGEXP/${SEO_EXCLUDE_LOCATION_REGEXP}/" /etc/nginx/conf.d/default_ssl.conf
[ ! -z "${SITEMAP_EXCLUDE_LOCATION_REGEXP}" ]   && sed -i "s/SITEMAP_EXCLUDE_LOCATION_REGEXP/${SITEMAP_EXCLUDE_LOCATION_REGEXP}/" /etc/nginx/conf.d/default_ssl.conf

[ ! -z "${APP_MAGE_MODE}" ]             && sed -i "s/APP_MAGE_MODE/${APP_MAGE_MODE}/" /etc/nginx/conf.d/b2b_ssl.conf
[ ! -z "${APP_MAGE_RUN_TYPE}" ]         && sed -i "s/APP_MAGE_RUN_TYPE/${APP_MAGE_RUN_TYPE}/" /etc/nginx/conf.d/b2b_ssl.conf
[ ! -z "${APP_B2B_MAGE_RUN_CODE}" ]     && sed -i "s/APP_B2B_MAGE_RUN_CODE/${APP_B2B_MAGE_RUN_CODE}/" /etc/nginx/conf.d/b2b_ssl.conf
[ ! -z "${APP_B2B_SERVER_NAME}" ]       && sed -i "s/APP_B2B_SERVER_NAME/${APP_B2B_SERVER_NAME}/" /etc/nginx/conf.d/b2b_ssl.conf

[ ! -z "${APP_DEFAULT_SERVER_NAME}" ]   && sed -i "s/APP_DEFAULT_SERVER_NAME/${APP_DEFAULT_SERVER_NAME}/" /etc/nginx/conf.d/affiliate.conf
[ ! -z "${APP_B2B_SERVER_NAME}" ]       && sed -i "s/APP_B2B_SERVER_NAME/${APP_B2B_SERVER_NAME}/" /etc/nginx/conf.d/affiliate.conf
[ ! -z "${APP_BASE_SERVER_NAME}" ]   && sed -i "s/APP_BASE_SERVER_NAME/${APP_BASE_SERVER_NAME}/" /etc/nginx/conf.d/affiliate.conf
[ ! -z "${SEO_EXCLUDE_LOCATION_REGEXP}" ]   && sed -i "s/SEO_EXCLUDE_LOCATION_REGEXP/${SEO_EXCLUDE_LOCATION_REGEXP}/" /etc/nginx/conf.d/affiliate.conf
[ ! -z "${SITEMAP_EXCLUDE_LOCATION_REGEXP}" ]   && sed -i "s/SITEMAP_EXCLUDE_LOCATION_REGEXP/${SITEMAP_EXCLUDE_LOCATION_REGEXP}/" /etc/nginx/conf.d/affiliate.conf


/usr/sbin/nginx -g "daemon off;"