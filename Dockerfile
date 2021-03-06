FROM alpine:3.12.3

COPY app /app

RUN apk upgrade && apk add --no-cache --update curl jq

CMD /app/start.sh
