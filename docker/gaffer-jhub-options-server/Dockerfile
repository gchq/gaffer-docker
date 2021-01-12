FROM node:15.3.0-alpine3.12

WORKDIR /srv/app
COPY package.json ./
RUN npm install
COPY . .

EXPOSE 8080

CMD [ "npm", "start" ]
