import json
import os


class Resource:
    def __init__(self) -> None:
        self._path = os.path.join(os.getcwd(), "src", "resources")

    def load_json(self, path: str) -> dict:
        absolute_path = os.path.join(self._path, path)
        if not os.path.isfile(absolute_path):
            raise FileNotFoundError(
                f"The file {absolute_path} does not exist."
            )

        with open(absolute_path, "r") as file:
            try:
                return json.load(file)
            except json.JSONDecodeError as e:
                raise ValueError(
                    f"Error decoding JSON from file {absolute_path}: {e}"
                )
