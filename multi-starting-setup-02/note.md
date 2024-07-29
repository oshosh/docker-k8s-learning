# compose 명령어
```
docker-compose up
  - compose file에서 찾을 수 있는 모든 서비스가 시작됨.
docker-compose up -d
  - detached 모드
docker-compose down
  - 모든 컨테이너가 삭제되고 생성된 디폴트 네트워크와 모든것이 종료됨
  - 이미지, 볼륨은 삭제가 안됨
docker-compose down -v
 - 볼륨도 같이 제거
```

# mongodb 확인
```
backend까지 연결 후 docker-compose up -d 후
docker logs multi-starting-setup-02-backend-1로 확인

services의 mongodb설정을 했기 때문에 아래와 같이 mongoDB의 서비스를 찾아갈 수 있음

`mongodb://${process.env.MONGODB_USERNAME}:${process.env.MONGODB_PASSWORD}@mongoDB:27017/course-goals?authSource=admin`,
```