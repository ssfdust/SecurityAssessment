FROM ssfdust/alpine-python-poetry:latest

ENV FLASK_ENV="production" \
      FLASK_APP="/Application/smorest_sfs/app.py" \
      HOST="0.0.0.0" \
      PYTHONPYCACHEPREFIX="/pycache" \
      LOGURU_LEVEL=INFO \
      PUID=1000 \
      PGID=1000 \
      APP="web"

COPY pyproject.toml poetry.lock /

RUN /entrypoint.sh \
        -a zlib \
        -a wqy-zenhei@etesting \
        -a libjpeg \
        -a freetype \
        -a lapack@community \
        -a postgresql-libs \
        -a openblas@community \
        -b zlib-dev \
        -b openblas-dev@community \
        -b musl-dev \
        -b lapack-dev@community \
        -b libxslt-dev \
        -b libffi-dev \
        -b jpeg-dev \
        -b freetype-dev \
        -b postgresql-dev \
    && wget https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh -O /usr/bin/wait-for-it \
    && chmod 755 /usr/bin/wait-for-it \
    && mkdir Application

WORKDIR /tmp

RUN apk add --update --no-cache curl \
        && cd /tmp && curl -Ls https://github.com/dustinblackman/phantomized/releases/download/2.1.1/dockerized-phantomjs.tar.gz | tar xz \
        && cp -R lib lib64 / \
        && cp -R usr/lib/x86_64-linux-gnu /usr/lib \
        && cp -R usr/share/fonts /usr/share \
        && cp -R etc/fonts /etc \
        && curl -k -Ls https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 | tar -jxf - \
        && cp phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs \
        && rm -rf /tmp/*

RUN addgroup -g ${PGID} webapp && \
    adduser -D -u ${PUID} -G webapp webapp

WORKDIR /Application/

USER webapp

CMD ["/bin/sh", "scripts/initapp.sh"]
