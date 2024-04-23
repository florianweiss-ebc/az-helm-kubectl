ARG BUILDPLATFORM
FROM ${BUILDPLATFORM}alpine:3

ARG AZ_VERSION
ARG KUBE_VERSION
ARG HELM_VERSION
ARG TARGETOS
ARG TARGETARCH
ARG YQ_VERSION

# install azure cli
# GitHub issue azure cli: https://github.com/Azure/azure-cli/issues/19591
# Python venv in Dockerfile: https://pythonspeed.com/articles/activate-virtualenv-dockerfile/
RUN apk add py3-pip
RUN apk add gcc musl-dev python3-dev libffi-dev openssl-dev cargo make
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv ${VIRTUAL_ENV}
ENV PATH="${VIRTUAL_ENV}/bin:$PATH"
RUN pip install --upgrade pip
RUN pip install azure-cli==${AZ_VERSION}

# install azure cli extension
RUN az extension add -n connectedk8s

# install kubectl and helm
RUN apk -U upgrade \
    && apk add --no-cache ca-certificates bash git openssh curl gettext jq \
    && wget -q https://storage.googleapis.com/kubernetes-release/release/v${KUBE_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl -O /usr/local/bin/kubectl \
    && wget -q https://get.helm.sh/helm-v${HELM_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz -O - | tar -xzO ${TARGETOS}-${TARGETARCH}/helm > /usr/local/bin/helm \
    && wget -q https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_${TARGETOS}_${TARGETARCH} -O /usr/local/bin/yq \
    && chmod +x /usr/local/bin/helm /usr/local/bin/kubectl /usr/local/bin/yq \
    && mkdir /config \
    && chmod g+rwx /config /root \
    && helm repo add "stable" "https://charts.helm.sh/stable" --force-update \
    && kubectl version --client \
    && helm version

WORKDIR /config

CMD bash