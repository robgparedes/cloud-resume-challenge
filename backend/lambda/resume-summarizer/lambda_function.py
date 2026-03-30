import json
import boto3

bedrock = boto3.client("bedrock-runtime", region_name="ap-southeast-2")
MODEL_ID = "amazon.nova-lite-v1:0"

def lambda_handler(event, context):
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
        resume_text = (body.get("text", "") or "").strip()

        if not resume_text:
            return {
                "statusCode": 400,
                "headers": {
                    "Access-Control-Allow-Origin": "*",
                    "Content-Type": "application/json"
                },
                "body": json.dumps({"error": "Missing text input"})
            }

        # Keep test inputs small
        resume_text = resume_text[:1500]

        prompt = (
            "Summarize this resume in 3 bullet points for a tech recruiter. "
            "Focus on role, skills, and measurable impact if present.\n\n"
            f"{resume_text}"
        )

        response = bedrock.converse(
            modelId=MODEL_ID,
            messages=[
                {
                    "role": "user",
                    "content": [
                        {"text": prompt}
                    ]
                }
            ],
            inferenceConfig={
                "maxTokens": 150,
                "temperature": 0.3,
                "topP": 0.9
            }
        )

        summary = response["output"]["message"]["content"][0]["text"].strip()

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json"
            },
            "body": json.dumps({"summary": summary})
        }

    except Exception as e:
        print("ERROR:", str(e))
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json"
            },
            "body": json.dumps({"error": str(e)})
        }