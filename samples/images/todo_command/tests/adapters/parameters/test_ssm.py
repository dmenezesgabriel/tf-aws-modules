import unittest
from unittest.mock import MagicMock, patch

from botocore.exceptions import ClientError

from src.adapters.cloud.aws.client import AWSClientAdapter
from src.adapters.exceptions import ParameterNotFound, ParameterStoreException
from src.adapters.parameters.ssm import SSMParameterStoreAdapter


class TestSSMParameterStoreAdapter(unittest.TestCase):

    @patch.object(AWSClientAdapter, "__init__", lambda x, client_type: None)
    @patch(
        "src.adapters.cloud.aws.client.AWSClientAdapter.client",
        new_callable=MagicMock,
    )
    def test_get_parameter_success(self, mock_client):
        # Arrange
        mock_client.get_parameter.return_value = {
            "Parameter": {"Value": "test_value"}
        }
        adapter = SSMParameterStoreAdapter()

        # Act
        result = adapter.get_parameter("test_param")

        # Assert
        mock_client.get_parameter.assert_called_once_with(
            Name="test_param", WithDecryption=True
        )
        self.assertEqual(result, "test_value")

    @patch.object(AWSClientAdapter, "__init__", lambda x, client_type: None)
    @patch(
        "src.adapters.cloud.aws.client.AWSClientAdapter.client",
        new_callable=MagicMock,
    )
    def test_get_parameter_not_found(self, mock_client):
        # Arrange
        error_response = {"Error": {"Code": "ParameterNotFound"}}
        mock_client.get_parameter.side_effect = ClientError(
            error_response, "get_parameter"
        )
        adapter = SSMParameterStoreAdapter()

        # Act & Assert
        with self.assertRaises(ParameterNotFound) as context:
            adapter.get_parameter("test_param")

        self.assertEqual(
            context.exception.args[0]["code"], "ssm.error.get_parameter"
        )
        self.assertIn(
            "Parameter not found", context.exception.args[0]["message"]
        )
        mock_client.get_parameter.assert_called_once_with(
            Name="test_param", WithDecryption=True
        )

    @patch.object(AWSClientAdapter, "__init__", lambda x, client_type: None)
    @patch(
        "src.adapters.cloud.aws.client.AWSClientAdapter.client",
        new_callable=MagicMock,
    )
    def test_get_parameter_store_exception(self, mock_client):
        # Arrange
        error_response = {"Error": {"Code": "SomeOtherError"}}
        mock_client.get_parameter.side_effect = ClientError(
            error_response, "get_parameter"
        )
        adapter = SSMParameterStoreAdapter()

        # Act & Assert
        with self.assertRaises(ParameterStoreException) as context:
            adapter.get_parameter("test_param")

        self.assertEqual(
            context.exception.args[0]["code"], "ssm.error.get_parameter"
        )
        self.assertIn(
            "Parameter store error", context.exception.args[0]["message"]
        )
        mock_client.get_parameter.assert_called_once_with(
            Name="test_param", WithDecryption=True
        )

    @patch.object(AWSClientAdapter, "__init__", lambda x, client_type: None)
    @patch(
        "src.adapters.cloud.aws.client.AWSClientAdapter.client",
        new_callable=MagicMock,
    )
    def test_get_parameter_with_map(self, mock_client):
        # Arrange
        mock_client.get_parameter.return_value = {
            "Parameter": {"Value": "mapped_value"}
        }
        parameter_map = {"fake_name": "mapped_key"}
        adapter = SSMParameterStoreAdapter(parameter_map=parameter_map)

        # Act
        result = adapter.get_parameter("fake_name")

        # Assert
        mock_client.get_parameter.assert_called_once_with(
            Name="mapped_key", WithDecryption=True
        )
        self.assertEqual(result, "mapped_value")


if __name__ == "__main__":
    unittest.main()
