# 도커 기본 명령어

```
docker run -it
(컨테이너 생성 + 인풋 + 의사결정)
```

```
docker start -a -i
(기존 컨테이너 실행 + 인터렉션 -> 인풋 + 의사결정)
```

```
docker rm
컨테이너 삭제 사용중인 컨테이너를 종료를 시켜야함
```

```
docker rmi
이미지 삭제 대신 사용중인 컨테이너는 종료를 시켜야함
```

```
docker image prune
사용하지 않는 이미지 전부 삭제
```

```
docker run -p 3000:80 -d --rm 이미지
컨테이너 생성 후 중지 될때 항상 컨테이너가 제거
```

# 도커 파일 복사 및 컨테이너 이름 부여, 이미지 생성 시 레파지토리 이름 및 태그 부여 방법

```
docker cp <로컬 파일>/<.(파일 경로 아래 전체) or text.txt(특정 파일)> <컨테이너 이름:/<컨테이너 경로>>

docker cp dummy/test reverent_wescoff:/test
- 현재 경로에서 test.txt를 reverent_wescoff 컨테이너에 test로 전달

docker cp reverent_wescoff:/test dummy
- reverent_wescoff:/test의 test 파일을 현재 경로의 dummy 폴더에 복사
```

```
docker run -p 3000:3000 -d --rm --name <내가주고 싶은 커스텀 이름> <컨테이너>
- docker ps의 [names]의 이름을 커스텀으로 부여 할 수 있음

docker build -t <레파지토리 이름:태그> .
- docker image를 빌드 할때 레파지토리 이름과 태그를 부여

예시
docker build -t nodenode-server:latest .
docker run -p 3001:80 -d --rm --name node-server-container nodenode-server:latest
docker stop node-server-container
```

# docker hub push

```
1. 도커 허브 레파지토리 node-hello-world로 생성
2. docker push <docker hub ID>/node-hello-world:tagname 작성
3.1. 태그에 이름을 맞춰주기 위해서 푸시하고자 하는 폴더를 명령어와 같이 작성
 - docker build -t <docker hub ID>/node-hello-world .
3.2. 기존 도커 이미지를 rename
 - docker tag <변경하고자 하는 docker images의 레파지토리 이름:태그> <docker hub ID>/node-hello-world
4. docker push <docker hub ID>/node-hello-world 진행

excl. 액세스 거부가 나온 경우
 - docker login
 - 유저 id / password 입력
```

# docker hub pull

```
0. 테스트를 위해 일단 다 지움 및 docker logout
 - docker image prune -a
 - docker logout
1. 퍼블릭 레파지토리에서 pull
 - docker pull <docker hub ID>/node-hello-world
```
