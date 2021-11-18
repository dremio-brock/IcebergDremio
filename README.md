
# Iceberg on ADLS / S3 / MINIO with Dremio via Hive or Hadoop catalog

A brief description of what this project does and who it's for




## Installation

Install project with docker-compose

Step 1: Create or use an existing Azure Storage Account with Data Lake Storage, AWS S3 account or use the local MINIO provided

Step 2: Obtain storage your account secrect

Step 4: clone repo

```bash
git clone https://github.com/dremio-brock/IcebergDremio.git
cd IcebergDremio
```

Step 3: Configure conf/metastore-site.xml 
Uncomment the type of storage you wish to use and fill in your account information

*Note on first run with Minio, you will need to create a service account to get the key & secret. Hive will need to be restarted once the metastore-site.xml is updated.
   
Step 4: Build and run

```bash
docker-compose build 
docker-compose up -d
```

Step 5: Jupyter Notebook \
\
Login to your notebook from the web browser localhost:8888
Your token can be obtained from using the docker log command
```bash
docker logs notebook
```

Step 6: Modify your Config\
\
In the work directory, create a copy of the config-sample.ini and rename it to config.ini\
open the new file and add in your config.\
\
If you wish to demo loading streaming data from an api such as the one used here you will need to obtain your own api keys.


## Setup Dremio

- Open dremio by going to the url localhost:9047
- Accept the EULA and create a user for Dremio
- Enable Iceberg in Dremio follow the instructions here for enabling iceberg in Dremio: http://docs.dremio.com/data-formats/iceberg-enabling/

## Hive Catalog:
You can chose to use the hive catalog, or a hadoop catalog. If you are using the hive catalog you will need to use hive as your source. docker-compose is mounting your metastore-site.xml to the proper hive conf directory in Dremio. 

- Add your Hive datasource by clicking the + button next to "Data Lake"
- Select Hive 3.x
- Give the source a name, fill in the URL as "hive-metastore"

## Hadoop Catalog:
If you wish to use the hadoop catalog, you will need to add the data lake source for the storage type you are using.
Additionally, you will need to add an advanced property to the source
- name=iceberg.catalog_type
- value=hadoop


*Note Minio requires extra steps outlined here: http://docs.dremio.com/data-sources/s3/#configuring-s3-for-minio

## 

After Dremio is setup, you can begin querying Iceberg tables. \
\
*Notes*
- By default Dremio Dremio will read the new Iceberg metadata file every 60 seconds.
- If a table does not show up when browsing a source, this may be due to metadata collection, either turn down the timer on the source, or query the new dataset directly in a new query window.


## Create some Iceberg Tables
Work with Iceberg using Spark. I have simplified the configuration and setup of spark using the python file called iceberg_spark.py. When you wish to use spark, you can import and call the function within. 

Demo 1: 
- Begin working with the code to learn how to create spark tables and perform some operations. 

Demo 2: 
- Run micro batches to insert data into an iceberg tables 

Dremio:
- While working with your iceberg tables, you can use Dremio to start query the results. Those results can then be used in external tools such as Tableau, Power BI, dbeaver, etc by connecting directly to Drmeio. 
- Additionally you can build out a semantic layer in Dremio joining many datasets and providing your tools with a single view of the data. 
