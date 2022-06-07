# Use Hadoop as the base image.
# Since Sqoop requires Hadoop to be running in the background.
FROM ghcr.io/kasipavankumar/hadoop-docker:1.0.3


# Set working directory to / (home).
WORKDIR /



# Download & uncompress Apache Sqoop v1.4.7.
RUN wget -qO- http://archive.apache.org/dist/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz | tar xvz \ 
    && mv sqoop-1.4.7.bin__hadoop-2.6.0 sqoop

# COPY sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz /sqoop

# Set SQOOP_HOME.
ENV SQOOP_HOME=/sqoop

# Update PATH with Sqoop's bin.
ENV PATH=$PATH:${SQOOP_HOME}/bin

# Download & decompress MySQL connector.
RUN wget -qO- http://ftp.ntu.edu.tw/MySQL/Downloads/Connector-J/mysql-connector-java-8.0.26.tar.gz | tar xvz \
    && mv mysql-connector-java-8.0.26/mysql-connector-java-8.0.26.jar $SQOOP_HOME/lib \
    && rm -rf mysql-connector-java-8.0.26

COPY java-json-schema.jar $SQOOP_HOME/lib/

# COPY jar/mysql-connector-java-8.0.26.jar $SQOOP_HOME/lib/

COPY postgresql-42.3.6.jar $SQOOP_HOME/lib/

# Download the commons lang.
RUN wget https://repo1.maven.org/maven2/commons-lang/commons-lang/2.6/commons-lang-2.6.jar \
    && mv commons-lang-2.6.jar $SQOOP_HOME/lib

# Download & unzip a sample database.
# https://dev.mysql.com/doc/employee/en/employees-installation.html
RUN wget https://github.com/datacharmer/test_db/archive/refs/heads/master.zip \
    && unzip master.zip \
    && apt-get remove unzip wget --yes \ 
    && apt-get autoremove --yes

# Rename sqoop-env-template.sh → sqoop-env.sh.
RUN mv $SQOOP_HOME/conf/sqoop-env-template.sh $SQOOP_HOME/conf/sqoop-env.sh

# Edit Hadoop variables in "sqoop-env.sh".
RUN echo "export HADOOP_COMMON_HOME=/hadoop-3.3.1" >> $SQOOP_HOME/conf/sqoop-env.sh \
    && echo "export HADOOP_MAPRED_HOME=/hadoop-3.3.1" >> $SQOOP_HOME/conf/sqoop-env.sh

# Copy required files to the image.
COPY init.sh /

# Set permissions to execute scripts files.
RUN chmod 700 ./bootstrap.sh 

CMD [ "bash", "./init.sh" ]