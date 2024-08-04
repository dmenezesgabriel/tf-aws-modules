import json
import logging

import pika

from src.config import get_config

logging.getLogger("pika").setLevel(logging.CRITICAL)

config = get_config()
logger = logging.getLogger()


class PikaAdapter:
    def __init__(self):
        self._connection = None
        self._channel = None

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
        self, queue: str, event_type: str, data: dict, exchange: str = ""
    ):
        try:
            self._connect()
            self._channel.queue_declare(queue=queue, durable=True)
            message = {"event_type": event_type, "data": data}
            self._channel.basic_publish(
                exchange=exchange,
                routing_key=queue,
                body=json.dumps(message),
            )
            logger.info(f"Message published to queue {queue}")
        except Exception as error:
            logger.error(f"Failed to publish message: {error}")
        finally:
            if self._connection and not self._connection.is_closed:
                self._connection.close()
                logger.info("Connection to RabbitMQ closed")

    @property
    def broker_url(self):
        return self._get_broker_url()
