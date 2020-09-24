FROM node:latest
WORKDIR /app
COPY . .
RUN npm install
EXPOSE 3000
CMD ["/usr/local/bin/npm", "run", "start"]
