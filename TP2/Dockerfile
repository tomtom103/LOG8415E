FROM ubuntu
ENV HADOOP_HOME /usr/local/hadoop-3.3.4
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64

RUN \
  apt-get update && apt-get install -y \
  ssh rsync vim default-jre-headless default-jdk openssh-server time make

RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz && tar -xf hadoop-3.3.4.tar.gz -C /usr/local/ && \
	echo "export PATH=$PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$PATH" >> ~/.bashrc  && \
	echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
  echo "export HADOOP_LOG_DIR=${HADOOP_HOME}/logs" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
RUN \
  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
  chmod 0600 ~/.ssh/authorized_keys 
RUN /etc/init.d/ssh start


# Install python 
RUN apt-get install -y python3 python3-pip python3-venv

COPY requirements.txt /root/requirements.txt

RUN python3 -m venv /root/.venv && \
  . /root/.venv/bin/activate && pip install -r /root/requirements.txt  

RUN mkdir -p /root/results

# Allows us to skip the unknown host message
ADD configs/config /root/.ssh/config

# Copy files over to docker image...
ADD configs/* /root/configs/
ADD files/* /root/files/
ADD scripts/* /root/scripts/
ADD Makefile /root/

ADD java/* /root/java/

RUN cd /root/java && \
  HADOOP_CLASSPATH=${JAVA_HOME}/lib/tools.jar \
  $HADOOP_HOME/bin/hadoop com.sun.tools.javac.Main \
  Recommendation.java && \
  jar cf recommendation.jar Recommendation*.class

WORKDIR /root
EXPOSE 50070
ENTRYPOINT service ssh restart && bash