#!/bin/sh -l

set -eu

mkdir -p ~/.aws
echo -e "[default]\naws_access_key_id=${AWS_ACCESS_KEY_ID}\naws_secret_access_key=${AWS_SECRET_ACCESS_KEY}" >~/.aws/credentials
echo -e "[default]\nregion=${AWS_REGION}\noutput=json" >~/.aws/config

FLAGS=""
if [ -z "${WITH_DELETE}" ]; then
  FLAGS="${FLAGS} --delete"
fi

aws s3 sync ${SOURCE} s3://${AWS_BUCKET_NAME}/${TARGET} ${FLAGS}

if [ -z "${WITH_CLOUD_FRONT_INVALIDATION}" ]; then
  if [ -z "${AWS_CLOUDFRONT_DISTRIBUTION_ID}" ]; then
    echo "Impossible to request an invalidation we need the AWS_CLOUDFRONT_DISTRIBUTION_ID value"
    exit 3
  else
    aws cloudfront create-invalidation --distribution-id ${AWS_CLOUDFRONT_DISTRIBUTION_ID} --paths "${TARGET}"
  fi
fi

rm -rf ~/.aws