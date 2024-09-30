import json
from unittest.mock import MagicMock, patch

import boto3
import pytest
from botocore.exceptions import ClientError
from moto import mock_aws
from src import lambda_function


@pytest.fixture(scope="class")
def ses_client():
    with mock_aws():
        client = boto3.client("ses", region_name="us-east-1")
        client.verify_email_identity(EmailAddress="sender@example.com")
        yield client


@pytest.fixture
def event():
    return {
        "body": json.dumps(
            {
                "subject": "Test Subject",
                "body": "Test Body",
                "sender": "sender@example.com",
                "recipients": ["recipient@example.com"],
            }
        )
    }


class TestLambdaFunction:

    def test_parse_event(self, event):
        result = lambda_function.parse_event(event)
        assert result.subject == "Test Subject"
        assert result.body == "Test Body"
        assert result.sender == "sender@example.com"
        assert result.recipients == ["recipient@example.com"]

    def test_send_email_success(self, ses_client):
        email_params = lambda_function.EmailParams(
            subject="Test Subject",
            body="Test Body",
            sender="sender@example.com",
            recipients=["recipient@example.com"],
        )
        email_sender = lambda_function.EmailSender()
        message_id = email_sender.send_email(email_params)
        assert message_id is not None

    @patch("boto3.client")
    def test_send_email_failure(self, mock_boto3_client):
        mock_ses_client = MagicMock()
        mock_ses_client.send_email.side_effect = ClientError(
            {
                "Error": {
                    "Code": "MessageRejected",
                    "Message": "Email address is not verified.",
                }
            },
            "SendEmail",
        )
        mock_boto3_client.return_value = mock_ses_client

        email_params = lambda_function.EmailParams(
            subject="Test Subject",
            body="Test Body",
            sender="sender@example.com",
            recipients=["recipient@example.com"],
        )
        email_sender = lambda_function.EmailSender()
        with pytest.raises(ClientError):
            email_sender.send_email(email_params)

    @patch("src.lambda_function.EmailSender.send_email")
    def test_lambda_handler_success(self, mock_send_email, event):
        mock_send_email.return_value = "test-message-id"
        context = MagicMock()
        context.aws_request_id = "test-request-id"
        context.memory_limit_in_mb = 128
        context.get_remaining_time_in_millis.return_value = 3000

        result = lambda_function.lambda_handler(event, context)
        assert result["statusCode"] == 200
        assert "Email sent successfully!" in result["body"]

    @patch("src.lambda_function.EmailSender.send_email")
    def test_lambda_handler_failure(self, mock_send_email, event):
        mock_send_email.side_effect = ClientError(
            {
                "Error": {
                    "Code": "MessageRejected",
                    "Message": "Email address is not verified.",
                }
            },
            "SendEmail",
        )
        context = MagicMock()
        context.aws_request_id = "test-request-id"
        context.memory_limit_in_mb = 128
        context.get_remaining_time_in_millis.return_value = 3000

        result = lambda_function.lambda_handler(event, context)
        assert result["statusCode"] == 500

        assert "error" in result["body"].lower()

        body_json = json.loads(result["body"])
        assert "MessageRejected" in body_json.get("error", "")
