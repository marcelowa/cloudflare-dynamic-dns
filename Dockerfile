FROM alpine:3.12.0

RUN apk upgrade && apk add --no-cache --update curl jq

COPY app /app

CMD /app/start.sh
