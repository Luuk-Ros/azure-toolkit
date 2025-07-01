# azure-toolkit

**A comprehensive toolkit for Azure administrators and developers, featuring automation scripts and KQL query examples.**

---

## Table of Contents

* [Description](#description)
* [Getting Started](#getting-started)
* [Scripts](#scripts)
* [KQL Examples](#kql-examples)
* [Contributing](#contributing)
* [License](#license)

---

## Description

`azure-toolkit` is your go-to repository for reusable Azure automation scripts and Kusto Query Language (KQL) examples. Whether you’re managing resources via PowerShell or Azure CLI, or analyzing logs with Log Analytics, you’ll find ready-to-use tools here to speed up your workflows.

## Getting Started

1. **Clone the repository**:

   ```bash
   git clone https://github.com/your-username/azure-toolkit.git
   cd azure-toolkit
   ```
2. **Explore** the folders below to find scripts or KQL queries relevant to your task.
3. **Run** scripts directly or adapt them to fit your environment.

## Scripts

All automation scripts are organized by category. Each script includes usage instructions and parameter descriptions.

* `scripts/`

  * `provisioning/` — Create and configure Azure resources
  * `monitoring/` — Setup alerts and monitoring
  * `cleanup/` — Clean up unused resources
  * `misc/` — Utility scripts (e.g., cost reports, tagging)

## KQL Examples

A library of KQL queries for common scenarios in Azure Monitor and Log Analytics.

* `kql/`

  * `performance/` — CPU, memory, and disk metrics
  * `security/` — Sign-in and audit logs
  * `network/` — Network traffic and diagnostic logs
  * `cost/` — Usage and cost analysis

## Contributing

Contributions are welcome! To add a script or KQL example:

1. Fork the repository.
2. Create a new branch: `git checkout -b feature/your-feature-name`.
3. Add your script or query, with clear comments and examples.
4. Submit a pull request, describing what you’ve added or changed.

Please follow the existing structure and naming conventions.

## License

This project is licensed under the [MIT License](LICENSE).
