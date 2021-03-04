FROM ubuntu:18.04
RUN apt update; apt install -y git vim python-pip
RUN mkdir /repos; cd /repos; git clone https://github.com/jdesbonnet/cobratoolbox
RUN cd /repos/cobratoolbox; git checkout doc_build
RUN pip install -r /repos/cobratoolbox/docs/requirements.txt
RUN cd /repos/cobratoolbox/docs; make html
