# KQL Examples

This folder contains all Kusto Query Language (KQL) examples, organised by query domain. Each category includes individual `.kql` files that you can open and run directly in **Azure Data Explorer**, **Log Analytics**, or **Microsoft Sentinel**.

## Categories

### data

Queries for monitoring log ingestion volumes and event counts:

| Query | Description |
|---|---|
| `ingestion-daily.kql` | Daily ingestion volume over the last 30 days, rendered as a time chart. |
| `ingestion-by-type-month.kql` | Ingestion volume broken down by data type for the current month. |
| `diagnostics-1d.kql` | Diagnostic log ingestion for the last 24 hours. |
| `diagnostics-30d piechart.kql` | 30-day diagnostic log distribution as a pie chart. |
| `get-event-total-count.kql` | Total event count per table across the workspace. |
| `top-hosts-month.kql` | Top log-emitting hosts for the current month. |

### security

Queries focused on sign-in logs and security analysis:

| Query | Description |
|---|---|
| `failed-signins-24h.kql` | All failed sign-in attempts in the last 24 hours. |
| `filtered-signins-30d.kql` | Sign-ins filtered by device, location, or user over the last 30 days. |
| `mfa-fails-7d.kql` | MFA failure events grouped by user over the last 7 days. |
| `windows-signins-30d.kql` | Windows device sign-ins over the last 30 days, with OS and device details. |

### network

Network-centric queries for firewall, DNS, and VPN diagnostics:

| Query | Description |
|---|---|
| `firewall-dns-proxy.kql` | Azure Firewall DNS proxy log analysis — top queried domains and blocked requests. |
| `vpn-ike-diagnostics.kql` | VPN Gateway IKE diagnostic events for troubleshooting tunnel establishment. |

### cost

Cost analysis queries for spending visibility:

| Query | Description |
|---|---|
| `cost-per-rg.kql` | Total data ingestion cost broken down per resource group. |
| `daily-cost-trend.kql` | Daily cost trend over time, rendered as a time chart. |
