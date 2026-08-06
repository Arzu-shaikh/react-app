FROM node:22-alpine
RUN apk add --no-cache nginx
WORKDIR /react
COPY react-app/package*.json ./
RUN npm install
COPY react-app/ .
RUN npm run build
RUN mkdir -p /usr/share/nginx/html
RUN rm -f /etc/nginx/http.d/default.conf /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/http.d/default.conf
RUN cp -r dist/* /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
