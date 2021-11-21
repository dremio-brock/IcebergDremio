#!/bin/bash
export HADOOP_HOME=/opt/hadoop-3.2.0
export HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/azure-data-lake-store-sdk-2.2.9.jar:${HADOOP_HOME}/share/hadoop/tools/lib/azure-storage-7.0.0.jar:${HADOOP_HOME}/share/hadoop/tools/lib/azure-keyvault-core-1.0.0.jar:${HADOOP_HOME}/share/hadoop/common/hadoop-common-3.2.0.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-azure-3.2.0.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-azure-datalake-3.2.0.jar:${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-1.11.375.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-3.2.0.jar
export JAVA_HOME=/usr/local/openjdk-8

/opt/apache-hive-metastore-3.0.0-bin/bin/schematool -initSchema -dbType postgres
/opt/apache-hive-metastore-3.0.0-bin/bin/start-metastore
