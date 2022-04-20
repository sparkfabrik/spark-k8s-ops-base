FROM gcr.io/google.com/cloudsdktool/cloud-sdk:382.0.0-alpine

LABEL org.opencontainers.image.source https://github.com/sparkfabrik/spark-k8s-ops-base

# Build target arch passed by BuildKit
ARG TARGETARCH

ENV CLOUDSDK_COMPUTE_REGION europe-west1-b

# NOTE: you can check which is the latest stable kubeclt version with:
# curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt
# https://github.com/docker/compose/releases
# https://docs.docker.com/compose/install/#install-compose-on-linux-systems

# Install additional components.
RUN apk --update add vim tmux curl wget less make bash \
    bash-completion util-linux pciutils usbutils coreutils binutils \
    findutils grep gettext docker ncurses jq bat py-pip python3-dev \
    openssl libffi-dev openssl-dev gcc libc-dev rust cargo git unzip

# Add additional components to Gcloud SDK.
RUN gcloud components install app-engine-java beta

ENV KUBECTL_VERSION 1.23.3
RUN curl -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl && \
    chmod +x /usr/local/bin/kubectl

ENV TERRAFORM_VERSION 1.1.5
RUN curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip && \
    unzip /tmp/terraform.zip && \
    mv terraform /usr/local/bin/terraform && \
    chmod +x /usr/local/bin/terraform

# Install tflint Terraform Linter
# https://github.com/terraform-linters/tflint
RUN curl -o /tmp/tflint_install.sh https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh && \
    chmod +x /tmp/tflint_install.sh && \
    /tmp/tflint_install.sh && \
    rm -f /tmp/tflint_install.sh

# https://github.com/kubepack/onessl/releases
ENV ONESSL_VERSION 0.14.0
RUN curl -fsSL -o onessl https://github.com/kubepack/onessl/releases/download/v${ONESSL_VERSION}/onessl-linux-${TARGETARCH} && \
    chmod +x onessl && \
    mv onessl /usr/local/bin/

# https://github.com/atombender/ktail/releases
ENV KTAIL_VERSION 1.0.1
RUN curl -L https://github.com/atombender/ktail/releases/download/v${KTAIL_VERSION}/ktail-linux-${TARGETARCH} -o /usr/local/bin/ktail && \
    chmod +x /usr/local/bin/ktail && \
    curl -L https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -o /usr/local/bin/kubectx && \
    curl -L https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -o /usr/local/bin/kubens && \
    chmod +x /usr/local/bin/kubectx /usr/local/bin/kubens && \
    curl -L https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail -o /usr/local/bin/kubetail && \
    chmod +x /usr/local/bin/kubetail

ENV COMPOSE_VERSION 1.29.2
RUN pip install "docker-compose==${COMPOSE_VERSION}" && \
    echo "if [ -f /etc/profile.d/bash_completion.sh ]; then source /etc/profile.d/bash_completion.sh; source <(kubectl completion bash | sed 's/kubectl/k/g') ; fi" >> /etc/profile

# Install stern
# https://github.com/stern/stern/releases
ENV STERN_VERSION 1.21.0
RUN mkdir /tmp/stern && cd /tmp/stern && \
    curl -LO https://github.com/stern/stern/releases/download/v${STERN_VERSION}/stern_${STERN_VERSION}_linux_${TARGETARCH}.tar.gz && \
    tar -xvf stern_${STERN_VERSION}_linux_${TARGETARCH}.tar.gz && \
    mv stern /usr/local/bin/stern && \
    rm stern_${STERN_VERSION}_linux_${TARGETARCH}.tar.gz && \
    rm -rf /tmp/stern

# Install Helm 3:
ENV HELM_VERSION 3.7.2
RUN wget -O helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz && \
    tar -xzf helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz  && \
    cp linux-${TARGETARCH}/helm /usr/local/bin/helm && \
    rm helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz && \
    rm -fr linux-${TARGETARCH}/

# Install Velero.
# https://github.com/vmware-tanzu/velero/releases
ENV VELERO_VERSION 1.7.1
RUN mkdir -p /velero && \
    cd /velero && \
    wget https://github.com/heptio/velero/releases/download/v${VELERO_VERSION}/velero-v${VELERO_VERSION}-linux-${TARGETARCH}.tar.gz && \
    tar zxvf velero-v${VELERO_VERSION}-linux-${TARGETARCH}.tar.gz && \
    cp velero-v${VELERO_VERSION}-linux-${TARGETARCH}/velero /usr/local/bin/velero && \
    chmod +x /usr/local/bin/velero && \
    rm -rf velero-v${VELERO_VERSION}-linux-${TARGETARCH}.tar.gz

