"""feat: add unique constraint to todo title

Revision ID: 16dc811cfcc8
Revises: cae9ba6a1c1e
Create Date: 2024-08-04 16:48:56.397332

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '16dc811cfcc8'
down_revision: Union[str, None] = 'cae9ba6a1c1e'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_index('ix_todos_title', table_name='todos')
    op.create_index(op.f('ix_todos_title'), 'todos', ['title'], unique=True)
    # ### end Alembic commands ###


def downgrade() -> None:
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_index(op.f('ix_todos_title'), table_name='todos')
    op.create_index('ix_todos_title', 'todos', ['title'], unique=False)
    # ### end Alembic commands ###
