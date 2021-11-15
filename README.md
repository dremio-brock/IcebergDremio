
# Iceberg on ADLS with Dremio

A brief description of what this project does and who it's for




## Installation

Install project with docker-compose

Step 1: Create or use an existing Azure Storage Account with Data Lake Storage

Step 2: Create an Azure AD service principal that can access your Azure Storage Accont 
https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal

Step 4: clone repo

```bash
git clone GITHUB_CLONE_HOME
cd GITHUB_CLONE_HOME
```

Step 3: Configure copy and rename conf/metastore-site-SAMPLE.xml to conf/metastore-site.xml
Fill in your azure storage account key and account information

```bash
 <property>
      <name>metastore.warehouse.dir</name>
      <value>wasbs://{azure-adls-container}@{azure-adls-container}.blob.core.windows.net/iceberg/warehouse</value>
  </property>
 <property>
      <name>fs.azure.account.key.{azure-adls-container}.blob.core.windows.net</name>
      <value></value>
  </property>
```
   
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
- Add your Hive datasource by clicking the + button next to "Data Lake"
- Select Hive 3.x
- Give the source a name, fill in the URL as "hive-metastore"
- Under Advanced options, add a new property
     - name=fs.azure.account.key.{account}.blob.core.windows.net
     - value=your account key
- Enable Iceberg in Dremio follow the instructions here for enabling iceberg in Dremio: http://docs.dremio.com/data-formats/iceberg-enabling/

After Dremio is setup, you can begin querying Iceberg tables. \
\
*Notes*
- By default Dremio Dremio will read the new Iceberg metadata file every 60 seconds.
- If a table does not show up when browsing a source, this may be due to metadata collection, either turn down the timer on the source, or query the new dataset directly in a new query window.


## Create some Iceberg Tables
Work with Iceberg using Spark 

Demo 1: 
- Begin working with the code to learn how to create spark tables and perform some operations. \
Demo 2: 
- Run micro batches to insert data into an iceberg tables \

Dremio:
- While working with your iceberg tables, you can use Dremio to start query the results. Those results can then be used in external tools such as Tableau, Power BI, dbeaver, etc by connecting directly to Drmeio. 
- Additionally you can build out a semantic layer in Dremio joining many datasets and providing your tools with a single view of the data. 
