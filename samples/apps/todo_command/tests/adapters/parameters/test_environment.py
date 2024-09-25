import unittest
from unittest.mock import patch

from src.adapters.exceptions import ParameterNotFound
from src.adapters.parameters.environment import (
    EnvironmentParameterStoreAdapter,
)


class TestEnvironmentParameterStoreAdapter(unittest.TestCase):

    @patch("src.adapters.parameters.environment.os.getenv")
    def test_get_parameter_from_env(self, mock_getenv):
        # Arrange
        mock_getenv.return_value = "fake_value"
        adapter = EnvironmentParameterStoreAdapter()

        # Act
        result = adapter.get_parameter("fake_key")

        # Assert
        mock_getenv.assert_called_once_with("fake_key")
        self.assertEqual(result, "fake_value")

    @patch("src.adapters.parameters.environment.os.getenv")
    def test_get_parameter_not_found(self, mock_getenv):
        # Arrange
        mock_getenv.return_value = None
        adapter = EnvironmentParameterStoreAdapter()

        # Act & Assert
        with self.assertRaises(ParameterNotFound) as context:
            adapter.get_parameter("fake_key")

        mock_getenv.assert_called_once_with("fake_key")
        self.assertEqual(
            context.exception.args[0]["code"],
            "environment.error.__get_parameter",
        )
        self.assertEqual(
            context.exception.args[0]["message"], "Parameter not found"
        )

    @patch("src.adapters.parameters.environment.os.getenv")
    def test_get_parameter_from_map(self, mock_getenv):
        # Arrange
        mock_getenv.return_value = "mapped_value"
        parameter_map = {"fake_name": "mapped_key"}
        adapter = EnvironmentParameterStoreAdapter(parameter_map=parameter_map)

        # Act
        result = adapter.get_parameter("fake_name")

        # Assert
        mock_getenv.assert_called_once_with("mapped_key")
        self.assertEqual(result, "mapped_value")


if __name__ == "__main__":
    unittest.main()
