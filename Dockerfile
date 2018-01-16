FROM ruby:2.5-alpine

ENV RUBY_ENV=development
ENV PAGER=less
VOLUME /tmp

RUN mkdir -p /app && \
  gem install bundler && \
  apk add --update --no-cache less sqlite-dev postgresql-dev tzdata && \
  apk add --update --no-cache --virtual build_deps \
    git ruby-dev make gcc musl-dev

WORKDIR /app
COPY Gemfile Gemfile.lock /app/
RUN bundle install && apk del build_deps
COPY ./ /app/

CMD ["rackup"]
