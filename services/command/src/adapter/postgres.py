import logging

from sqlalchemy import (
    URL,
    UUID,
    Boolean,
    Column,
    MetaData,
    String,
    Table,
    create_engine,
    insert,
    select,
    update,
)
from sqlalchemy.orm import sessionmaker
from src.config import get_config
from src.domain.entities.todo import Todo

config = get_config()
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class PostgresTodoAdapter:
    def __init__(self):
        self.__engine = create_engine(self.database_url)
        self._metadata = MetaData()
        self.__todo_table = Table(
            "todos",
            self.metadata,
            Column("id", UUID, primary_key=True, index=True),
            Column("title", String, index=True),
            Column("description", String),
            Column("done", Boolean),
        )

        self.__session = sessionmaker(autocommit=False, bind=self.__engine)

    @property
    def database_url(self):
        return URL.create(
            "postgresql",
            username=config.DATABASE_USER,
            password=config.DATABASE_PASSWORD,
            host=config.DATABASE_HOST,
            database=config.DATABASE_DB_NAME,
            port=config.DATABASE_PORT,
        )

    @property
    def metadata(self):
        return self._metadata

    def create_todo(self, todo: Todo) -> Todo:
        query = insert(self.__todo_table).values(
            id=todo.id,
            title=todo.title,
            description=todo.description,
            done=todo.done,
        )
        session = self.__session()
        try:
            session.begin()
            create_result = session.execute(query)
            session.commit()
            if not hasattr(create_result, "inserted_primary_key"):
                raise Exception("Todo has not been created")
            todo_id = create_result.inserted_primary_key[0]
            return self.get_todo_by_id(todo_id)
        except Exception as error:
            logger.error(error)
            session.rollback()
            raise

    def get_todo_by_id(self, id: str) -> Todo:
        query = select(self.__todo_table).where(self.__todo_table.c.id == id)
        session = self.__session()
        try:
            session.begin()
            result = session.execute(query).fetchone()
            if result is None:
                logger.error(f"Todo {id} not found")
            todo = Todo(
                id=result.id,
                title=result.title,
                description=result.description,
                done=result.done,
            )
            return todo
        except Exception as error:
            logger.error(error)
            raise

    def update_todo(self, todo: Todo) -> Todo:
        query = update(self.__todo_table).where(
            self.__todo_table.c.id == todo.id
        )

        update_values = {}
        if todo.title is not None:
            update_values["title"] = todo.title
        if todo.description is not None:
            update_values["description"] = todo.description
        if todo.done is not None:
            update_values["done"] = todo.done

        query = query.values(**update_values)

        session = self.__session()
        try:
            session.begin()
            session.execute(query)
            session.commit()
            return self.get_todo_by_id(id=todo.id)
        except Exception as error:
            logger.error(error)
            raise

    def delete_todo(self, id: str) -> bool:
        query = self.__todo_table.delete().where(self.__todo_table.c.id == id)
        session = self.__session()
        try:
            session.begin()
            session.execute(query)
            return True
        except Exception as error:
            logger.error(error)
            raise
