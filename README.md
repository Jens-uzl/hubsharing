# Belgian Federated Interhub FHIR Document Sharing Implementation Guide

> **Normative Source of Truth** for the migration proposal from legacy Belgian KMEHR SOAP Web Services (`getTransactionList`, `getTransaction`) to **IHE MHD (Mobile access to Health Documents) on HL7® FHIR® R4**, aligned with the **European Health Data Space (EHDS)**.

[![FHIR R4](https://img.shields.io/badge/FHIR-R4%20(v4.0.1)-orange.svg)](http://hl7.org/fhir/R4/)
[![IHE MHD](https://img.shields.io/badge/IHE%20MHD-v4.2.2-blue.svg)](https://profiles.ihe.net/ITI/MHD/)
[![SUSHI](https://img.shields.io/badge/SUSHI-v3.20.1-blueviolet.svg)](https://fshschool.org/sushi/)

---

## 1. Role in the Interhub Ecosystem

This Implementation Guide (IG) is the **normative source of truth** for the Belgian Federated Interhub FHIR document-sharing proposal. It defines all profile structures, extensions, terminologies, operations, and search parameters.

The generated FHIR artifacts and sample resources from this IG directly seed the other two components in this workspace:
- **`../fhir-ehealth-hub-simulator/`**: Reference Java / Spring Boot / HAPI FHIR server implementing the responder specifications. Sample resources from `fsh-generated/resources/` are hosted in its `data/` directory.
- **`../fhir-ehealthhub-simulator-viewer/`**: Modern web workspace and developer console. Bundles a copy of the generated resources in `public/fixtures/` and the narrative chapters/FSH in `public/ig/`.

---

## 2. Core Architectural Principles

1. **Strict Interhub Boundary**: Normatively and exclusively specifies federated **Hub-to-Hub** exchange between Belgian eHealth Hubs (CoZo, RSW, Abrumet+, Zodap) and cross-border gateways. Intrahub connections between clinical EHR/LIS systems and their local Hub remain out of scope.
2. **Document-Centric Structure**: All shared clinical payloads are strictly exchanged as FHIR Bundles of type `document` (`Bundle.type = #document`), rooted in a `Composition` with all referenced resources included directly within the bundle.
3. **No Cross-Hub Dereferencing (No N+1 Queries)**: All authoring parties, custodians, and patient demographic snapshots are provided as **contained resources** (`DocumentReference.contained`). Cross-document relationships (`relatesTo.target`) use **logical references** by business identifier, eliminating cross-hub cascading queries.
4. **Open Coding Slices on `system`**: Document category and type elements mandate the national `cd-transaction` code system, but open slicing allows local hospital codings and multilingual descriptions to travel without being stripped by relaying hubs.
5. **The Two Core Transactions**:
   - **`getTransactionList` ↔ MHD ITI-67 (`Find DocumentReferences`)**: Query metadata summaries by patient SSIN, category, LOINC type, date range, and author. POST is mandated to prevent SSIN logging.
   - **`getTransaction` ↔ MHD ITI-68 (`Retrieve Document`) & `$retrieve-document`**: Resolves a document reference to an immutable FHIR Document Bundle or raw PDF stream via content negotiation (`Accept: application/pdf`).

---

## 3. Key FHIR Artifacts

### Profiles

| Profile Name | Base Resource | Description |
| :--- | :--- | :--- |
| **`BeInterhubDocumentReference`** | `IHE.MHD.Comprehensive.DocumentReference` | Discovery envelope for ITI-67 (`getTransactionList`) with contained authors, custodian, patient snapshot, and national extensions. |
| **`BeInterhubMinimalDocumentReference`** | `IHE.MHD.Minimal.DocumentReference` | Lightweight discovery envelope making contained entities and extended metadata optional. |
| **`BeInterhubDocumentBundle`** | `Bundle` (`type = #document`) | Retrieval envelope for ITI-68 (`getTransaction`), containing root Composition and clinical entries. |
| **`BeInterhubLabComposition`** | `Composition` | Root composition profile for Belgian laboratory reports (LOINC `11502-2`), aligned with HL7 Belgium `BeLaboratoryReport` and EHDS `Composition-eu-lab`. |
| **`BeTelemonitoringComposition`** | `Composition` | Root composition profile for remote patient telemonitoring sessions and Holter studies. |
| **`TelemonitoringDiagnosticReport`** | `DiagnosticReport` | Diagnostic report profile carrying telemonitoring session and carepath metadata. |

### Belgian Extensions (`input/fsh/be-interhub-extensions.fsh`)

| Extension Name | URL / Identifier | Purpose |
| :--- | :--- | :--- |
| **`BeExtHomeCommunityId`** | `.../StructureDefinition/be-ext-home-community-id` | Mandatory Regional Hub Home Community ID (`urn:oid:1.3.6.1.4.1.21297.1.X`) for federated routing. |
| **`BeExtPatientAccess`** | `.../StructureDefinition/be-ext-patient-access` | Enforces Belgian patient portal visibility (`yes`, `no`, `never`, delay dates). |
| **`BeExtEndToEndEncryption`** | `.../StructureDefinition/be-ext-end-to-end-encryption` | Metadata for eHealth ETK depot encryption. |
| **`BeExtRecordDateTime`** | `.../StructureDefinition/be-ext-record-date-time` | Timestamp when recorded in the hub source system. |
| **`BeExtHcPartyType`** | `.../StructureDefinition/be-ext-hcparty-type` | Carries KMEHR `CD-HCPARTY` code inline on author, authenticator, and custodian. |

### CapabilityStatements & Operations

| Artifact Name | Type | Description |
| :--- | :--- | :--- |
| **`BeInterhubDocumentResponder`** | `CapabilityStatement` | Normative server requirements for responding eHealth Hubs and repositories. |
| **`BeInterhubDocumentConsumer`** | `CapabilityStatement` | Client requirements for initiating eHealth Hubs in federated communication. |
| **`BeRetrieveDocument`** | `OperationDefinition` | Belgian `$retrieve-document` extended operation definition for ITI-68 document retrieval. |

---

## 4. Building the Implementation Guide

### Fast FSH Compilation (SUSHI)
Run after editing any `.fsh` file in `input/fsh/`:

```bash
sushi .
```
Outputs compiled FHIR resources to `fsh-generated/resources/`.

### Full HL7 IG Publisher Build
Requires Java 17+ and Jekyll:

```bash
# Full build with terminology validation
./_build.sh build

# Offline / Fast build (skips remote terminology server check)
./_build.sh notx

# Build without re-running SUSHI
./_build.sh nosushi

# Download / update publisher.jar tooling
./_build.sh update
```

### Local Preview Server
To preview the published HTML guide locally:

```bash
./_serve.sh
# or: node serve.js
```
Serves the published IG on `http://localhost:8080`.

---

## 5. Design History & Open Items

See **[`TODO.md`](TODO.md)** for a live architectural log of resolved design decisions (Mermaid v11 syntax constraints, M2M OAuth2/IAM security model, open coding slices, logical references to prevent N+1 queries) and current open items.
