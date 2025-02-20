FROM openjdk:17-jdk-slim

WORKDIR /app

COPY . /app

RUN javac -cp postgresql-42.7.5.jar server.java

EXPOSE 8080

CMD ["java", "-cp", ".:postgresql-42.7.5.jar", "server"]
