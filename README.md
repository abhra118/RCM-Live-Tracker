# Automated Healthcare RCM Live Tracker

An end-to-end Healthcare Revenue Cycle Management (RCM) analytics project built with MySQL, Python automation, Windows Task Scheduler, and Power BI.

## Project Overview

This project simulates a real healthcare RCM operations environment where claim and agent performance data updates automatically every hour.

## Dashboard Pages

### 1. Live Agent Performance Tracker

- Claims processed in the latest hour
- Target achievement and average accuracy
- Agents below target
- Agent scorecard and priority action list

### 2. RCM Live Tracker

- Total claims and collections
- Denial rate
- High-priority claims
- Live claim-status breakdown
- Priority claim action list

## Automation Pipeline

```text
Windows Task Scheduler (every hour)
        ↓
Python pipeline generates new RCM activity
        ↓
MySQL database is updated
        ↓
Power BI dashboards refresh with current KPIs
