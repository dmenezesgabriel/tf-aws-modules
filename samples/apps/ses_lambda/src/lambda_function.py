import json
import logging
import os
import time
from dataclasses import asdict, dataclass
from typing import Any, Dict

import boto3
from botocore.exceptions import BotoCoreError, ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)


class JsonFormatter(logging.Formatter):
    def format(self, record):
        log_record = {
            "timestamp": self.formatTime(record, self.datefmt),
            "level": record.levelname,
            "message": record.getMessage(),
            "logger": record.name,
            "function": record.funcName,
            "line": record.lineno,
        }
        if record.exc_info:
            log_record["exception"] = self.formatException(record.exc_info)
        return json.dumps(log_record)


handler = logging.StreamHandler()
handler.setFormatter(JsonFormatter())
logger.addHandler(handler)


@dataclass
class EmailParams:
    subject: str
    body: str
    sender: str
    recipient: str


class EmailSender:
    def __init__(
        self, region_name: str = os.environ.get("AWS_REGION", "us-east-1")
    ):
        self.client = boto3.client("ses", region_name=region_name)

    def send_email(self, email_params: EmailParams) -> str:
        try:
            logger.info(
                "Attempting to send email",
                extra={"email_params": asdict(email_params)},
            )
            start_time = time.time()
            response = self.client.send_email(
                Source=email_params.sender,
                Destination={"ToAddresses": [email_params.recipient]},
                Message={
                    "Subject": {"Data": email_params.subject},
                    "Body": {"Text": {"Data": email_params.body}},
                },
            )
            end_time = time.time()
            logger.info(
                "Email sent successfully",
                extra={
                    "message_id": response["MessageId"],
                    "response_time": end_time - start_time,
                },
            )
            return response["MessageId"]
        except (BotoCoreError, ClientError) as error:
            logger.exception(
                "Error sending email", extra={"error": str(error)}
            )
            raise


def parse_event(event: Dict[str, Any]) -> EmailParams:
    logger.info("Parsing event", extra={"event": event})
    params = event.get("body", event)
    if isinstance(params, str):
        params = json.loads(params)
    return EmailParams(
        subject=params["subject"],
        body=params["body"],
        sender=params["sender"],
        recipient=params["recipient"],
    )


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    logger.info(
        "Lambda function invoked",
        extra={"aws_request_id": context.aws_request_id},
    )
    start_time = time.time()

    try:
        email_params = parse_event(event)
        email_sender = EmailSender()
        message_id = email_sender.send_email(email_params)

        end_time = time.time()
        logger.info(
            "Lambda execution completed successfully",
            extra={
                "message_id": message_id,
                "execution_time": end_time - start_time,
            },
        )

        return {
            "statusCode": 200,
            "body": json.dumps(
                {
                    "message": "Email sent successfully!",
                    "messageId": message_id,
                }
            ),
        }
    except Exception as error:
        logger.exception(
            "Error processing request", extra={"error": str(error)}
        )
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(error)}),
        }
    finally:
        logger.info(
            "Lambda execution finished",
            extra={
                "total_execution_time": time.time() - start_time,
                "memory_used": context.memory_limit_in_mb,
                "time_remaining": context.get_remaining_time_in_millis(),
            },
        )
