FROM ruby:3.0.0

ENV RAILS_ENV production
RUN mkdir /mangosteen
RUN bundle config mirror.https://rubygems.org https://gems.ruby-china.com
WORKDIR /mangosteen
ADD mangosteen-*.tar.gz ./
# ADD Gemfile /mangosteen
# ADD Gemfile.lock /mangosteen
# ADD vendor/cache /mangosteen/vendor/cache
RUN bundle config set --local without 'development test'
RUN bundle install


ENTRYPOINT bundle exec puma