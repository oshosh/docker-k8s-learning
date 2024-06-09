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
