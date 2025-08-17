import os

import boto3
from moto import mock_aws
from airflow.providers.amazon.aws.hooks.s3 import S3Hook


def test_s3_hook_uploads_log():
    """S3Hook should store log content at the expected path."""
    with mock_aws():
        bucket = "airbridge-logs"
        key = "logs/dag/run/task/1.log"
        s3 = boto3.client("s3", region_name="us-east-1")
        s3.create_bucket(Bucket=bucket)

        os.environ["AIRFLOW_CONN_AWS_DEFAULT"] = "aws://access_key:secret_key@"

        hook = S3Hook(aws_conn_id="aws_default")
        hook.load_string("log line", key=key, bucket_name=bucket)

        obj = s3.get_object(Bucket=bucket, Key=key)
        assert obj["Body"].read() == b"log line"
