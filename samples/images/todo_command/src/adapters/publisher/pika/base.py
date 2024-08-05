import json
import logging
from typing import Optional

import pika

from src.adapters.exceptions import PublisherChannelNotFound
from src.config import get_config
from src.ports.publisher import PublisherPort

logging.getLogger("pika").setLevel(logging.CRITICAL)

config = get_config()
logger = logging.getLogger()


class PikaAdapter(PublisherPort):
    def __init__(self, queue: str, exchange: str = ""):
        self._connection = None
        self._channel = None
        self._queue = queue
        self._exchange = exchange

    def _get_broker_url(self):
        user = config.get_parameter("RABBITMQ_DEFAULT_USER")
        password = config.get_parameter("RABBITMQ_DEFAULT_PASS")
        host = config.get_parameter("RABBITMQ_HOST")
        port = config.get_parameter("RABBITMQ_DEFAULT_PORT")
        return f"amqp://{user}:{password}@{host}:{port}"

    def _connect(self):
        if not self._connection or self._connection.is_closed:
            logger.info("Connecting to RabbitMQ...")
            self._connection = pika.BlockingConnection(
                pika.URLParameters(self.broker_url)
            )
            self._channel = self._connection.channel()
            logger.info("Connected to RabbitMQ")

    def publish(
        self, event_type: str, body: dict, headers: Optional[dict] = None
    ):
        if not self._channel:
            raise PublisherChannelNotFound(
                {
                    "code": "pika.error.publish",
                    "message": "Channel not found",
                }
            )
        try:
            self._connect()
            self._channel.queue_declare(queue=self._queue, durable=True)
            message = {"event_type": event_type, "body": body}
            self._channel.basic_publish(
                exchange=self._exchange,
                routing_key=self._queue,
                body=json.dumps(message),
                properties=pika.BasicProperties(headers=headers),
            )
            logger.info(f"Message published to queue {self._queue}")
        except Exception as error:
            logger.error(f"Failed to publish message: {error}")
        finally:
            if self._connection and not self._connection.is_closed:
                self._connection.close()
                logger.info("Connection to RabbitMQ closed")

    @property
    def broker_url(self):
        return self._get_broker_url()
