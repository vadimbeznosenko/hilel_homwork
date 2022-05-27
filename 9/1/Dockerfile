FROM node:8.16.2-alpine

RUN adduser --home /home/sax4  --disabled-password sax4

WORKDIR /usr/src/app/

COPY *.json ./

RUN npm i

RUN npm install express

USER sax4

WORKDIR /usr/src/app/

COPY . .

ADD --chown=sax4 . /usr/src/app/build
#********
RUN npm run build

CMD ["node", "run start"]