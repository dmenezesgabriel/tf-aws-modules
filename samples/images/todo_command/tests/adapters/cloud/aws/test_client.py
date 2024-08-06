import os
import unittest
from unittest.mock import MagicMock, patch

from src.adapters.cloud.aws.client import AWSClientAdapter


class TestAWSClientAdapter(unittest.TestCase):

    @patch.dict(
        os.environ,
        {
            "AWS_ACCESS_KEY_ID": "fake_access_key",
            "AWS_SECRET_ACCESS_KEY": "fake_secret_key",
            "AWS_SESSION_TOKEN": "fake_session_token",
            "AWS_ENDPOINT_URL": "http://fakeendpoint.com",
            "AWS_REGION_NAME": "fake-region",
        },
    )
    @patch("boto3.client")
    def test_create_client_with_env_credentials(self, mock_boto_client):
        # Arrange
        mock_client = MagicMock()
        mock_boto_client.return_value = mock_client

        # Act
        adapter = AWSClientAdapter(client_type="s3")

        # Assert
        mock_boto_client.assert_called_once_with(
            "s3",
            endpoint_url="http://fakeendpoint.com",
            aws_access_key_id="fake_access_key",
            aws_secret_access_key="fake_secret_key",
            aws_session_token="fake_session_token",
            region_name="fake-region",
        )
        self.assertEqual(adapter.client, mock_client)

    @patch.dict(
        os.environ,
        {
            "AWS_ACCESS_KEY_ID": "",
            "AWS_SECRET_ACCESS_KEY": "",
            "AWS_SESSION_TOKEN": "",
            "AWS_ENDPOINT_URL": "",
            "AWS_REGION_NAME": "fake-region",
        },
    )
    @patch("boto3.Session")
    @patch("boto3.client")
    def test_create_client_with_session_credentials(
        self, mock_boto_client, mock_boto_session
    ):
        # Arrange
        mock_credentials = MagicMock()
        mock_credentials.access_key = "session_access_key"
        mock_credentials.secret_key = "session_secret_key"
        mock_credentials.token = "session_token"

        mock_session = MagicMock()
        mock_session.get_credentials.return_value = mock_credentials

        mock_boto_session.return_value = mock_session
        mock_client = MagicMock()
        mock_boto_client.return_value = mock_client

        # Act
        adapter = AWSClientAdapter(client_type="s3")

        # Assert
        mock_boto_session.assert_called_once()
        mock_session.get_credentials.assert_called_once()
        mock_boto_client.assert_called_once_with(
            "s3",
            endpoint_url="",  # Adjusted to match the actual call
            aws_access_key_id="session_access_key",
            aws_secret_access_key="session_secret_key",
            aws_session_token="session_token",
            region_name="fake-region",
        )
        self.assertEqual(adapter.client, mock_client)

    @patch.dict(
        os.environ,
        {
            "AWS_ACCESS_KEY_ID": "",
            "AWS_SECRET_ACCESS_KEY": "",
            "AWS_SESSION_TOKEN": "",
            "AWS_ENDPOINT_URL": "",
            "AWS_REGION_NAME": "fake-region",
        },
    )
    @patch("boto3.Session")
    @patch("boto3.client")
    @patch("src.adapters.cloud.aws.client.logger")
    def test_create_client_session_error(
        self, mock_logger, mock_boto_client, mock_boto_session
    ):
        # Arrange
        mock_boto_session.side_effect = Exception("session error")

        # Act & Assert
        with self.assertRaises(Exception) as context:
            AWSClientAdapter(client_type="s3")

        self.assertEqual(str(context.exception), "session error")
        mock_logger.error.assert_called_once_with(
            "Failed to get credentials from session: session error"
        )

    @patch.dict(
        os.environ,
        {
            "AWS_ACCESS_KEY_ID": "fake_access_key",
            "AWS_SECRET_ACCESS_KEY": "fake_secret_key",
            "AWS_SESSION_TOKEN": "fake_session_token",
            "AWS_ENDPOINT_URL": "http://fakeendpoint.com",
            "AWS_REGION_NAME": "fake-region",
        },
    )
    @patch("boto3.client")
    @patch("src.adapters.cloud.aws.client.logger")
    def test_create_client_error(self, mock_logger, mock_boto_client):
        # Arrange
        mock_boto_client.side_effect = Exception("client error")

        # Act & Assert
        with self.assertRaises(Exception) as context:
            AWSClientAdapter(client_type="s3")

        self.assertEqual(str(context.exception), "client error")
        mock_logger.error.assert_called_once_with(
            "Failed to create s3: client error"
        )


if __name__ == "__main__":
    unittest.main()
