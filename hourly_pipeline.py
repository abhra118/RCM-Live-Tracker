"""Simulated hourly RCM source feed for the portfolio project.

In production, replace generate_claim_updates() with a read-only query or API
call to the company's RCM/billing system. The downstream MySQL loading pattern
remains the same.
"""
from __future__ import annotations

import os
import random
from datetime import datetime, timedelta

import mysql.connector
from dotenv import load_dotenv

load_dotenv()

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", "3306")),
    "database": os.getenv("DB_NAME", "rcm_live_tracker"),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD"),
}

PAYERS = ["Apex Health", "Blue Horizon", "CareFirst", "MediSure", "United Care"]
PROVIDERS = ["Dr. Ananya Roy", "Dr. R. Sen", "Dr. Vivek Shah", "Dr. K. Iyer", "Dr. M. Das"]
DEPARTMENTS = ["Cardiology", "Orthopedics", "Radiology", "Emergency", "General Medicine"]
PROCEDURES = ["Office Visit", "MRI Scan", "X-Ray", "Echocardiogram", "Physical Therapy"]
DENIAL_REASONS = ["Eligibility", "Authorization", "Coding", "Timely Filing", "Duplicate Claim"]


def ar_bucket(days: int) -> str:
    if days <= 30:
        return "0-30"
    if days <= 60:
        return "31-60"
    if days <= 90:
        return "61-90"
    return "90+"


def next_refresh_hour(cursor) -> datetime:
    cursor.execute("SELECT MAX(refresh_hour) FROM agent_hourly")
    latest = cursor.fetchone()[0]
    if latest is None:
        return datetime.now().replace(minute=0, second=0, microsecond=0)
    return latest + timedelta(hours=1)


def next_claim_number(cursor) -> int:
    cursor.execute("SELECT COALESCE(MAX(CAST(SUBSTRING(claim_id, 4) AS UNSIGNED)), 0) FROM claim_fact")
    return int(cursor.fetchone()[0]) + 1


def load_agents(cursor):
    cursor.execute("""
        SELECT agent_id, agent_name, team, hourly_target, baseline_accuracy
        FROM agent_dim
        WHERE active_flag = 'Yes'
    """)
    return cursor.fetchall()


def generate_agent_activity(agents, refresh_hour: datetime):
    rows = []
    for agent_id, name, team, target, baseline_accuracy in agents:
        logged_in = round(random.uniform(0.80, 1.00), 2)
        processed = max(8, round(target * random.uniform(0.78, 1.18)))
        denied = round(processed * random.uniform(0.08, 0.16))
        paid = round(processed * random.uniform(0.45, 0.65))
        pending = max(0, processed - paid - denied)
        errors = max(0, round(processed * (1 - float(baseline_accuracy)) * random.uniform(0.5, 1.3)))
        accuracy = round(1 - errors / processed, 4)
        activity_id = f"ACT{refresh_hour:%y%m%d%H}{agent_id[-2:]}"
        rows.append((
            activity_id, refresh_hour, agent_id, name, team, logged_in,
            processed + random.randint(0, 8), processed, paid, denied, pending,
            errors, accuracy, round(processed / logged_in, 2), target,
            round(processed / target, 4), round(paid * random.uniform(900, 2600), 2),
            random.randint(3, 28), round(random.uniform(0.92, 1.00), 4),
        ))
    return rows


def generate_claim_updates(agents, refresh_hour: datetime, start_number: int):
    rows = []
    for claim_number in range(start_number, start_number + random.randint(22, 38)):
        agent_id, agent_name, team, *_ = random.choice(agents)
        status = random.choices(["Paid", "Denied", "Pending", "In Process"], weights=[56, 15, 17, 12])[0]
        billed = round(random.uniform(650, 8350), 2)
        paid = round(billed * random.uniform(0.72, 0.98), 2) if status == "Paid" else 0
        outstanding = round(billed - paid, 2)
        days_in_ar = 0 if status == "Paid" else random.randint(4, 145)
        priority = "High" if ((status == "Denied" and billed >= 6000) or (days_in_ar > 90 and outstanding >= 5000)) else "Medium" if (days_in_ar > 60 or billed >= 6500) else "Normal"
        processed_at = None if status == "In Process" else refresh_hour + timedelta(minutes=random.randint(5, 55))
        service_date = (refresh_hour - timedelta(days=random.randint(0, 100))).date()
        rows.append((
            f"CLM{claim_number:06d}", refresh_hour, service_date, processed_at,
            agent_id, agent_name, team, random.choice(PROVIDERS), random.choice(PAYERS),
            random.choice(DEPARTMENTS), random.choice(PROCEDURES), status,
            random.choice(DENIAL_REASONS) if status == "Denied" else "",
            billed, paid, outstanding, days_in_ar,
            "Paid" if status == "Paid" else ar_bucket(days_in_ar),
            "Yes" if status == "Denied" and random.random() < 0.42 else "No",
            priority, refresh_hour,
        ))
    return rows


def run_pipeline() -> None:
    if not DB_CONFIG["password"] or DB_CONFIG["password"].startswith("replace_"):
        raise ValueError("Set DB_PASSWORD in your .env file before running the pipeline.")

    connection = mysql.connector.connect(**DB_CONFIG)
    cursor = connection.cursor()
    try:
        refresh_hour = next_refresh_hour(cursor)
        agents = load_agents(cursor)
        if not agents:
            raise RuntimeError("No active agents found in agent_dim.")
        agent_rows = generate_agent_activity(agents, refresh_hour)
        claim_rows = generate_claim_updates(agents, refresh_hour, next_claim_number(cursor))

        cursor.executemany("""
            INSERT INTO agent_hourly (
                activity_id, refresh_hour, agent_id, agent_name, team, logged_in_hours,
                claims_assigned, claims_processed, claims_paid, claims_denied, claims_pending,
                error_count, accuracy_rate, claims_per_hour, hourly_target,
                target_achievement_pct, collection_amount_inr, pending_workload, adherence_pct
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, agent_rows)
        cursor.executemany("""
            INSERT INTO claim_fact (
                claim_id, claim_created_at, service_date, processed_at, agent_id, agent_name,
                team, provider, payer, department, procedure_name, claim_status, denial_reason,
                billed_amount_inr, paid_amount_inr, outstanding_amount_inr, days_in_ar, ar_bucket,
                error_flag, priority_flag, last_updated_at
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, claim_rows)
        refresh_id = f"REF{refresh_hour:%Y%m%d%H}"
        cursor.execute("""
            INSERT INTO refresh_log (
                refresh_id, refresh_timestamp, rows_added_claims,
                rows_added_agent_activity, refresh_status, data_source, notes
            ) VALUES (%s, %s, %s, %s, 'Completed', 'Simulated RCM source feed', 'Hourly scheduled update')
        """, (refresh_id, refresh_hour, len(claim_rows), len(agent_rows)))
        connection.commit()
        print(f"SUCCESS | {refresh_hour:%Y-%m-%d %H:%M} | claims added: {len(claim_rows)} | agent activity rows: {len(agent_rows)}")
    except Exception:
        connection.rollback()
        raise
    finally:
        cursor.close()
        connection.close()


if __name__ == "__main__":
    run_pipeline()
