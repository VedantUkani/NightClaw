import json
import os
from agents import function_tool

MOCK_DATA_PATH = os.path.join(os.path.dirname(__file__), "..", "mock_data", "schedule.json")


@function_tool
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
