import json
import os
import boto3
from botocore.exceptions import ClientError

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ.get("TABLE_NAME", "cloudresume-visitor-count")

CORS_HEADERS = {
    "Access-Control-Allow-Origin": "https://robertgparedes.com",
    "Access-Control-Allow-Headers": "content-type",
    "Access-Control-Allow-Methods": "POST,OPTIONS",
}

def lambda_handler(event, context):
    method = event.get("requestContext", {}).get("http", {}).get("method")

    if method == "OPTIONS":
        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": ""
        }

    table = dynamodb.Table(TABLE_NAME)

    try:
        response = table.update_item(
            Key={"id": "visitors"},
            UpdateExpression="ADD #c :inc",
            ExpressionAttributeNames={"#c": "count"},
            ExpressionAttributeValues={":inc": 1},
            ReturnValues="UPDATED_NEW",
        )

        count = int(response["Attributes"]["count"])

        return {
            "statusCode": 200,
            "headers": {**CORS_HEADERS, "Content-Type": "application/json"},
            "body": json.dumps({"count": count}),
        }

    except ClientError as e:
        return {
            "statusCode": 500,
            "headers": {**CORS_HEADERS, "Content-Type": "application/json"},
            "body": json.dumps({"error": e.response["Error"]["Message"]}),
        }