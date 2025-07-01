# Network Queries

This directory contains KQL queries focused on network-related logs in your Azure environment. Use these queries to investigate DNS proxy requests, NSG flow data, and blocked traffic trends.

## Files

- **firewall-dns-proxy.kql** - Extract and list Azure Firewall DNS Proxy requests.
- **vpn-ike-diagnostics.kql** - Parses IKE diagnostic logs to extract VPN session events with remote/local IPs and timestamps.