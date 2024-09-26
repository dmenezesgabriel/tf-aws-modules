import base64
import unittest
from unittest.mock import patch

from src.utils.singleton import Singleton, SingletonHash, generate_hash


class TestGenerateHash(unittest.TestCase):

    def test_generate_hash(self) -> None:
        # Arrange
        value = "test_value"
        expected_hash = base64.b64encode(value.encode("ascii")).decode("utf8")

        # Act
        result = generate_hash(value)

        # Assert
        self.assertEqual(result, expected_hash)


class TestSingleton(unittest.TestCase):

    def tearDown(self):
        # Ensure Singleton instances are cleared after each test
        Singleton.drop()

    def test_singleton_instance(self):
        # Arrange
        class MyClass(metaclass=Singleton):
            pass

        # Act
        instance1 = MyClass()
        instance2 = MyClass()

        # Assert
        self.assertIs(instance1, instance2)

    def test_singleton_drop(self) -> None:
        # Arrange
        class MyClass(metaclass=Singleton):
            pass

        instance1 = MyClass()

        # Act
        Singleton.drop()
        instance2 = MyClass()

        # Assert
        self.assertIsNot(instance1, instance2)


class TestSingletonHash(unittest.TestCase):

    def tearDown(self) -> None:
        # Ensure SingletonHash instances are cleared after each test
        SingletonHash.drop()

    @patch("src.utils.singleton.generate_hash")
    def test_singleton_hash_instance(self, mock_generate_hash):
        # Arrange
        mock_generate_hash.side_effect = lambda x: (
            "hash1" if "value1" in x else "hash2"
        )

        class MyClass(metaclass=SingletonHash):
            def __init__(self, value):
                self.value = value

        # Act
        instance1 = MyClass("value1")
        instance2 = MyClass("value1")
        instance3 = MyClass("value2")

        # Assert
        self.assertIs(instance1, instance2)
        self.assertIsNot(instance1, instance3)
        self.assertIsNot(instance2, instance3)

    def test_singleton_hash_drop(self) -> None:
        # Arrange
        class MyClass(metaclass=SingletonHash):
            def __init__(self, value):
                self.value = value

        instance1 = MyClass("value1")

        # Act
        SingletonHash.drop()
        instance2 = MyClass("value1")

        # Assert
        self.assertIsNot(instance1, instance2)


if __name__ == "__main__":
    unittest.main()
