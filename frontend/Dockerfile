FROM node:22.13.1-alpine3.20 AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

FROM nginx:1.27-alpine3.20

COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 8080

RUN sed -i 's/listen  *80;/listen 8080;/g' /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]