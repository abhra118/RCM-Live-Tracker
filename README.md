# Hourly RCM Pipeline

This local script simulates an hourly RCM source feed and loads new claims and agent activity into MySQL.

## Setup

1. Install packages: `python -m pip install -r requirements.txt`
2. Copy `.env.example` to `.env` and enter the MySQL root password.
3. Test the pipeline: `python hourly_pipeline.py`

The script adds 22–38 claims, seven agent activity rows, and one refresh-log row per run. It uses the next hour after the latest `agent_hourly.refresh_hour` record so the Power BI dashboard’s refresh timestamp advances each run.

## Production replacement

Replace `generate_claim_updates()` and `generate_agent_activity()` with a read-only source-system query or API request. The MySQL load and refresh-log steps remain unchanged.
