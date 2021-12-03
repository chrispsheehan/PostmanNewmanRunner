FROM postman/newman:alpine
RUN apk add --update --no-cache make
RUN apk add --update --no-cache jq
RUN apk add --update --no-cache curl
RUN apk add --update --no-cache npm
RUN npm install -g newman-reporter-slackreporter
COPY src /etc/newman/
ENTRYPOINT [ "make" ]