from typing import Optional
from uuid import UUID, uuid4


class Todo:
    def __init__(
        self,
        title: str,
        description: str,
        done: bool,
        id: Optional[UUID] = None,
    ) -> None:
        self._id = id or uuid4()
        self._title = title
        self._description = description
        self._done = done

    @property
    def title(self):
        return self._title

    @property
    def description(self):
        return self._description

    @property
    def done(self):
        return self._done

    @property
    def id(self):
        return self._id

    def to_dict(self):
        return {
            "id": self.id,
            "title": self.title,
            "description": self.description,
            "done": self.done,
        }
