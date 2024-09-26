import json
import unittest
from unittest.mock import mock_open, patch

from src.utils.resources import (
    Resource,
)  # Replace 'src.utils.resources' with the actual module path


class TestResource(unittest.TestCase):

    @patch("src.utils.resources.os.path.isfile")
    @patch("src.utils.resources.os.getcwd")
    def test_load_json_file_not_found(self, mock_getcwd, mock_isfile):
        # Arrange
        mock_getcwd.return_value = "/fake/directory"
        mock_isfile.return_value = False

        # Act & Assert
        with self.assertRaises(FileNotFoundError):
            Resource.load_json("nonexistent.json")

    @patch("src.utils.resources.os.path.isfile")
    @patch("src.utils.resources.os.getcwd")
    @patch("src.utils.resources.json.load")
    def test_load_json_success(self, mock_json_load, mock_getcwd, mock_isfile):
        # Arrange
        mock_getcwd.return_value = "/fake/directory"
        mock_isfile.return_value = True
        mock_json_load.return_value = {"key": "value"}
        mock_open_instance = mock_open(read_data='{"key": "value"}')

        with patch("builtins.open", mock_open_instance):
            # Act
            result = Resource.load_json("test.json")

        # Assert
        mock_isfile.assert_called_once_with(
            "/fake/directory/src/resources/test.json"
        )
        mock_open_instance.assert_called_once_with(
            "/fake/directory/src/resources/test.json", "r"
        )
        mock_json_load.assert_called_once_with(mock_open_instance())
        self.assertEqual(result, {"key": "value"})

    @patch("src.utils.resources.os.path.isfile")
    @patch("src.utils.resources.os.getcwd")
    @patch("src.utils.resources.json.load")
    @patch("src.utils.resources.logger")
    def test_load_json_json_decode_error(
        self, mock_logger, mock_json_load, mock_getcwd, mock_isfile
    ):
        # Arrange
        mock_getcwd.return_value = "/fake/directory"
        mock_isfile.return_value = True
        mock_json_load.side_effect = json.JSONDecodeError(
            "Expecting value", "doc", 0
        )
        mock_open_instance = mock_open(read_data="invalid json")

        with patch("builtins.open", mock_open_instance):
            # Act & Assert
            with self.assertRaises(ValueError):
                Resource.load_json("test.json")
            mock_logger.error.assert_called_once_with(
                "Error: Expecting value: line 1 column 1 (char 0)"
            )

    @patch("src.utils.resources.os.path.isfile")
    @patch("src.utils.resources.os.getcwd")
    @patch("src.utils.resources.json.load")
    @patch("src.utils.resources.logger")
    def test_load_json_generic_exception(
        self, mock_logger, mock_json_load, mock_getcwd, mock_isfile
    ):
        # Arrange
        mock_getcwd.return_value = "/fake/directory"
        mock_isfile.return_value = True
        mock_json_load.side_effect = Exception("generic error")
        mock_open_instance = mock_open(read_data='{"key": "value"}')

        # Act
        with patch("builtins.open", mock_open_instance):
            Resource.load_json("test.json")

        # Assert
        mock_logger.error.assert_called_once_with("Error: generic error")


if __name__ == "__main__":
    unittest.main()
