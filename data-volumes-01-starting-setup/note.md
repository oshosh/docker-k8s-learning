```
이미지 빌드 태그는 feedback-node로 부여

docker build -t feedback-node .
```

```
feedback-node의 이미지를 feedback-app 컨테이너로 생성하고 detached 모드, 중단시 바로 제거를 해라.

docker run -p 3000:80 -d --name feedback-app --rm feedback-node
```

```
제목에 Awesome, 내용에 This is awesome! 입력 후 아래 방문

http://localhost:3000/feedback/awesome.txt
```

# 컨테이너 제거 이후 다시 실행 후 /feedback/awesome.txt 방문 시 /awesome.txt가 없는 문제 알아보기

```
docker stop feedback-app
docker run -p 3000:80 -d --name feedback-app feedback-nod

/feedback/awesome.txt

제목 Awesome 내용에 Added again 입력후 stop 후 다시 시작
docker stop feedback-app
docker start feedback-app
/feedback/awesome.txt (존재)

Container Layer (read-write)를 통해 이미지 파일 시스템에 액세스 해야함
- 호스트 파일에서 COPY . . 를 통해 temp 파일을 생성했기 때문에 다시 컨테이너를 생성할 경우 날라감.
```

# Volumes

```
docker file
VOLUME [ "/app/feedback" ]
```

```
docker build -t feedback-node:volumes .
docker run -d -p 3000:80 --rm --name feedback-app feedback-node:volumes

제목 Awesome
내용 One more time!
[무한 로딩..]

docker logs feedback-app

(node:1) UnhandledPromiseRejectionWarning: Error: EXDEV: cross-device link not permitted, rename '/app/temp/awesome.txt' -> '/app/feedback/awesome.txt'
(Use `node --trace-warnings ...` to show where the warning was created)
(node:1) UnhandledPromiseRejectionWarning: Unhandled promise rejection. This error originated either by throwing inside of an async function without a catch block, or by rejecting a promise which was not handled with .catch(). To terminate the node process on unhandled promise rejection, use the CLI flag `--unhandled-rejections=strict` (see https://nodejs.org/api/cli.html#cli_unhandled_rejections_mode). (rejection id: 1)
(node:1) [DEP0018] DeprecationWarning: Unhandled promise rejections are deprecated. In the future, promise rejections that are not handled will terminate the Node.js process with a non-zero exit code.
```

# 원인

```
 await fs.rename(tempFilePath, finalFilePath);
  - 도커 Volumes를 부여했을 경우 컨테이너 파일 시스템 내부의 다른 폴더로 이동이 불가함.
  - 컨테이너 밖으로 이동만 가능

  await fs.copyFile(tempFilePath, finalFilePath);
  await fs.unlink(tempFilePath);
```

# 다시 이미지 만들기

```
docker stop feedback-app
docker rmi feedback-node:volumes

docker build -t feedback-node:volumes .
docker run -d -p 3000:80 --rm --name feedback-app feedback-node:volumes

Awesome
Another test!

docker stop feedback-app
docker run -d -p 3000:80 --rm --name feedback-app feedback-node:volumes
 - 이렇게 해도 해결 안됨 미러링 된 공간이 필요함.
```

# Volumes(Anonymous Volumes, Named Volumes) or Bind Mounts

```
Anonymous Volumes
docker volume ls
 - 익명의 local 볼륨 공간 생성
docker stop feedback-app
 - 익명 local 볼륨 공간 삭제됨

 Named Volumes
  - 컨테이너가 종료된 후에도 볼륨이 유지됨
```

# 익명 볼륨 제거 후 명명 볼륨으로 생성해보기

```
docker rmi feedback-node:volumes
docker build -t feedback-node:volumes .

Dockerfile에서 VOLUME 라인을 제거 후
docker run -d -p 3000:80 --rm --name feedback-app -v feedback:/app/feedback feedback-node:volumes
 - app/feedback 볼륨에 저장
 - 즉, 호스트 머신에 폴더를 만들어 컨테이너 내부의 이 폴더에 연결하지만 이 볼륨은 feedback:/의 선택한 이름으로 저장이 됨

 똑같이 테스트 후 종료
 docker stop feedback-app
 docker volume ls 아래와 같이 존재

 DRIVER    VOLUME NAME
 local     feedback

 docker run -d -p 3000:80 --rm --name feedback-app -v feedback:/app/feedback feedback-node:volumes

 성공
 docker volume prune
  - 익명 볼륨 제거
```

