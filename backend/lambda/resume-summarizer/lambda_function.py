import json
import boto3

bedrock = boto3.client("bedrock-runtime", region_name="ap-southeast-2")

def lambda_handler(event, context):

    # Handle OPTIONS (CORS preflight)
    method = event.get("requestContext", {}).get("http", {}).get("method")
    if method == "OPTIONS":
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "content-type",
                "Access-Control-Allow-Methods": "POST,OPTIONS",
            },
            "body": ""
        }

    try:
        body = json.loads(event.get("body", "{}"))
        resume_text = body.get("text", "")

        prompt = f"Summarize this resume in 3 bullet points for a tech recruiter:\n{resume_text}"

        response = bedrock.invoke_model(
            modelId="anthropic.claude-3-haiku-20240307-v1:0",
            contentType="application/json",
            accept="application/json",
            body=json.dumps({
                "anthropic_version": "bedrock-2023-05-31",
                "max_tokens": 200,
                "messages": [
                    {"role": "user", "content": prompt}
                ]
            })
        )

        result = json.loads(response["body"].read())
        summary = result["content"][0]["text"]

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json"
            },
            "body": json.dumps({"summary": summary})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({"error": str(e)})
        }