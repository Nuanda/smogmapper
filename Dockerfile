FROM ruby:2.3.0
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /smogmapper
WORKDIR /smogmapper
ADD Gemfile /smogmapper/Gemfile
ADD Gemfile.lock /smogmapper/Gemfile.lock
RUN bundle install
ADD . /smogmapper
