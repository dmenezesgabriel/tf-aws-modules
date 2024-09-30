import logging

import boto3

logger = logging.getLogger()
logger.setLevel("INFO")


def lambda_handler(event, context):
    # Get the email details from the event
    subject = event["subject"]
    body = event["body"]
    sender = event["sender"]
    recipient = event["recipient"]

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
