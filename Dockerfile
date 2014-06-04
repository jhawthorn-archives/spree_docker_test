FROM ubuntu:13.10

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y install python-software-properties wget openssl libreadline6 libreadline6-dev curl git zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion zlib1g-dev build-essential libreadline-dev libsqlite3-dev libxml2-dev libxslt1-dev libffi-dev libgdbm-dev libmysqld-dev libmysqlclient-dev mysql-client libpq-dev libsqlite3-dev imagemagick nodejs phantomjs

WORKDIR /root

RUN \
  wget -O ruby-install-0.4.3.tar.gz https://github.com/postmodern/ruby-install/archive/v0.4.3.tar.gz; \
  tar -xzvf ruby-install-0.4.3.tar.gz; \
  cd ruby-install-0.4.3/ && make install; \
  rm -Rf ruby-install-0.4.3 ruby-install-0.4.3.tar.gz

RUN CFLAGS="-O3 -g" ruby-install ruby 2.1.2 -j5

ENV PATH /home/rails/.gem/ruby/2.1.0/bin:/opt/rubies/ruby-2.1.2/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV GEM_HOME /home/rails/.gem/ruby/2.1.0
ENV GEM_PATH /home/rails/.gem/ruby/2.1.0:/opt/rubies/ruby-2.1.2/lib/ruby/gems/2.1.0

# Faster nokogiri installs
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES 1

RUN adduser rails --gecos "" --disabled-password
USER rails
WORKDIR /home/rails
ENV HOME /home/rails

RUN echo "gem: --no-ri --no-rdoc" > .gemrc
RUN gem i bundler

CMD if [ -z $BRANCH ]; then BRANCH=master; fi; \
    if [ -z $USER ]; then USER=spree; fi; \
    echo "Testing $USER:$BRANCH"; \
    git clone --branch "$BRANCH" --depth 1 "git://github.com/$USER/spree.git" spree && \
    cd spree && \
    echo "gem 'fast_sqlite'" >> common_spree_dependencies.rb && \
    bundle install && \
    DB=sqlite sh build.sh
