# Security Queries

This directory contains KQL queries for auditing authentication and sign-in activity in your Azure environment. Use these queries to:

- Count unique sign-ins per device  
- List and filter sign-in events  
- Analyze failed and MFA-related sign-in attempts  

## Files

- **windows-signins-30d.kql** - List sign-in events on Windows devices in the last 30 days.  
- **filtered-signins-30d.kql** - List sign-ins in the last 30 days, excluding certain device name patterns.  
- **failed-signins-24h.kql** - Visualize failed sign-in attempts over the past 24 hours.  
- **mfa-fails-7d.kql** - Show users with MFA failure events in the last 7 days.