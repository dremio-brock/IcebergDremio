from os import environ
import findspark
from pyspark import sql, SparkConf, SparkContext
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from py4j.java_gateway import java_import
import time
import configparser
import socket
findspark.init()


def start_spark(storage, config_section, catalog_type):
    """
    Create a spark with the defaults set for a specific storage type and iceberg catalog settings
    :param storage: adls, s3, minio
    :param config_section: the section to look for storage settings
    :param catalog_type: hive, hadoop, or glue catalog
    """
    # add Iceberg dependency
    ICEBERG_VERSION="0.12.1"
    DEPENDENCIES="org.apache.iceberg:iceberg-spark3-runtime:{}".format(ICEBERG_VERSION)

    # Read config file
    config = configparser.ConfigParser()
    config.read('config.ini')

    # get the endpoint ip address, spark doesn't like docker hostnames
    ENDPOINT = 'http://' + socket.gethostbyname('minio') + ':9000'
    
    # initialize sparkConf
    conf = SparkConf()
    
    # Set warehouse location
    warehouse = config[config_section]['warehouse']
    
    # dummy hive_uri
    hive_uri = None
    
    if storage == 'minio':
        ACCESS_KEY_ID = config[config_section]['ACCESS_KEY_ID']
        SECRET_ACCESS_KEY = config[config_section]['SECRET_ACCESS_KEY']
        
        
        # add dependencies
        DEPENDENCIES+=",org.apache.hadoop:hadoop-aws:3.2.0"
        DEPENDENCIES+=",com.amazonaws:aws-java-sdk-bundle:1.11.375"
        
        # add spark conf
        conf.set("spark.hadoop.fs.s3a.access.key", ACCESS_KEY_ID)
        conf.set("spark.hadoop.fs.s3a.secret.key", SECRET_ACCESS_KEY)
        conf.set("spark.hadoop.fs.s3a.endpoint", ENDPOINT)
        conf.set("spark.hadoop.fs.s3a.connection.ssl.enabled", "false")
    elif storage == 's3' and catalog_type == 'glue':
      
        # Get AWS credentials
        ACCESS_KEY_ID = config[config_section]['ACCESS_KEY_ID']
        SECRET_ACCESS_KEY = config[config_section]['SECRET_ACCESS_KEY']
        AWS_REGION = config[config_section]['AWS_REGION']
        
        # set AWS env variables
        environ["AWS_ACCESS_KEY_ID"] = ACCESS_KEY_ID
        environ["AWS_SECRET_ACCESS_KEY"] = SECRET_ACCESS_KEY
        environ["AWS_REGION"] = AWS_REGION
        
        # add dependencies
        DEPENDENCIES+=",software.amazon.awssdk:bundle:2.15.40"
        DEPENDENCIES+=",software.amazon.awssdk:url-connection-client:2.15.40"
        
        # add spark conf
        conf.set("spark.sql.catalog.spark_catalog","org.apache.iceberg.spark.SparkCatalog")
        conf.set("spark.sql.catalog.spark_catalog.io-impl","org.apache.iceberg.aws.s3.S3FileIO")
        conf.set("spark.sql.catalog.spark_catalog","org.apache.iceberg.spark.SparkCatalog")
        conf.set("spark.sql.catalog.spark_catalog.catalog-impl","org.apache.iceberg.aws.glue.GlueCatalog")
        conf.set("spark.sql.catalog.spark_catalog.lock-impl","org.apache.iceberg.aws.glue.DynamoLockManager")
        conf.set("spark.sql.catalog.spark_catalog.lock.table","myGlueLockTable")
        
    elif storage == 's3' and catalog_type in ['hadoop','hive']:
        print('Using S3 with Hive or Hadoop')
        # Get AWS credentials
        ACCESS_KEY_ID = config[config_section]['ACCESS_KEY_ID']
        SECRET_ACCESS_KEY = config[config_section]['SECRET_ACCESS_KEY']
        
        # add dependencies
        DEPENDENCIES+=",org.apache.hadoop:hadoop-aws:3.2.0"
        DEPENDENCIES+=",com.amazonaws:aws-java-sdk-bundle:1.11.375"
        
        # add spark conf
        conf.set("spark.hadoop.fs.s3a.access.key", ACCESS_KEY_ID)
        conf.set("spark.hadoop.fs.s3a.secret.key", SECRET_ACCESS_KEY)

    elif storage == 'adls':
        spark.conf.set("fs.azure.account.key." + storageAccountName + ".blob.core.windows.net", secret)
        
        # add dependencies
        DEPENDENCIES+=",org.apache.hadoop:hadoop-azure:3.2.0"
        DEPENDENCIES+=",com.microsoft.azure:azure-storage:7.0.0" 
        DEPENDENCIES+=",org.apache.hadoop:hadoop-azure-datalake:3.2.0"
    else:
        print('you use a storage type of minio, s3, or adls')
    
    if catalog_type == 'hive':
        hive_uri = config[config_section]['HIVE_URI']
        conf.set("spark.sql.catalog.spark_catalog.type", "hive")
        conf.set("spark.sql.catalog.spark_catalog.uri", hive_uri)
    elif catalog_type == 'hadoop':
        conf.set("spark.sql.catalog.spark_catalog.type", "hadoop")


    # set environment dependencies
    environ['PYSPARK_SUBMIT_ARGS'] = '--packages {} pyspark-shell'.format(DEPENDENCIES)

    # Set iceberg settings
    conf.set('spark.jars.packages', DEPENDENCIES)
    conf.set("spark.sql.catalog.spark_catalog.warehouse", warehouse)
    conf.set("spark.sql.execution.pyarrow.enabled", "true")
    conf.set("spark.sql.catalog.spark_catalog", "org.apache.iceberg.spark.SparkSessionCatalog")
    conf.set("spark.sql.extensions", "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions")
    spark = SparkSession.builder.config(conf=conf).getOrCreate()
    sc = spark.sparkContext
    jvm = sc._gateway.jvm

    # add jars for java operations
    java_import(jvm, "org.apache.iceberg.CatalogUtil")
    java_import(jvm, "org.apache.iceberg.catalog.TableIdentifier")
    java_import(jvm, "org.apache.iceberg.Schema")
    java_import(jvm, "org.apache.iceberg.types.Types")
    java_import(jvm, "org.apache.iceberg.PartitionSpec")
    java_import(jvm, "org.apache.iceberg.actions.Actions")
    return spark, jvm, hive_uri, sc