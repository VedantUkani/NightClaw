import json
import os

MOCK_DATA_PATH = os.path.join(os.path.dirname(__file__), "..", "mock_data", "schedule.json")


def get_schedule() -> dict:
    """
    Retrieve the user's work schedule for the current week including shift times,
    task-by-task breakdown, overtime hours, missed breaks, incidents, and a
    weekly summary (total hours worked, code blues, rapid responses, etc.).

    In production this would call the hospital scheduling system (e.g. Kronos).
    For the demo it reads from mock_data/schedule.json.
    """
    with open(MOCK_DATA_PATH, "r") as f:
        return json.load(f)


if __name__ == "__main__":
    print(json.dumps(get_schedule(), indent=2))
