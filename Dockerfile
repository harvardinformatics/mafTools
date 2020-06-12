FROM debian:buster-20200607-slim AS builder

RUN apt update && apt install -y \
  curl \
  git \
  make \
  python-scipy \
  zlib1g-dev

RUN curl -L https://github.com/benedictpaten/sonLib/archive/1040ab0857f888b4b3112c394f646ab61727f00d.tar.gz | \
      tar -xzf - \
  && mv sonLib-* sonLib 

RUN curl -L https://github.com/benedictpaten/pinchesAndCacti/archive/85b67f3795d55b5e0f812a9a4d0c82a49243c607.tar.gz | \
      tar -xzf - \
  && mv pinchesAndCacti-* pinchesAndCacti

RUN cd sonLib && make
RUN cd pinchesAndCacti && make

WORKDIR /mafTools

COPY . .

RUN make
# RUN make test

FROM debian:buster-20200607-slim
RUN apt update && apt install -y --no-install-recommends python-numpy \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /mafTools/bin/ /usr/local/bin/

# disable ~/.local when bind mounting home directories
ENV PYTHONNOUSERSITE=1
