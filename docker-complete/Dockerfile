FROM node:14

WORKDIR /app

# 현재 os경로, docker 내부 경로 복사
COPY package.json .

RUN npm install

COPY . .

EXPOSE 3000

CMD [ "node", "app.mjs" ]

# https://github.com/bindian0509/docker-k8s-learning/blob/9d620832498ca6421a547f22e1e8f4fe86c4475b/first-demo/Dockerfile
# docker build . = 빌드
# docker run -p <호스트 포트>:<도커 내부 포트> 빌드 이미지
# docker ps 도커 상태
# docker stop 이미지
