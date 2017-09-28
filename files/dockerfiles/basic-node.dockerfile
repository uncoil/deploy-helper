## {{PROJECTNAME}} Dockerfile
FROM node:6.9.5

RUN apt-get update && apt-get install -y mysql-client vim
RUN useradd --user-group --create-home --shell /bin/false docker

ENV HOME=/home/docker

RUN npm install -g yarn
RUN yarn global add knex
RUN yarn global add istanbul

COPY package.json $HOME/app/
RUN chown -R docker:docker $HOME/
RUN mkdir -p /usr/local/share/.config/yarn
RUN chown -R docker:docker /usr/local/share/.config/yarn

RUN echo "Host github.com\n\tStrictHostKeyChecking no\n" >> $HOME/.ssh/config
USER docker

WORKDIR $HOME/app

RUN yarn

## Copy any files into the container that are required to run/build/test here
COPY src $HOME/app/src
COPY config $HOME/app/config
COPY test $HOME/app/test
COPY cli $HOME/app/cli
COPY test.sh $HOME/app/test.sh
