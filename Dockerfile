FROM node:18-alpine AS BUILDER

WORKDIR /app

# for metadata of code 
LABEL key="robinsharma <sharma0211kum@gmail.com>" \
      app="gemini-project" \
      stage="build"

COPY *.json *-lock.json . ./ 
RUN npm ci && \
    npm run build && \ 
    rm -rf node_modules && npm cache clean --force


FROM node:18-alpine AS Production

WORKDIR /app

COPY *.json *-lock.json ./
RUN npm ci --Production && npm cache clean --force

# copy only necessary file to build code
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.mjs ./

# we env for the code to be optimize and use only production for code build
ENV Node_Env=Production 
EXPOSE 3000

CMD [ "npm","start" ]


