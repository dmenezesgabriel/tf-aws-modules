import json
import logging

import boto3

logger = logging.getLogger()
logger.setLevel("INFO")


def lambda_handler(event, context):
    params = event
    if "body" in event:
        params = json.loads(event["body"])
    subject = params["subject"]
    body = params["body"]
    sender = params["sender"]
    recipient = params["recipient"]

    try:
        message_id = send_email(subject, body, sender, recipient)
        logger.info(f"Email sent successfully! Message ID: {message_id}")
        return {
            "statusCode": 200,
            "body": f"Email sent successfully! Message ID: {message_id}",
        }
    except Exception as error:
        logger.error(f"Error sending email: {str(error)}")
        return {
            "statusCode": 500,
            "body": f"Error sending email: {str(error)}",
        }


def send_email(subject, body, sender, recipient):
    client = boto3.client("ses", region_name="us-east-1")
    response = client.send_email(
        Source=sender,
        Destination={"ToAddresses": [recipient]},
        Message={
            "Subject": {"Data": subject},
            "Body": {"Text": {"Data": body}},
        },
    )
    logger.info(response)
    return response["MessageId"]
