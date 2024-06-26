From alpine:latest

RUN apk add --no-cache bash

# RUN apt -y update \
#     && apt -y upgrade \
#     && apt -y install curl wget gpg unzip

RUN apk update && apk upgrade --no-cache
RUN apk add curl wget gpg unzip --no-cache
ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN apk add py3-pip --no-cache
RUN rm /usr/lib/python*/EXTERNALLY-MANAGED
# RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools

# Install yc CLI
RUN curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | \
    bash -s -- -a

# Install Terraform
ARG TERRAFORM_VERSION=1.4.6
RUN curl -sL https://hashicorp-releases.yandexcloud.net/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && install -o root -g root -m 0755 terraform /usr/local/bin/terraform \
    && rm -rf terraform terraform.zip

RUN ln -sf /root/yandex-cloud/bin/yc /usr/local/bin