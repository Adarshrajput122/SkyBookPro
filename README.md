# SkyBook Pro – Airline Booking Management System

SkyBook Pro is a comprehensive Tour Planning and Airline Ticket Booking Management System built entirely on the Salesforce platform. The application interfaces with the live Amadeus Flight Offers Search & Booking API to deliver real-time flight inventory management, automated traveler dashboard components, and customer flight reservation structures.

## 🛠️ Project Technical Architecture
*   **Presentation Layer:** 12 native Lightning Web Components (LWC) styled with SLDS utility classes.
*   **Controller Layer:** Cacheable and imperative `@AuraEnabled` Apex methods.
*   **Service Layer:** Modular Apex engine (`BookingService`, `AmadeusAuthService`, `AmadeusFlightSearchService`).
*   **Integration Layer:** Amadeus REST API processing authenticated via Named Credentials.
*   **Automation Engine:** 4 Record-Triggered/Scheduled Flows, 1 Validation Rule suite, and a Group Booking Approval Process.

## 📂 Salesforce DX Package Directory Structure
Ensure your `force-app/main/default/` contains the following custom modules required by the Business Requirements Document (BRD):

```text
force-app/main/default/
├── classes/
│   ├── AmadeusAuthService.cls            # Handles OAuth2 Bearer token generation and caching
│   ├── AmadeusFlightSearchService.cls    # Calls /v2/shopping/flight-offers API endpoint
│   ├── FlightOfferWrapper.cls            # @AuraEnabled OOP Data Wrapper for LWC data binding
│   ├── BookingService.cls                # Handles DML transactional logic for booking insertions
│   ├── BookingTriggerHandler.cls         # Handles validation and automation for the Booking lifecycle
│   ├── BookingArchiveBatch.cls           # Asynchronous Batch Apex for data management
│   └── TestDataFactory.cls               # Centralized test data provisioning isolation class
├── lwc/
│   ├── flightSearchForm/                 # Input terminal matching origin, destination, and dates
│   ├── flightResultsList/                # Renders collections using template iterations
│   ├── passengerDetailsForm/             # Dynamic multi-passenger dynamic form structure
│   ├── bookingConfirmation/              # Order checkout checkpoint executing imperative Apex calls
│   └── myBookingsDashboard/              # @wire adapter datatable rendering passenger flights
├── objects/
│   ├── Flight__c/                        # Stores Amadeus flight record details
│   ├── Booking__c/                       # Transaction head record mapping travelers to flights
│   ├── Passenger_Detail__c/              # Master-Detail child storing passenger metadata
│   ├── Flight_Segment__c/                # Master-Detail leg tracker for connected flight paths
│   └── Refund__c/                        # Tracks refund values, requests, and processing statuses
└── messageChannels/
    └── SkyBook_Channel__c.messageChannel-meta.xml  # Shared LMS channel for component communication
```

## 🚀 Key CLI Deployment Commands
To deploy your data model, triggers, and components into your target scratch org or Developer sandbox, run these commands:

1. **Deploy your structural metadata:**
   ```bash
   sf project deploy start
   ```
2. **Execute your local Apex testing suite:**
   ```bash
   sf apex run test --detailed-logging --result-format human
   ```

# Salesforce DX Project

Salesforce DX is a development approach that brings source-driven development, team collaboration, and continuous integration to the Salesforce Platform. Instead of working directly in an org through a web browser, you work with metadata as source files in a local DX project, track changes in version control, and deploy through automated processes.

This project template gets you started with the tools and structure you need to build Salesforce applications using source control, scratch orgs, and the Salesforce CLI.

## Prerequisites

Before you start, make sure you have:

- **Salesforce CLI** - Download from [developer.salesforce.com/tools/salesforcecli](https://developer.salesforce.com/tools/salesforcecli). See [Install Salesforce CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm) for details.
- **VS Code with Salesforce Extension Pack** - See [Installation Instructions](https://developer.salesforce.com/docs/platform/sfvscode-extensions/guide/install.html) for details. Includes the Agentforce Vibes extension.
- **A development org** - Sign up for a free Developer Edition org [here](https://developer.salesforce.com/signup).
- **Dev Hub enabled** (optional, required to create scratch orgs) - You can enable Dev Hub in your development org under Setup > Dev Hub.  See [Provide Developers Access to Salesforce DX Tools](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_setup_dx_tools.htm).

## Project Structure

Your DX project follows this structure:

- **`force-app/main/default/`** - Your metadata source files live in this default package directory. You can configure additional package directories in the `sfdx-project.json` file.
- **`config/`** - Scratch org definitions and project settings
- **`scripts/`** - Automation scripts for common tasks
- **`sfdx-project.json`** - Project manifest that defines package directories, namespace, API version, and other project-level settings

See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm).

## Get Started

Ready to start developing? The [Get Started with Salesforce DX](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_get_started_dx.htm) guide walks you through your first project, from creating a scratch org to creating a simple Apex class or LWC to deploying your code to a sandbox.

## Common Salesforce CLI Commands

Here are common CLI commands that you'll use the most:

- `sf org login web`: Authorize an org
- `sf org open`: Open your org in a browser
- `sf org create scratch`: Create a scratch org
- `sf project deploy start`: Deploy metadata to your org
- `sf project retrieve start`: Retrieve metadata from your org
- `sf template generate <artifact>`: Scaffold new components, such as Apex classes and triggers, LWC components, Lightning apps, and more
- `sf apex <command>`: Run Apex tests, run anonymous Apex blocks, and view logs
- `sf data <command>`: Work with test data
- `sf alias <command>`: Manage org aliases
- `sf config <command>`: Configure CLI settings

## Use Agentforce Vibes to Build Lightning Apps

Transform your ideas into custom Lightning apps that extend CRM workflows directly in Lightning Experience. Through natural conversations with Agentforce Vibes, implement custom objects and fields, complex business logic, and dynamic UI components. See [Build a Lightning App Using Agentforce Vibes](https://developer.salesforce.com/docs/platform/einstein-for-devs/guide/lexapp-overview.html).

## Additional Resources

- [Agentforce Vibes Developer Guide](https://developer.salesforce.com/docs/platform/einstein-for-devs/guide/einstein-overview.html)
- [Salesforce CLI Installation Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/)
- [Salesforce CLI Plugin Development Guide](https://developer.salesforce.com/docs/platform/salesforce-cli-plugin/guide/conceptual-overview.html)
- [Salesforce VS Code Extensions Documentation](https://developer.salesforce.com/tools/vscode/)

