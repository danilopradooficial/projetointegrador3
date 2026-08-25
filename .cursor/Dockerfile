FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# R base (sem pacotes externos, conforme as atividades) + utilitarios minimos.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        r-base-core \
        git \
        curl \
        ca-certificates \
        locales \
    && rm -rf /var/lib/apt/lists/*

# Usuario padrao usado pelo Cloud Agent.
RUN if ! id ubuntu >/dev/null 2>&1; then \
        useradd -m -s /bin/bash ubuntu; \
    fi

USER ubuntu
