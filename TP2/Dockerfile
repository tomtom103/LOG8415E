FROM ubuntu
ENV HADOOP_PREFIX /usr/local/hadoop-2.10.1
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64

RUN \
  apt-get update && apt-get install -y \
  ssh rsync vim default-jre-headless default-jdk openssh-server time make

RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-2.10.1/hadoop-2.10.1.tar.gz && tar -xf hadoop-2.10.1.tar.gz -C /usr/local/ && \
	echo "export PATH=$PATH:$JAVA_HOME/bin:$HADOOP_PREFIX/bin:$PATH" >> ~/.bashrc  && \
	echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && \
  echo "export HADOOP_LOG_DIR=${HADOOP_PREFIX}/logs" >> $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
RUN \
  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
  chmod 0600 ~/.ssh/authorized_keys 
RUN /etc/init.d/ssh start

RUN mkdir -p /root/results

ADD configs/* /root/configs/
ADD files/* /root/files/
ADD Makefile /root/
COPY wordcount.sh /root/wordcount.sh

WORKDIR /root
EXPOSE 50070
ENTRYPOINT service ssh restart && bash