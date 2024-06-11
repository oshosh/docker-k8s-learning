FROM node:14

WORKDIR /app

# 작업 디렉토리를 설정하면 .로 써도 무방
COPY package.json .

RUN npm install

COPY . .

# RUN npm install 아래 써서 docker build 시 npm install 재실행을 막고 캐싱으로 docker 레이어를 고려함
ARG DEFAULT_PORT=80 

# ENV PORT 80
ENV PORT $DEFAULT_PORT

EXPOSE $PORT

# VOLUME ["/app/node_modules"]

CMD ["npm", "start" ]