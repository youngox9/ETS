FROM nginx

# 将 Vue 应用程序的静态文件复制到 Nginx 容器
#COPY dist /usr/share/nginx/html

# 复制自定义的 Nginx 配置文件
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf
#COPY ./dist/ /usr/share/nginx/html/
WORKDIR /usr/share/nginx/html
#1. 建立映像檔
#docker build -t etsdev .
#2. 查看映像檔
#docker images
#3. 建立容器
#docker run -p 8080:8080 --name etsdev -d etsdev
#4. 查看容器
#docker ps -a
#5. 停止容器
#docker stop etsdev
#docker start etsdev
#6. 移除容器
#docker rm etsdev
#7. 查看日誌
#docker logs etsdev
#8. 執行容
#docker exec -it etsdev bash

#USE TOMCAT 
#FROM tomcat:8.0
#COPY ./dist/index.html /usr/local/tomcat/webapps/dist/
#COPY ./dist/assets/* /usr/local/tomcat/webapps/dist/assets/
#WORKDIR /usr/local/tomcat/webapps