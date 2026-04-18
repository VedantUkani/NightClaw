import json
import os
from agents import function_tool

MOCK_DATA_PATH = os.path.join(os.path.dirname(__file__), "..", "mock_data", "vitals.json")


@function_tool
def get_vitals() -> dict:
    """
    Retrieve the user's latest health vitals including heart rate, HRV, blood
    pressure, SpO2, stress score, sleep quality, and a 24-hour trend.
    Also returns active health flags (e.g. elevated_resting_hr, sleep_deficit).

    In production this would call the wearable device / health API.
    For the demo it reads from mock_data/vitals.json.
    """
    with open(MOCK_DATA_PATH, "r") as f:
        return json.load(f)
