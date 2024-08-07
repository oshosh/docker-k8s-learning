# Composer 유틸리티 컨테이너로 Laravel 앱 만들기
```
docker-compose run --rm composer create-project --prefer-dist laravel/laravel .
 - 단일 컨테이너 실행

 docker-compose up -d server php mysql
  - 특정 서비스만 실행

 docker-compose up -d --build server
  - docker-compose가 dockerfiles를 거친 다음 변경된 사항이 있는 경우 이미지를 다시 생성 시킴


  0. 아래와 같이 커맨드 입력하여 현재 동작시키고 있는 컨테이너 모두 내리기
  docker-compose down

1. dockerfiles 폴더의 php.dockerfile 파일에서
   FROM php:8.0-fpm-alpine   로 변경

2. 기존 src 폴더 및 하위파일 제거 한 뒤에 src 폴더 다시 생성

3. 아래와 같이 커맨드 입력
   docker-compose build server php mysql
   docker-compose run --rm composer create-project --prefer-dist laravel/laravel:8.0.0 .

4. src 폴더에 있는 .env 파일의 mysql 관련 내용 다시 수정

5. 아래와 같이 커맨드 입력
   docker-compose up -d server php mysql

6. 브라우저에서 localhost:8000 로 들어가서 laravel 초기 페이지 확인
```