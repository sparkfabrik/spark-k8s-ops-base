FROM gcr.io/google.com/cloudsdktool/cloud-sdk:347.0.0-alpine

LABEL org.opencontainers.image.source https://github.com/sparkfabrik/spark-k8s-ops-base

# Default env vars.
ENV KUBECTL_VERSION 1.18.19
ENV CLOUDSDK_COMPUTE_REGION europe-west1-b
ENV HELM_VERSION 3.3.0
ENV TERRAFORM_VERSION 0.12.29
# https://github.com/vmware-tanzu/velero/releases
ENV VELERO_VERSION 1.0.0
# https://github.com/kubepack/onessl/releases
ENV ONESSL_VERSION 0.14.0
# https://github.com/atombender/ktail/releases
ENV KTAIL_VERSION 1.0.1
# https://github.com/stern/stern/releases
ENV STERN_VERSION 1.19.0
# https://github.com/derailed/k9s/releases
ENV K9S_VERSION 0.24.12
# https://github.com/doitintl/kube-no-trouble/releases1
ENV KUBENT_VERSION 0.4.0
# NOTE: you can check which is the latest stable kubeclt version with:
# curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt

# Install additional components.
RUN apk --update add vim tmux curl wget less make bash bash-completion util-linux pciutils usbutils coreutils binutils findutils grep gettext docker ncurses jq bat && \
    gcloud components install app-engine-java beta && \
    curl -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip /tmp/terraform.zip && \
    mv terraform /usr/local/bin/terraform && \
    chmod +x /usr/local/bin/terraform && \
    curl -fsSL -o onessl https://github.com/kubepack/onessl/releases/download/v${ONESSL_VERSION}/onessl-linux-amd64 && \
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

# Install stern
RUN wget https://github.com/stern/stern/releases/download/v${STERN_VERSION}/stern_${STERN_VERSION}_linux_amd64.tar.gz -O stern_${STERN_VERSION}_linux_amd64.tar.gz -q && \
    tar -xvf stern_${STERN_VERSION}_linux_amd64.tar.gz && \
    mv stern_${STERN_VERSION}_linux_amd64/stern /usr/local/bin/stern && \
    rm -r stern_${STERN_VERSION}_linux_amd64 && \
    rm stern_${STERN_VERSION}_linux_amd64.tar.gz

# Install Helm 3:
RUN wget -O helm-v${HELM_VERSION}-linux-amd64.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    tar -xzf helm-v${HELM_VERSION}-linux-amd64.tar.gz  && \
    cp linux-amd64/helm /usr/local/bin/helm && \
    rm helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    rm -fr linux-amd64/

# Install Velero.
RUN mkdir -p /velero && \
    cd /velero && \
    wget https://github.com/heptio/velero/releases/download/v${VELERO_VERSION}/velero-v${VELERO_VERSION}-linux-amd64.tar.gz && \
    tar zxvf velero-v${VELERO_VERSION}-linux-amd64.tar.gz && \
    cp velero-v${VELERO_VERSION}-linux-amd64/velero /usr/local/bin/velero && \
    chmod +x /usr/local/bin/velero && \
    rm -rf velero-v${VELERO_VERSION}-linux-amd64.tar.gz

# Install k9s
# @see https://github.com/derailed/k9s
RUN wget -O k9s_Linux_x86_64.tar.gz https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_x86_64.tar.gz && \
    tar -xzf k9s_Linux_x86_64.tar.gz && \
    rm k9s_Linux_x86_64.tar.gz && \
    mv k9s /usr/local/bin/k9s && \
    chmod +x /usr/local/bin/k9s

# Install Kube No Trouble - kubent.
# https://github.com/doitintl/kube-no-trouble
RUN curl -sfL https://github.com/doitintl/kube-no-trouble/releases/download/${KUBENT_VERSION}/kubent-${KUBENT_VERSION}-linux-amd64.tar.gz | tar -zxO > /usr/local/bin/kubent && \
    chmod +x /usr/local/bin/kubent

RUN echo "PS1='\[\033[1;36m\]\u\[\033[1;31m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;31m\]\$\[\033[0m\] '" >> /etc/profile \
    && echo "export PATH=/google-cloud-sdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" >> /etc/profile \
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
    && echo "alias helm3=\"helm\"" >> /etc/profile
