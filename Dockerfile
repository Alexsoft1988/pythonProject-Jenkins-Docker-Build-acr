FROM python:3.8.0-alpine3.10

USER root


WORKDIR /app
COPY source/ /app/source/
COPY ./requirements.txt /app
RUN ls -la /app


RUN python3 --version
RUN pip3 install --upgrade pip
RUN pip3 install --no-cache-dir -r /app/requirements.txt
RUN pip3 list --format=columns

USER 1001


ENTRYPOINT ["python3", "/app/source/main.py"]