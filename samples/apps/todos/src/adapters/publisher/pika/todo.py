import logging

from src.adapters.publisher.pika.base import PikaAdapter
from src.config import get_config

config = get_config()
logger = logging.getLogger()


class PikaTodoAdapter(PikaAdapter):
    def __init__(self):
        super().__init__(queue=config.get_parameter("TODO_QUEUE"))
