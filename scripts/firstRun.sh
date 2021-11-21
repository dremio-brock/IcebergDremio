#!/bin/sh
# Authenticate with the default user and get token

json=$(curl -i -k "http://dremio:9047/apiv2/login" -X POST -H "Content-Type:application/json" -d '{"userName": "dremio","password": "dremio123"}');
token2=$(expr "$json" : '.*"token":"\([^"]*\)"');

# add minio
curl "http://dremio:9047/apiv2/source/minio/?nocache=1637418620647" \
      -X 'PUT' \
      -H "Authorization: _dremio$token2" \
      -H "Content-Type: application/json" \
      -d '{"name":"minio","config":{"credentialType":"ACCESS_KEY","accessKey":"minioadmin","accessSecret":"minioadmin","externalBucketList":[],"enableAsync":true,"compatibilityMode":true,"enableFileStatusCheck":true,"rootPath":"/","propertyList":[{"name":"fs.s3a.endpoint","value":"minio:9000"},{"name":"fs.s3a.path.style.access","value":"true"},{"name":"iceberg.catalog_type","value":"hive"}],"whitelistedBuckets":[],"isCachingEnabled":true,"maxCacheSpacePct":100},"accelerationRefreshPeriod":3600000,"accelerationGracePeriod":10800000,"metadataPolicy":{"deleteUnavailableDatasets":true,"autoPromoteDatasets":false,"namesRefreshMillis":3600000,"datasetDefinitionRefreshAfterMillis":3600000,"datasetDefinitionExpireAfterMillis":10800000,"authTTLMillis":86400000,"updateMode":"PREFETCH_QUERIED"},"type":"S3","accessControlList":{"userControls":[],"roleControls":[]}}';

#add hive metastore
curl "http://dremio:9047/apiv2/source/hive-metastore/?nocache=1637511258412" \
  -X 'PUT' \
  -H "Authorization: _dremio$token2" \
  -H "Content-Type: application/json" \
  -d '{"name":"hive-metastore","config":{"hostname":"hive-metastore","port":9083,"authType":"STORAGE","enableAsync":true,"propertyList":[{"name":"metastore.warehouse.dir","value":"s3a://dremio/"},{"name":"fs.s3a.access.key","value":"minioadmin"},{"name":"fs.s3a.secret.key","value":"minioadmin"},{"name":"fs.s3a.connection.ssl.enabled","value":"false"},{"name":"fs.s3a.path.style.access","value":"true"},{"name":"fs.s3a.endpoint","value":"minio:9000"},{"name":"fs.s3a.impl","value":"org.apache.hadoop.fs.s3a.S3AFileSystem"}],"isCachingEnabledForS3AndAzureStorage":true,"maxCacheSpacePct":100},"accelerationRefreshPeriod":3600000,"accelerationGracePeriod":10800000,"metadataPolicy":{"deleteUnavailableDatasets":true,"namesRefreshMillis":60000,"datasetDefinitionRefreshAfterMillis":3600000,"datasetDefinitionExpireAfterMillis":10800000,"authTTLMillis":86400000,"updateMode":"PREFETCH_QUERIED"},"type":"HIVE3","accessControlList":{"userControls":[],"roleControls":[]}}';

#add postgres
curl 'http://dremio:9047/apiv2/source/postgre/?nocache=1637512411997' \
  -X 'PUT' \
  -H "Authorization: _dremio$token2" \
  -H 'Content-Type: application/json' \
  -d '{"config":{"username":"admin","password":"admin","hostname":"metastore-db","port":"5432","databaseName":"metastore_db","useSsl":false,"authenticationType":"MASTER","fetchSize":200,"maxIdleConns":8,"idleTimeSec":60,"encryptionValidationMode":"CERTIFICATE_AND_HOSTNAME_VALIDATION","propertyList":[]},"name":"postgre","accelerationRefreshPeriod":3600000,"accelerationGracePeriod":10800000,"metadataPolicy":{"deleteUnavailableDatasets":true,"namesRefreshMillis":3600000,"datasetDefinitionRefreshAfterMillis":3600000,"datasetDefinitionExpireAfterMillis":10800000,"authTTLMillis":86400000,"updateMode":"PREFETCH_QUERIED"},"type":"POSTGRES","accessControlList":{"userControls":[],"roleControls":[]}}';


# Add support keys to enable iceberg

curl -X POST \
  http://dremio:9047/api/v3/sql \
  -H "Authorization: _dremio$token2" \
  -H 'Content-Type: application/json' \
  -d '{
	"sql": "ALTER SYSTEM SET \"dremio.iceberg.enabled\" = true;"}';

curl -X POST \
  http://dremio:9047/api/v3/sql \
  -H "Authorization: _dremio$token2" \
  -H 'Content-Type: application/json' \
  -d '{
	"sql": "ALTER SYSTEM SET \"dremio.execution.support_unlimited_splits\" = true;"}';