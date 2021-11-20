#!/bin/sh
# Authenticate with the default user and create a minio source
json=$(curl -i -k "http://dremio:9047/apiv2/login" -X POST -H "Content-Type:application/json" -d '{"userName": "dremio","password": "dremio123"}');
token2=$(expr "$json" : '.*"token":"\([^"]*\)"');
curl "http://dremio:9047/apiv2/source/minio/?nocache=1637418620647" \
      -X 'PUT' \
      -H "Authorization: _dremio$token2" \
      -H "Content-Type: application/json" \
      -d '{"name":"minio","config":{"credentialType":"ACCESS_KEY","accessKey":"minioadmin","accessSecret":"minioadmin","externalBucketList":[],"enableAsync":true,"compatibilityMode":true,"enableFileStatusCheck":true,"rootPath":"/","propertyList":[{"name":"fs.s3a.endpoint","value":"minio:9000"},{"name":"fs.s3a.path.style.access","value":"true"}],"whitelistedBuckets":[],"isCachingEnabled":true,"maxCacheSpacePct":100},"accelerationRefreshPeriod":3600000,"accelerationGracePeriod":10800000,"metadataPolicy":{"deleteUnavailableDatasets":true,"autoPromoteDatasets":false,"namesRefreshMillis":3600000,"datasetDefinitionRefreshAfterMillis":3600000,"datasetDefinitionExpireAfterMillis":10800000,"authTTLMillis":86400000,"updateMode":"PREFETCH_QUERIED"},"type":"S3","accessControlList":{"userControls":[],"roleControls":[]}}';