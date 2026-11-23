import pytest
from sqlalchemy import create_engine, text


@pytest.fixture(scope="session")
def scalar():
    """Run a SQL query and return the single value it produces."""
    engine = create_engine("postgresql+psycopg2://portfolio:portfolio@localhost:5432/ecom")

    def run(sql: str):
        with engine.connect() as conn:
            return conn.execute(text(sql)).scalar()

    return run
