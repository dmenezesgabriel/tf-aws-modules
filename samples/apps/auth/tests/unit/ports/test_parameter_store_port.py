# mypy: ignore-errors
from typing import Dict, Optional
from unittest.mock import MagicMock

import pytest

from src.ports.parameter_store_port import ParameterStorePort


class TestParameterStorePortAbstraction:
    def test_cannot_instantiate_abstract_class(self) -> None:
        # Arrange & Act & Assert
        with pytest.raises(TypeError):
            ParameterStorePort()  # type: ignore[abstract]

    def test_cannot_instantiate_incomplete_implementation(self) -> None:
        # Arrange
        class IncompleteParameterStore(ParameterStorePort):
            pass

        # Act & Assert
        with pytest.raises(TypeError):
            IncompleteParameterStore()  # type: ignore[abstract]


class TestParameterStorePortImplementation:
    @pytest.fixture
    def concrete_store(self) -> ParameterStorePort:
        class ConcreteParameterStore(ParameterStorePort):
            def get_parameter(self, key: str) -> Optional[str]:
                return f"Value for {key}"

        return ConcreteParameterStore()

    def test_concrete_implementation(
        self, concrete_store: ParameterStorePort
    ) -> None:
        # Act
        result = concrete_store.get_parameter("test_key")

        # Assert
        assert isinstance(concrete_store, ParameterStorePort)
        assert result == "Value for test_key"

    @pytest.fixture
    def test_store(self) -> ParameterStorePort:
        class TestParameterStore(ParameterStorePort):
            def __init__(self) -> None:
                self.test_data: Dict[str, str] = {
                    "existing_key": "existing_value",
                    "another_key": "another_value",
                }

            def get_parameter(self, key: str) -> Optional[str]:
                return self.test_data.get(key)

        return TestParameterStore()

    @pytest.mark.parametrize(
        "key, expected_value",
        [
            ("existing_key", "existing_value"),
            ("another_key", "another_value"),
            ("non_existing_key", None),
        ],
    )
    def test_get_parameter_implementation(
        self,
        test_store: ParameterStorePort,
        key: str,
        expected_value: Optional[str],
    ) -> None:
        # Act
        result = test_store.get_parameter(key)

        # Assert
        assert result == expected_value

    def test_get_parameter_called_with_correct_argument(self) -> None:
        # Arrange
        mock_get_parameter = MagicMock(return_value="mocked_value")

        class MockParameterStore(ParameterStorePort):
            get_parameter = mock_get_parameter

        store = MockParameterStore()
        test_key = "test_key"

        # Act
        result = store.get_parameter(test_key)

        # Assert
        mock_get_parameter.assert_called_once_with(test_key)
        assert result == "mocked_value"
