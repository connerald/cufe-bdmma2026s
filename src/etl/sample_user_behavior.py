"""Sample the first 1/8 of the Taobao behavior log into data/processed.

The script keeps the original row order and only exports the sampled behavior file.
Profile tables and joins are generated later in Spark SQL from the imported sample.
"""

from __future__ import annotations

import argparse
import csv
from pathlib import Path


DEFAULT_REPO_ROOT = Path(__file__).resolve().parents[2]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Create the 1/8 sample and profile summary.")
    parser.add_argument(
        "--input",
        type=Path,
        default=DEFAULT_REPO_ROOT / "data" / "raw" / "UserBehavior.csv",
        help="Path to the original UserBehavior.csv file.",
    )
    parser.add_argument(
        "--sample-output",
        type=Path,
        default=DEFAULT_REPO_ROOT / "data" / "processed" / "user_behavior_sample.csv",
        help="Path to the sampled behavior CSV.",
    )
    return parser.parse_args()


def count_valid_rows(input_path: Path) -> int:
    with input_path.open("r", newline="", encoding="utf-8") as handle:
        reader = csv.reader(handle)
        return sum(1 for row in reader if row and len(row) == 5)


def write_sample(input_path: Path, sample_output: Path) -> tuple[int, int]:
    total_rows = count_valid_rows(input_path)
    if total_rows == 0:
        raise ValueError(f"No valid rows found in {input_path}")

    sample_rows = max(1, total_rows // 8)
    sample_output.parent.mkdir(parents=True, exist_ok=True)

    with input_path.open("r", newline="", encoding="utf-8") as source, sample_output.open(
        "w", newline="", encoding="utf-8"
    ) as sample_file:
        reader = csv.reader(source)
        writer = csv.writer(sample_file)
        writer.writerow(["user_id", "item_id", "category_id", "behavior_type", "timestamp"])

        sampled = 0
        for row in reader:
            if not row or len(row) != 5:
                continue

            if sampled >= sample_rows:
                break

            user_id, item_id, category_id, behavior_type, timestamp_text = row
            writer.writerow([user_id, item_id, category_id, behavior_type, timestamp_text])

            sampled += 1

    return total_rows, sample_rows


def main() -> None:
    args = parse_args()
    total_rows, sample_rows = write_sample(args.input, args.sample_output)
    print(f"Total valid rows: {total_rows}")
    print(f"Sample rows written: {sample_rows}")
    print(f"Sample output: {args.sample_output}")


if __name__ == "__main__":
    main()