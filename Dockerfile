FROM node:12

RUN apt-get update -qqy && apt-get upgrade -qqy

# Downloading gcloud package
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

# Installing the package
RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh

# Adding the package path to local
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

# Get tagged copy of gcloudrig
RUN mkdir /usr/src/app
RUN curl -L https://api.github.com/repos/gcloudrig/gcloudrig/tarball/v0.1.0-beta.3 > /tmp/gcloudrig.tar.gz \
    && tar -C /usr/src/app -xvf /tmp/gcloudrig.tar.gz --strip-components=1
    
COPY ./entrypoint.sh /
COPY ./app /usr/src/app/

WORKDIR /usr/src/app
RUN npm ci --prefix ./api --only=production; \
    npm install --prefix ./dashboard

RUN npm install -g @angular/cli@latest
RUN npm run build --prefix ./dashboard

CMD [ "sh", "-c", "/entrypoint.sh" ]
