# ==================================== BASE ====================================
ARG INSTALL_PYTHON_VERSION=${INSTALL_PYTHON_VERSION:-3.7}
FROM python:${INSTALL_PYTHON_VERSION}-slim-buster AS base
ENV CONFIG_FILE_PATH=${CONFIG_FILE_PATH:-'/etc/run_config/RUN_CONFIG.yml'}
ENV GUNICORN_CONFIG_FILE_PATH=${GUNICORN_CONFIG_FILE_PATH:-'/etc/gunicorn_config/GUNICORN_CONFIG.py'}

RUN apt-get update
RUN apt-get install -y \
    curl \
    netcat \
    iputils-ping \
    build-essential \
    ssh \
    nodejs

WORKDIR /app
COPY requirements.txt .

RUN useradd -m glados -u 2892
RUN chown -R glados:glados /app
USER glados
ENV PATH="/home/glados/.local/bin:${PATH}"

RUN pip install -U "setuptools<46"
RUN pip install --user -r requirements.txt
COPY . .

FROM base AS development-server
ENTRYPOINT python manage.py runserver 8000

FROM base AS production-server
ENTRYPOINT while true; do echo 'daemon'; sleep 2; done
#ENTRYPOINT python manage.py collectstatic --no-input; python manage.py runserver 8000
#ENTRYPOINT PYTHONPATH=/app/src:$PYTHONPATH gunicorn src.glados.wsgi:APP -b 0.0.0.0:8000 -c ${GUNICORN_CONFIG_FILE_PATH}