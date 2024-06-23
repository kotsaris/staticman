FROM node:8.11.3

# Create app directory
RUN mkdir -p /app
WORKDIR /app

# Install app dependencies
COPY package.json /app/
RUN npm install -q
COPY config.production.json /app/

# Bundle app source
COPY . /app

ENV NODE_ENV=production
EXPOSE 80
CMD [ "npm", "start" ]