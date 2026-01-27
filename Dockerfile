# dùng image có sẵn tích hợp cả linux , apache , mysql , php

# còn gọi là LAMP STACK 

FROM mattrayner/lamp:latest-1804

RUN echo "[mysqld]" >> /etc/mysql/my.cnf && \
    echo "secure-file-priv = \"\"" >> /etc/mysql/my.cnf

    
#image mattrayner/lamp đc cấu hình để coi thư mục /app là gốc , nếu copy code vào /var/www/html thì apache mở /app lên thì ko thấy gì => web trống trơn 
COPY src/ /app/


RUN chown -R www-data:www-data /app && \

    chmod -R 777 /app

