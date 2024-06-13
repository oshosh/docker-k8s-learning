# 호스트 통신을 위한 컨테이너 만들기
```
docker 컨테이너를 만들때 mongodb connect을 위해 도커가 localhost라는걸 인식하게 하려면 host.docker.internal 부여하면 docker 컨테이너 내부에서 호스트 통신의 내부 ip로 변경이 된다.
```

# mongo db 컨테이너 안에 넣기
```
docker run -d --name mongodb  mongo
 - 도커 허브로 부터 mongo의 이미지가 없다면 이미지를 빌드하고 
 받아서 바로 컨테이너화 시킴
docker container inspect mongodb  
 - NetworkSettings > IPAddress > mongodb 컨테이너의 고유 주소를 가져옴
 - IPAddress에서 가져온 ip를 mongoose connect 주소 대체함

 docker build -t favorites-node .  
 docker run --name favorites -d --rm -p 3000:3000 favorites-node
 이후 
 포스트맨으로 검사해봄
```

# docker 컨테이너를 통해 docker간 통신 가능하게 하기
```
일단 기존에 생성한 이미지, 컨테이너 전부 제거
docker network create favorites-net
 - 도커 내부 네트워크이며 도커 컨테이너에서 컨테이너 서로간 통신이 가능해짐
docker network ls
 - 기존의 모든 네트워크를 찾아봄

'mongodb://172.17.0.2:27017/swfavorites',
이렇게 넣어줄 필요 없이 컨테이너로 생성될 네임을 넣어줌
'mongodb://mongodb:27017/swfavorites', 혹은 host.docker.internal 넣어줘도 해당하는 컨테이너의 로컬 주소를 잡아줌.
아래와 같은 설정을 해야함.

docker run -d --name mongodb --network favorites-net mongo 
 - mongodb 컨테이너 favorites-net 네트워크 설정
docker build -t favorites-node . 
 - favorites-node 이미지 리빌드 혹은 빌드
docker run --name favorites --network favorites-net -d --rm -p 3000:3000 favorites-node
 - favorites 컨테이너도 favorites-net 설정 후 컨테이너 실행

 docker logs favorites
 (node:1) [MONGODB DRIVER] Warning: Current Server Discovery and Monitoring engine is deprecated, and will be removed in a future version. To use the new Server Discover and Monitoring engine, pass option { useUnifiedTopology: true } to the MongoClient constructor.


+------------------+        +-------------------+
|                  |        |                   |
|  MongoDB         |        |  Node.js App      |
|  Container       |        |  Container        | ---------- 외부 API
|  (mongodb)       |        |  (favorites)      |
|                  |        |                   |
|  --network-------+--------+----network--------+
|  favorites-net   |        |  favorites-net    |
|                  |        |                   |
+------------------+        +-------------------+
        ^                            ^
        |                            |
        |       +--------------------+
        |       |
        v       v
+---------------------------------------+
|         Docker Network                |
|         (favorites-net)               |
+---------------------------------------+

 결론 
 1. 호스트와 외부간에는 -p 로 해결이 가능
 2. db혹은 외부 컨테이너간에는 network를 설정 해줘야한다. 그렇지 않으면
 수동 컨테이너의 ip를 달아줘야하나 외부로 통신이 불가하다.
  why ? docker run -d --name mongodb --network favorites-net mongo 
   => 포트가 없음...

```