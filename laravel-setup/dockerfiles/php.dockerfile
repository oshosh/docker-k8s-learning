FROM php:8.0-fpm-alpine

WORKDIR /var/www/html

RUN docker-php-ext-install pdo pdo_mysql

# /var/www/html 안에 docker-php-ext-install pdo pdo_mysql 애플리케이션 설치
# php는 CMD나 ENTRYPOINT가 없어도 베이스 이미 내에 디폴트 명령이 자동 실행되어 인터프린터를 호출한다.

