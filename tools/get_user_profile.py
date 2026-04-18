import json
import os
from agents import function_tool

MOCK_DATA_PATH = os.path.join(os.path.dirname(__file__), "..", "mock_data", "user_profile.json")


@function_tool
def get_user_profile() -> dict:
    """
    Retrieve the current user's profile including personal details, baseline
    health metrics, shift pattern, and known medical conditions.

    In production this would call the HR / wearable API.
    For the demo it reads from mock_data/user_profile.json.
    """
    with open(MOCK_DATA_PATH, "r") as f:
        return json.load(f)
