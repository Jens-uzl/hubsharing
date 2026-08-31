# Belgian Federated Interhub FHIR Document Sharing Implementation Guide

A comprehensive FHIR Release 4 Implementation Guide (IG) defining the normative migration proposal from legacy Belgian **KMEHR SOAP Web Services** (`getTransactionList`, `getTransaction`) to **IHE MHD (Mobile access to Health Documents)** RESTful document sharing, aligned with the **European Health Data Space (EHDS)**.

## Core Architectural Scope

* **Strict Hub-to-Hub Interhub Boundary**: This Implementation Guide normatively and exclusively specifies **Interhub** communication (federated Hub-to-Hub exchange between Belgian eHealth Hubs and cross-border gateways). Clinical applications (EHRs, LIS, patient portals, telemonitoring apps) connect to their designated local Hub via **Intrahub endpoints** using Intrahub protocols (such as KMEHR or internal standards), which remain **out of scope**.
* **Document-Centric Model**: All shared clinical payloads are strictly exchanged as **FHIR Bundles of type `document` (`Bundle.type = #document`)**, containing a root `Composition` and self-contained referenced clinical resources.
* **Metadata Discovery**: Document discovery across Belgian Hubs (CoZo, RSW, BHN, Zodap) is governed by the `BeInterhubDocumentReference` profile (deriving from `IHE.MHD.Comprehensive.DocumentReference` with contained resources), carrying national identifiers (SSIN/INSS, NIHDI, CBE), Belgian patient access rules (`PatientAccess`), Home Community IDs, and cryptographic hashes.
* **Core Transactions**:
  * **`getTransactionList` ↔ MHD ITI-67 (`Find DocumentReferences`)**: Initiating hub searches for document metadata summaries by patient SSIN, CD-TRANSACTION category, date range, and author across partner hubs.
  * **`getTransaction` ↔ MHD ITI-68 (`Retrieve Document`) & `$document`**: Initiating hub retrieves the full, immutable FHIR Document Bundle from the authoritative responding hub.
* **Priority Clinical Domains**:
  * **Laboratory Reports (`labresult`)**: Compliant with HL7 Belgium `BeLaboratoryReport` and EHDS `Composition-eu-lab`.
  * **Telemonitoring (`telemonitoring`)**: Remote patient monitoring sessions, Holter studies, carepaths, and telemonitoring diagnostic reports.

---

## Prerequisites & Build

### Using SUSHI
Compile FHIR Shorthand (FSH) artifacts:

```bash
sushi .
```

### Full IG Publisher Build
Run the build script:

```bash
# On Linux / devcontainer:
bash _build.sh

# On Windows:
_build.bat
```

---

## Key FHIR Artifacts

| Artifact | Type | Description                                                                                                    |
| :--- | :--- |:---------------------------------------------------------------------------------------------------------------|
| **`BeInterhubDocumentReference`** | Profile | Metadata discovery carrier for `getTransactionList` (MHD ITI-67) conforming to IHE MHD Comprehensive Contained |
| **`BeInterhubDocumentBundle`** | Profile | Canonical FHIR Document Bundle (`type = #document`) for `getTransaction` (MHD ITI-68)                          |
| **`BeInterhubLabComposition`** | Profile | Root Composition for Laboratory Report documents (LOINC 11502-2)                                               |
| **`BeTelemonitoringComposition`** | Profile | Root Composition for Telemonitoring documents (LOINC ...)                                                      |
| **`TelemonitoringDiagnosticReport`** | Profile | Telemonitoring diagnostic report with carepath and session extensions                                          |
| **`BeExtPatientAccess`** | Extension | Belgian patient portal visibility rules (`yes`, `no`, `never`, delay dates)                                    |
| **`BeExtHomeCommunityId`** | Extension | Regional Hub Home Community ID (`urn:oid:1.3.6.1.4.1.21297.1.X`)                                               |
| **`BeExtEndToEndEncryption`** | Extension | Belgian eHealth ETK depot encryption metadata                                                                  |
| **`BeExtRecordDateTime`** | Extension | Timestamp when recorded in the hub source system                                                               |
| **`BeInterhubDocumentResponder`** | CapabilityStatement | Server requirements for responding eHealth Hubs and Repositories                                               |
| **`BeInterhubDocumentConsumer`** | CapabilityStatement | Client requirements for initiating eHealth Hubs in Interhub federated communication                            |
