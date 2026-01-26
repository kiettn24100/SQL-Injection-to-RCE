# dùng image có sẵn tích hợp cả linux , apache , mysql , php

# còn gọi là LAMP STACK 

FROM mattrayner/lamp:latest-1804


RUN docker-php-ext-install mysql mysqli

COPY src/ /var/www/html

WORKDIR /var/www/html

RUN chown -R www-data:www-data /var/www/html \

    && chmod -R 777 /var/www/html


FROM ubuntu:20.04

# Tránh hỏi region khi cài đặt
ENV DEBIAN_FRONTEND=noninteractive

# Cài đặt Apache, PHP, MySQL Server
RUN apt-get update && apt-get install -y \
    apache2 \
    mysql-server \
    php \
    php-mysql \
    libapache2-mod-php \
    && rm -rf /var/lib/apt/lists/*

# 2. Cấu hình MySQL (Tắt secure-file-priv)
RUN echo "secure-file-priv = \"\"" >> /etc/mysql/mysql.conf.d/mysqld.cnf

# 3. Setup thư mục Web và Quyền 777
COPY src/ /var/www/html/
RUN rm /var/www/html/index.html
RUN chmod -R 777 /var/www/html
RUN chown -R www-data:www-data /var/www/html

# 4. Khởi tạo Database (Vì cài thủ công nên phải tự tạo user)
RUN service mysql start && \
    mysql -e "CREATE USER 'admin'@'localhost' IDENTIFIED BY 'password';" && \
    mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost';" && \
    mysql -e "FLUSH PRIVILEGES;" && \
    mysql -e "CREATE DATABASE vulndb;"

# 5. Chạy cả 2 dịch vụ (Dùng script đơn giản)
# Đây là cách giữ cho container không bị tắt
CMD service mysql start && apachectl -D FOREGROUND
