# dùng image có sẵn tích hợp cả linux , apache , mysql , php

# còn gọi là LAMP STACK 

FROM mattrayner/lamp:latest-1804

RUN echo "[mysqld]" >> /etc/mysql/my.cnf && \
    echo "secure-file-priv = \"\"" >> /etc/mysql/my.cnf

    

COPY src/ /var/www/html


RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 777 /var/www/html
