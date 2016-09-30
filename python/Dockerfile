FROM ubuntu:16.04
MAINTAINER Chris Cohoat
RUN apt-get -yq update
RUN apt-get install -y git python-pip python-dev build-essential htop

WORKDIR /app
ADD ./requirements.txt /app/requirements.txt
RUN pip install -r requirements.txt
ADD . /app

CMD ["python", "main.py"]