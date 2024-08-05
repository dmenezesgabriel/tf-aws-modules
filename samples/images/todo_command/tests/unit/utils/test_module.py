import unittest
from unittest.mock import MagicMock, patch

from src.utils.module import Module, Modules


class TestModules(unittest.TestCase):

    @patch("src.utils.module.importlib.import_module")
    @patch("src.utils.module.getattr")
    @patch("src.utils.module.Resource.load_json")
    def test_get_class_instance_success(
        self, mock_load_json, mock_getattr, mock_import_module
    ):
        # Arrange
        mock_class_instance = MagicMock()
        mock_getattr.return_value = mock_class_instance
        mock_import_module.return_value = MagicMock()

        # Act
        result = Modules.get_class_instance(
            "some.path", "SomeClass", "arg1", kwarg1="value1"
        )

        # Assert
        mock_import_module.assert_called_once_with("some.path")
        mock_getattr.assert_called_once_with(
            mock_import_module.return_value, "SomeClass"
        )
        mock_class_instance.assert_called_once_with("arg1", kwarg1="value1")
        self.assertEqual(result, mock_class_instance.return_value)

    @patch("src.utils.module.importlib.import_module")
    @patch("src.utils.module.getattr")
    @patch("src.utils.module.logger")
    def test_get_class_instance_exception(
        self, mock_logger, mock_getattr, mock_import_module
    ):
        # Arrange
        mock_import_module.side_effect = Exception("import error")
        mock_getattr.side_effect = Exception("getattr error")

        # Act
        result = Modules.get_class_instance(
            "some.invalid.path", "InvalidClass"
        )

        # Assert
        mock_import_module.assert_called_once_with("some.invalid.path")
        mock_logger.info.assert_called_once_with("Error: import error")
        self.assertIsNone(result)

    @patch("src.utils.module.Modules.get_class_instance")
    @patch("src.utils.module.Resource.load_json")
    def test_get_class_default_instance(
        self, mock_load_json, mock_get_class_instance
    ):
        # Arrange
        mock_load_json.return_value = {
            "ssm": {"path": "some.path", "class_name": "SomeClass"},
            "environment": {"path": "other.path", "class_name": "OtherClass"},
        }
        mock_instance = MagicMock()
        mock_get_class_instance.return_value = mock_instance

        # Act
        result = Modules.get_class_default_instance(
            Module.SSM_PARAMETER_STORE, "arg1", kwarg1="value1"
        )

        # Assert
        mock_load_json.assert_called_once_with("modules.json")
        mock_get_class_instance.assert_called_once_with(
            "some.path", "SomeClass", "arg1", kwarg1="value1"
        )
        self.assertEqual(result, mock_instance)


if __name__ == "__main__":
    unittest.main()