# 바인드 마운트
```
docker desktop > settings > Resources > File sharing > 파일 공유 공간이 적용 되는 곳인지 확인
docker run -d -p 3000:80 --rm --name feedback-app -v feedback:/app/feedback -v "<호스트 머신 전체 절대경로>:/app(컨테이너 작업디렉토리)" feedback-node:volumes

macOS / Linux: -v $(pwd):/app
Windows: -v "%cd%":/app

docker run -d -p 3000:80 --rm --name feedback-app -v feedback:/app/feedback -v "/Users/osh/Desktop/my-repo/docker-k8s-learning/data-volumes-01-starting-setup:/app" feedback-node:volumes

위 명령어 문제 발생
 - "-v <호스트 머신 전체 절대경로>:/app(컨테이너 작업디렉토리)" 에 의해 /app 폴더의 모든 것을 로컬 폴더로 덮어쓰기 때문에 문제가 생김 그러면서 node_module이 사라지게 됨
 - 익명 볼륨을 통해 -v /app/node_modules를 사라지게 않게 해야함. (익명 볼륨은 컨테이너 종료 시 삭제)

docker run -d -p 3000:80 --rm --name feedback-app -v feedback:/app/feedback -v "/Users/osh/Desktop/my-repo/docker-k8s-learning/data-volumes-01-starting-setup:/app" -v /app/node_modules feedback-node:volumes

-v /app/node_modules 명령은 VOLUME ["/app/node_modules"]와 같다 

위 명령어 문제 발생
 - 노드 서버 런타임 수정 시 다시 껏다 켜야함

 package.json 수정
  "scripts": {
    "start": "nodemon server.js"
  },
  devDependencies": {
    "nodemon": "2.0.4"
  }

  dockerfile 수정
  FROM node:14

  WORKDIR /app

  # 작업 디렉토리를 설정하면 .로 써도 무방
  COPY package.json .

  RUN npm install

  COPY . .

  EXPOSE 80

  # VOLUME ["/app/node_modules"]

  CMD ["node", "server.js" ]

  docker 이미지 재빌드
  docker container 재 실행

  sever.js console 추가 후
  docker logs feedback-app 확인

```

# 읽기 전용 볼륨
```
:ro 도커가 폴더나 그 하위 폴더를 쓸수 없게 함 (read-only)
 - docker run -d -p 3000:80 --rm --name feedback-app -v feedback:/app/feedback -v "/Users/osh/Desktop/my-repo/docker-k8s-learning/data-volumes-01-starting-setup:/app:ro" -v /app/node_modules feedback-node:volumes
```

# 도커 볼륨 관리

```
docker volume ls
 - 도커 볼륨 list

docker volume create <feedback-files>
 - 도커 볼륨 수동 생성

docker volume inspect <feedback>
 - 도커 볼륨 검사
 
docker volume rm <feedback>
 - 도커 볼륨 삭제
 - 명명된 볼륨으로 설정 했다면 그 안의 자료도 다 날라감
```

# COPY VS 바인드 마운트
```
바인드 마운트를 사용하면 다시 복사를 해올 수 있기 때문에 Dockerfile에서 COPY를 안써도 된다고 생각하지만 도커의 개발 환경에서만 사용하고 개발환경이 아닐 경우에는 COPY를 써야한다.
```

# env

```
docker build -t feedback-node:env .

--env = -e 랑 같다
-e PORT=8000 -e 블라블라
 => 여러개도 가능

docker run -d -p 3000:8000 --env PORT=8000 --rm --name feedback-app -v feedback:/app/feedback -v "/Users/osh/Desktop/my-repo/docker-k8s-learning/data-volumes-01-starting-setup:/app:ro" -v/app/temp -v /app/node_modules feedback-node:env  

.env 파일을 만들었을 경우
docker run -d -p 3000:8000 --env-file ./.env --rm --name feedback-app -v feedback:/app/feedback -v "/Users/osh/Desktop/my-repo/docker-k8s-learning/data-volumes-01-starting-setup:/app:ro" -v/app/temp -v /app/node_modules feedback-node:env  
```

# 빌드 인수
```
docker build -t feedback-node:dev --build-arg DEFAULT_PORT=8000 .
```