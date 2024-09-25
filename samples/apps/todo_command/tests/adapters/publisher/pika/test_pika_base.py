import json
import unittest
from unittest.mock import MagicMock, PropertyMock, patch

import pika  # type: ignore

from src.adapters.exceptions import PublisherChannelNotFound
from src.adapters.publisher.pika.base import PikaAdapter


class TestPikaAdapter(unittest.TestCase):

    @patch("src.adapters.publisher.pika.base.get_config")
    def setUp(self, mock_get_config):
        # Mock configuration values
        self.mock_config = MagicMock()
        self.mock_config.get_parameter.side_effect = lambda key: {
            "RABBITMQ_DEFAULT_USER": "user",
            "RABBITMQ_DEFAULT_PASS": "pass",
            "RABBITMQ_HOST": "localhost",
            "RABBITMQ_DEFAULT_PORT": "5672",
        }[key]
        mock_get_config.return_value = self.mock_config

        # Initialize PikaAdapter with mock values
        self.adapter = PikaAdapter(queue="test_queue")

    @patch("pika.BlockingConnection")
    def test_connect_success(self, mock_blocking_connection):
        # Arrange
        mock_connection = MagicMock()
        mock_blocking_connection.return_value = mock_connection
        mock_channel = mock_connection.channel.return_value

        # Act
        self.adapter._connect()

        # Assert
        mock_blocking_connection.assert_called_once_with(
            pika.URLParameters(self.adapter.broker_url)
        )
        mock_connection.channel.assert_called_once()
        self.assertEqual(self.adapter._connection, mock_connection)
        self.assertEqual(self.adapter._channel, mock_channel)

    @patch("pika.BlockingConnection")
    def test_publish_success(self, mock_blocking_connection):
        # Arrange
        mock_connection = MagicMock()
        mock_blocking_connection.return_value = mock_connection
        mock_channel = mock_connection.channel.return_value
        self.adapter._connection = mock_connection
        self.adapter._channel = mock_channel

        # Ensure is_closed returns False
        mock_connection.is_closed = False

        event_type = "test_event"
        body = {"key": "value"}
        headers = {"header_key": "header_value"}

        # Act
        self.adapter.publish(event_type, body, headers)

        # Assert
        mock_channel.queue_declare.assert_called_once_with(
            queue="test_queue", durable=True
        )
        mock_channel.basic_publish.assert_called_once_with(
            exchange="",
            routing_key="test_queue",
            body=json.dumps({"event_type": event_type, "body": body}),
            properties=pika.BasicProperties(headers=headers),
        )
        mock_connection.close.assert_called_once()

    def test_publish_channel_not_found(self):
        # Arrange
        self.adapter._channel = None

        event_type = "test_event"
        body = {"key": "value"}

        # Act & Assert
        with self.assertRaises(PublisherChannelNotFound):
            self.adapter.publish(event_type, body)

    @patch("pika.BlockingConnection")
    def test_publish_error(self, mock_blocking_connection):
        # Arrange
        mock_connection = MagicMock()
        mock_blocking_connection.return_value = mock_connection
        mock_channel = mock_connection.channel.return_value
        mock_channel.basic_publish.side_effect = Exception("publish error")
        self.adapter._connection = mock_connection
        self.adapter._channel = mock_channel

        # Ensure is_closed returns False
        mock_connection.is_closed = False

        event_type = "test_event"
        body = {"key": "value"}
        headers = {"header_key": "header_value"}

        # Act
        self.adapter.publish(event_type, body, headers)

        # Assert
        mock_channel.queue_declare.assert_called_once_with(
            queue="test_queue", durable=True
        )
        mock_channel.basic_publish.assert_called_once_with(
            exchange="",
            routing_key="test_queue",
            body=json.dumps({"event_type": event_type, "body": body}),
            properties=pika.BasicProperties(headers=headers),
        )
        mock_connection.close.assert_called_once()

    @patch(
        "src.adapters.publisher.pika.base.PikaAdapter.broker_url",
        new_callable=PropertyMock,
    )
    def test_broker_url_property(self, mock_broker_url):
        # Arrange
        mock_broker_url.return_value = "amqp://user:pass@localhost:5672"

        # Act
        url = self.adapter.broker_url

        # Assert
        self.assertEqual(url, "amqp://user:pass@localhost:5672")


if __name__ == "__main__":
    unittest.main()
