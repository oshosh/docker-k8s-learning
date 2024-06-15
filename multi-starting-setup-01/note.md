# 로컬 호스트 통신

```
(DB)
docker run --name mongodb --rm -d -p 27017:27017 mongo

(BACKEND)
backend > app.js > host.docker.internal로 변경
docker build -t goals-node .
docker run --name goals-backend --rm -d -p 80:80 goals-node

(FRONTEND)
docker build -t goals-react .
docker run --name goals-frontend --rm -d -p 3000:3000 -it goals-react
```

# 동일 네트워크 생성 통신

```
(docker network)
docker network create goals-net

(DB)
docker run --name mongodb --rm -d --network goals-net mongo

(BACKEND)
backend > app.js > host.docker.internal에서 mongodb로 변경
docker build -t goals-node .
docker run --name goals-backend --rm -d --network goals-net -p 80:80 goals-node

(FRONTEND)
frontend > app.js > fetch 함수 localhost를 goals-backend로 변경하지 않은 브라우저에서 실행 되고 있기 때문에 그렇기 때문에 backend에서도 80:80 로컬 호스트 포트를 열어둠. (그대로 유지)
docker build -t goals-react .
docker run --name goals-frontend --rm -d -p 3000:3000 -it goals-react
 - 컨테이너에서 실행되는 애플케이션과 관계가 없기에 네트워크는 필요가없음.
```

# 몽고디비에 명명 볼륨을 주어 데이터 지속성 높이기

```
docker stop mongodb
docker run --name mongodb -v data:/data/db --rm -d --network goals-net mongo
docker ps
정상 확인
```

# 몽고디비 유저 권한 부여

```
docker stop mongodb

(DB)
docker run --name mongodb -v data:/data/db --rm -d --network goals-net -e MONGO_INITDB_ROOT_USERNAME=max -e MONGO_INITDB_ROOT_PASSWORD=secret mongo
docker ps
정상 확인

(BACKEND)
backend > app.js >  "mongodb://max:secret@mongoDB:27017/course-goals?authSource=admin", 변경
docker build -t goals-node .
docker ps
정상 확인
docker run --name goals-backend --rm -p 80:80 --network goals-net goals-node
docker ps
정상 확인
```
