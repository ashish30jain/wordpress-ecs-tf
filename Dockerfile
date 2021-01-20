FROM php:fpm-alpine3.13

CMD apk update && apk add nginx 
ENV DATA_DIR /var/www/html/
# Disable daemon mode
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
    # Backup configs
    cp -a /etc/nginx/conf.d /etc/nginx/.conf.d.orig && \
    rm -f /etc/nginx/conf.d/default.conf && \
    # Make sure the data directory is created and ownership correct
    mkdir -p $DATA_DIR && \
    chown -R www-data:www-data $DATA_DIR
RUN cp conf/default.conf /etc/nginx/conf.d/
RUN cp -rf wordpress /var/www/html/ && cp set-wp-config.sh .

CMD  ./set-wp-config.sh && nginx && php-fpm