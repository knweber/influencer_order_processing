FROM ruby:2.5

ENV RUBY_ENV=development

RUN gem install bundler
RUN mkdir -p /app/lib /app/db /app/test
WORKDIR /app
COPY Gemfile Gemfile.lock /app/
RUN bundle install 
COPY db /app/db/
COPY Rakefile /app/
COPY test /app/test/
COPY lib /app/lib/

CMD ["rake", "-T"]
