@@ -0,0 +1,7 @@
FROM node:14 as build
WORKDIR /usr/local/app
COPY package*.json ./ 
RUN npm install
COPY . .
EXPOSE 3800
CMD ["node", "index.js"]

@@ -0,0 +1,11 @@
FROM node:14 as build
WORKDIR /usr/local/app
COPY ./ /usr/local/app/
RUN npm install
RUN npm run build

FROM nginx:latest
WORKDIR /usr/share/nginx/html
COPY --from=build /usr/local/app/build .
COPY ./nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80


server {
    listen 80;
    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
        try_files $uri $uri/ /index.html =404;
    }
}