# Install k9s
# @see https://github.com/derailed/k9s
# https://github.com/derailed/k9s/releases
ENV K9S_VERSION 0.25.18
RUN wget -O k9s_Linux_x86_64.tar.gz https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_x86_64.tar.gz && \
    tar -xzf k9s_Linux_x86_64.tar.gz && \
    rm k9s_Linux_x86_64.tar.gz && \
    mv k9s /usr/local/bin/k9s && \
    chmod +x /usr/local/bin/k9s

# Install Kube No Trouble - kubent.
# https://github.com/doitintl/kube-no-trouble
ENV KUBENT_VERSION 0.5.0
RUN curl -sfL https://github.com/doitintl/kube-no-trouble/releases/download/${KUBENT_VERSION}/kubent-${KUBENT_VERSION}-linux-${TARGETARCH}.tar.gz | tar -zxO > /usr/local/bin/kubent && \
    chmod +x /usr/local/bin/kubent

# Install Cert Manager CLI - cmctl
# https://github.com/jetstack/cert-manager/releases
ENV CMCTL_VERSION 1.7.0
RUN curl -o cmctl.tar.gz -sfL https://github.com/jetstack/cert-manager/releases/download/v${CMCTL_VERSION}/cmctl-linux-${TARGETARCH}.tar.gz && \
    tar -xzf cmctl.tar.gz && \
    rm cmctl.tar.gz && \
    mv cmctl /usr/local/bin/cmctl && \
    chmod +x /usr/local/bin/cmctl

# Install Krew - kubectl plugin manager
# https://krew.sigs.k8s.io/docs/user-guide/setup/install/
RUN set -x; cd "$(mktemp -d)" && \
    OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
    KREW="krew-${OS}_${ARCH}" && \
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" && \
    tar zxvf "${KREW}.tar.gz" && \
    ./"${KREW}" install krew

ENV PATH "/root/.krew/bin:$PATH"

# Install kube-capacity using krew
RUN kubectl krew install resource-capacity

# Copy alias functions
COPY bash_functions.sh /etc/profile.d/bash_functions.sh
RUN chmod +x /etc/profile.d/bash_functions.sh

RUN echo "PS1='\[\033[1;36m\]\u\[\033[1;31m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;31m\]\$\[\033[0m\] '" >> /etc/profile \
    && echo "export PATH=/google-cloud-sdk/bin:/root/.krew/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" >> /etc/profile \
    && echo "export TERM=xterm" >> /etc/profile \
    && echo "source <(kubectl completion bash)" >> /etc/profile \
    && echo "alias k=\"kubectl\"" >> /etc/profile \
    && echo "alias events=\"kubectl get events --all-namespaces --sort-by=.metadata.creationTimestamp\"" >> /etc/profile \
    && echo "alias watch-events=\"kubectl get events -w --all-namespaces\"" >> /etc/profile \
    && echo "alias nodes=\"kubectl get nodes\"" >> /etc/profile \
    && echo "alias top-nodes=\"kubectl top nodes\"" >> /etc/profile \
    && echo "alias pods=\"kubectl get pod --all-namespaces\"" >> /etc/profile \
    && echo "alias deployments=\"kubectl get deployments --all-namespaces\"" >> /etc/profile \
    && echo "alias jobs=\"kubectl get jobs --all-namespaces\"" >> /etc/profile \
    && echo "alias cronjobs=\"kubectl get cronjobs --all-namespaces\"" >> /etc/profile \
    && echo "alias ingress=\"kubectl get ingress --all-namespaces\"" >> /etc/profile \
    && echo "alias services=\"kubectl get services --all-namespaces\"" >> /etc/profile \
    && echo "alias kdp-error=\"kubectl get pods | grep Error | cut -d' ' -f 1 | xargs kubectl delete pod\"" >> /etc/profile \
    && echo "alias kdp-evicted=\"kubectl get pods | grep Evicted | cut -d' ' -f 1 | xargs kubectl delete pod\"" >> /etc/profile \
    && echo "alias helm3=\"helm\"" >> /etc/profile \
    && echo "alias kube-capacity=\"kubectl resource-capacity\"" >> /etc/profile \
    && echo "source <(helm completion bash)" >> /etc/profile \
    && echo "source <(velero completion bash)" >> /etc/profile \
    && echo "source <(cmctl completion bash)" >> /etc/profile
