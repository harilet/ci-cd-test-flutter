#Stage 1 - Install dependencies and build the app
FROM dart:3.1.0 as build-env

ARG 2.4.1

RUN apt-get update --quiet --yes
RUN apt-get install --quiet --yes \
    unzip \
    apt-utils

RUN dart pub global activate fvm 2.4.1
RUN fvm install 3.13.1
RUN fvm global 3.13.1
ENV PATH="/root/fvm/default/bin:${PATH}"
# Run flutter doctor
RUN flutter doctor -v
# Enable flutter web
RUN flutter config --enable-web

# Copy files to container and build
RUN mkdir /app/
COPY . /app/
WORKDIR /app/
RUN flutter pub get
RUN flutter build web

# Stage 2 - Create the run-time image
FROM nginx:1.21.1-alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
