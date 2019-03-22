FROM node:10

RUN apt-get update; \
    apt-get -y install vim 

USER node
RUN mkdir ~/.npm-global; \
    npm config set prefix '~/.npm-global'; \
    npm install -g @vue/cli; \
    echo 'export PATH=$PATH:~/.npm-global/bin/' >> /home/node/.bashrc

EXPOSE 8080
