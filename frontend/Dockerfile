FROM node:20-alpine as build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY frontend/replace-placeholders.sh /app/replace-placeholders.sh
RUN chmod +x /app/replace-placeholders.sh

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
