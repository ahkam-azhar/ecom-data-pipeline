from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine, text

engine = create_engine("postgresql+psycopg2://portfolio:portfolio@localhost:5432/ecom")


def load_raw(csv_dir: str) -> None:
    with engine.begin() as conn:
        conn.execute(text("CREATE SCHEMA IF NOT EXISTS raw"))

    csv_files = sorted(Path(csv_dir).glob("*.csv"))
    if not csv_files:
        print(f"No CSV files found in {csv_dir}. Check that the dataset is in the data folder.")
        return

    for csv in csv_files:
        table = csv.stem.removeprefix("olist_").removesuffix("_dataset")
        df = pd.read_csv(csv, dtype=str)  # keep everything as text, untouched
        df.to_sql(
            table,
            engine,
            schema="raw",
            if_exists="replace",
            index=False,
            chunksize=10_000,
            method="multi",
        )
        print(f"loaded raw.{table}: {len(df)} rows")


if __name__ == "__main__":
    load_raw("data/")