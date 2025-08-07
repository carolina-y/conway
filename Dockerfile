FROM ruby:3.4.5-bookworm AS build

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y supervisor

COPY . /app
WORKDIR /app
RUN bundle install

ENTRYPOINT ["supervisord", "-c", "/app/supervisord.conf"]
