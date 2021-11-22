
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

*Note on first run with Minio, it will automatically create a bucket with a  account key and secret minioadmin:minioadmin
   
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
In the work directory, modify config.ini with your settings. If you are using minio, no changes are needed.\
\
If you wish to demo loading streaming data from an api such as the one used here you will need to obtain your own api keys.


## Setup Dremio

- Open dremio by going to the url localhost:9047
- A default username and password dremio:dremio123 has been created already
- The Dremio startup script enables iceberg automatically as described here: http://docs.dremio.com/data-formats/iceberg-enabling/

## Sources
By default a Minio source has been created and added as well as the hive source. Steps to do so are outlined here: http://docs.dremio.com/data-sources/s3/#configuring-s3-for-minio\
The default minio credentials are minioadmin:minioadmin\
\
**When querying from the hive source, the catalog should be set to iceberg.catalog_type=hive (default)\
**When using a file based source, the catalog should be set to iceberg.catalog_type=hadoop (default)

## Notes

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
