FROM google/cloud-sdk:257.0.0-alpine

# Default env vars.
ENV CLOUDSDK_COMPUTE_REGION europe-west1-b
ENV HELM_VERSION 2.14.3
ENV TERRAFORM_VERSION 0.11.14
ENV VELERO_VERSION 1.0.0
ENV ONESSL_VERSION 0.12.0
ENV KTAIL_VERSION 0.11.0
ENV KUBECTL_VERSION 1.15.2
# NOTE: you can check which is the latest stable kubeclt version with:
# curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt

# Install additional components.
RUN apk --update add vim tmux curl wget less make bash bash-completion util-linux pciutils usbutils coreutils binutils findutils grep gettext docker ncurses jq && \
    gcloud components install app-engine-java beta && \
    curl -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip /tmp/terraform.zip && \
    mv terraform /usr/local/bin/terraform && \
    chmod +x /usr/local/bin/terraform && \
    wget -O helm-v${HELM_VERSION}-linux-amd64.tar.gz https://kubernetes-helm.storage.googleapis.com/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    tar -xzf helm-v${HELM_VERSION}-linux-amd64.tar.gz  && \
    cp linux-amd64/helm /usr/local/bin && \
    rm helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    rm -fr linux-amd64/ && \
    curl -fsSL -o onessl https://github.com/kubepack/onessl/releases/download/${ONESSL_VERSION}/onessl-linux-amd64 && \
    chmod +x onessl && \
    mv onessl /usr/local/bin/ && \
    curl -L https://github.com/atombender/ktail/releases/download/v${KTAIL_VERSION}/ktail-linux-amd64 -o /usr/local/bin/ktail && \
    chmod +x /usr/local/bin/ktail && \
    curl -L https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -o /usr/local/bin/kubectx && \
    curl -L https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -o /usr/local/bin/kubens && \
    chmod +x /usr/local/bin/kubectx /usr/local/bin/kubens && \
    curl -L https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail -o /usr/local/bin/kubetail && \
    chmod +x /usr/local/bin/kubetail && \
    echo "if [ -f /etc/profile.d/bash_completion.sh ]; then source /etc/profile.d/bash_completion.sh; source <(kubectl completion bash | sed 's/kubectl/k/g') ; fi" >> /etc/profile

# Install Velero.
RUN mkdir -p /velero && \
    cd /velero && \
    wget https://github.com/heptio/velero/releases/download/v${VELERO_VERSION}/velero-v${VELERO_VERSION}-linux-amd64.tar.gz && \
    tar zxvf velero-v${VELERO_VERSION}-linux-amd64.tar.gz && \
    cp velero-v${VELERO_VERSION}-linux-amd64/velero /usr/local/bin/velero && \
    chmod +x /usr/local/bin/velero && \
    rm -rf velero-v${VELERO_VERSION}-linux-amd64.tar.gz

RUN echo "PS1='\[\033[1;36m\]\u\[\033[1;31m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;31m\]\$\[\033[0m\] '" >> /etc/profile \
    && echo "export PATH=/google-cloud-sdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" >> /etc/profile \
    && echo "export TERM=xterm" >> /etc/profile \
    && echo "source <(kubectl completion bash)" >> /etc/profile \
    && echo "alias k=\"kubectl\"" >> /etc/profile \
    && echo "alias events=\"kubectl get events -w --all-namespaces\"" >> /etc/profile \
    && echo "alias nodes=\"kubectl get nodes\"" >> /etc/profile \
    && echo "alias top-nodes=\"kubectl top nodes\"" >> /etc/profile \
    && echo "alias pods=\"kubectl get pod --all-namespaces\"" >> /etc/profile \
    && echo "alias deployments=\"kubectl get deployments --all-namespaces\"" >> /etc/profile \
    && echo "alias jobs=\"kubectl get jobs --all-namespaces\"" >> /etc/profile \
    && echo "alias cronjobs=\"kubectl get cronjobs --all-namespaces\"" >> /etc/profile \
    && echo "alias ingress=\"kubectl get ingress --all-namespaces\"" >> /etc/profile \
    && echo "alias services=\"kubectl get services --all-namespaces\"" >> /etc/profile
