```
  docker run it -d node
   - node 컨테이너 생성
  docker exec -it <container names> npm init 
   - 도커 내부에 메인프로세스를 중단하지 않고 npm init 작업
```

# dockerfile과 바인드 마운트로 호스트 파일에 파일 생성해보기
```
docker build -t node-util . 
docker run -it -v <Dockerfile이 있는 경로>:/app node-util npm init
```

# ENTRYPOINT - 컨테이너 뒤에 명령어를 덮어치지 않고 뒤에 그대로 붙쳐줌 CMD와 반대임
```
docker build -t mynpm .    
docker run -it -v <Dockerfile이 있는 경로>:/app mynpm init
 => docker run -it -v <Dockerfile이 있는 경로>:/app mynpm [ENTRYPOINT] init

 docker run -it -v <Dockerfile이 있는 경로>:/app mynpm install express --save
  => 이 작업을 통해 호스트머신인 로컬로도 미러링이 가능하다.
```

# docker compose로 해보기
```
  docker-compose run npm 
   - 도커 컴포즈 서비스 중 하나를 특정하여 실행 시킬 수 있다.
  docker-compose run npm init
  
  run 명령어는 up / down 명령어와 다르게 컨테이너가 내려가지 않기때문에
  run --rm를 해줘야 컨테이너가 내려감
```