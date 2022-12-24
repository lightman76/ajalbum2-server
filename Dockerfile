#Dockerfile.rails
FROM ruby:2.5.5 AS ajalbum-server
RUN apt-get install imagemagick

#Default Directory
ENV INSTALL_PATH /opt/app
ENV PHOTO_STORAGE_PATH /opt/photo-storage
RUN mkdir -p $INSTALL_PATH
RUN mkdir -p $PHOTO_STORAGE_PATH


#Install rails
RUN gem install bundler -v 1.17.3
RUN gem install nokogiri -v 1.12.5
WORKDIR /opt/app
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
COPY app app
COPY bin bin
COPY config config
COPY db db
COPY lib lib
COPY lib lib
COPY public public
COPY vendor vendor
COPY config.ru config.ru
COPY Rakefile Rakefile
RUN mkdir -p log
RUN mkdir -p tmp

RUN bundle install

#Run a shell
CMD bundle exec unicorn -c config/unicorn.rb