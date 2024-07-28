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
backend > app.js > host.docker.internal에서 처음 생성한 몽고디비의 컨테이너 이름인 mongodb로 변경 합니다.
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
이 작업을 하기 전에는 db, fe, be, volume 전부 내리고 다시 실행 권장..

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
docker volume rm data
docker run --name goals-backend --rm -d -p 80:80 --network goals-net goals-node
docker ps
정상 확인
```

# NodeJs 컨테이너의 볼륨, 바인드 마운트 및 폴리싱
```
docker stop goals-backend

1. app WORKDIR 아래 logs로 logs 컨테이너 볼륨 생성
docker run --name goals-backend -v logs:/app/logs --rm -p 80:80 --network goals-net goals-node
2. 로컬 호스팅 디렉토리를 바인드 마운트
docker run --name goals-backend -v /Users/osh/Desktop/my-repo/docker-k8s-learning/multi-starting-setup-01/backend:/app -v logs:/app/logs --rm -p 80:80 --network goals-net goals-node
3. 익명 볼륨 생성 node_modules는 컨테이너에서 유지
docker run --name goals-backend -v /Users/osh/Desktop/my-repo/docker-k8s-learning/multi-starting-setup-01/backend:/app -v logs:/app/logs -v /app/node_modules -d --rm -p 80:80 --network goals-net goals-node

:/app/logs 이경로는 :/app를 내부 경로를 덮어씁니다. docker의 정책상
그렇기 때문에 logs는 변경되지 않는다.

backend -> package.json ->  nodemon 추가 dockerfile node, start 변경

로그 확인
docker logs goals-backend

dockerfile에서 env 설정 후 id는 다르게해서 docker 명령어 시 MONGODB_USERNAME는 기본값 부여 해보고 비번은 빼본다.

docker run --name goals-backend -v /Users/osh/Desktop/my-repo/docker-k8s-learning/multi-starting-setup-01/backend:/app -v logs:/app/logs -v /app/node_modules -e MONGODB_USERNAME=max -d --rm -p 80:80 --network goals-net goals-node

기존 컨테이너에 복사하고 싶지 않는 파일
.dockerignore


프론트
docker run -v /Users/osh/Desktop/my-repo/docker-k8s-learning/multi-starting-setup-01/frontend/src:/app/src --name goals-frontend --rm -d -p 3000:3000 -it goals-react
```