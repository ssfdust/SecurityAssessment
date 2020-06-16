FROM python:3.8-slim

ENV FLASK_ENV="production" \
      FLASK_APP="/Application/smorest_sfs/app.py" \
      HOST="0.0.0.0" \
      PYTHONPYCACHEPREFIX="/pycache" \
      LOGURU_LEVEL=INFO \
      PUID=1000 \
      PGID=1000 \
      PIP_FLAGS='--no-cache-dir -q' \
      PHANTOMJS_VERSION=2.1.1 \
      PHANTOMJS_PLATFORM=linux-x86_64 \
      APP="web"

WORKDIR /tmp

RUN apt-get update && apt-get install -y wget bzip2 gcc fonts-wqy-microhei

RUN wget -q -O /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-${PHANTOMJS_VERSION}-${PHANTOMJS_PLATFORM}.tar.bz2 && \
  tar -xjf /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 -C /tmp && \
  rm -f /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 && \
  mv /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64/ /usr/local/share/phantomjs && \
  ln -s /usr/local/share/phantomjs/bin/phantomjs /usr/local/bin/phantomjs

RUN mkdir Application

# set working directory to /app/
WORKDIR /Application/
# add requirements.txt to the image
COPY pyproject.toml poetry.lock /Application/

RUN pip install $PIP_FLAGS --upgrade pip poetry pip-autoremove \
        && pip install $PIP_FLAGS --upgrade pip poetry pip-autoremove \
        && pip install $PIP_FLAGS --no-build-isolation pendulum \
        && poetry config virtualenvs.create false \
        && poetry install --no-dev --no-interaction --no-ansi --no-root \
        && pip install $PIP_FLAGS --upgrade pip poetry pip-autoremove \
        && pip-autoremove poetry -y \
        && pip uninstall -y pip-autoremove \
        && rm -rf ~/.cache \
        && wget https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh -O /usr/bin/wait-for-it \
        && chmod 755 /usr/bin/wait-for-it \
        && apt-get remove -y gcc wget bzip2 --purge \
        && apt-get autoremove -y \
        && apt-get clean \
        && rm -rf /pycache

RUN python -c "from text2vec import Similarity;Similarity().load_model()"

CMD ["/bin/sh", "scripts/initapp.sh"]
