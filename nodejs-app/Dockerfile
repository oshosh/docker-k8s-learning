# docker hub의 base 이미지를 기반으로 생성
FROM node 

# 도커 컨테이너 내부 작업 할 디렉토리
WORKDIR /app

# 로컬 모든 파일을 /app = ./ 도커 컨테이너에 전부 복사
COPY . /app

# WORKDIR 기준으로 install
RUN npm install 

EXPOSE 80 

CMD ["node", "server.js" ]


