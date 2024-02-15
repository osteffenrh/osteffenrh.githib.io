FROM fedora:39

RUN dnf update --assumeyes
RUN dnf install --assumeyes rubygems ruby-devel gcc g++ make
RUN gem install jekyll builder jekyll-compose
