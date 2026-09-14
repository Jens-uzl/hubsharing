# AGENTS.md — Belgian Federated Interhub FHIR Document Sharing IG

Normative HL7® FHIR® R4 Implementation Guide (IG) migrating Belgian KMEHR SOAP services (`getTransactionList`, `getTransaction`) to IHE MHD (v4.2.2) and EHDS-aligned RESTful exchanges.

---

## 1. Scope & Ecosystem Boundaries

- **Interhub Only (In-Scope)**: Strictly and exclusively specifies federated **Hub-to-Hub** exchange between Belgian eHealth Hubs (CoZo, RSW, Abrumet+, Zodap) and EHDS cross-border gateways.
- **Intrahub Out-of-Scope**: Clinical apps, EHRs, LIS, and patient portals communicate with their local Hub via local/intrahub endpoints (KMEHR or internal protocols). Never introduce intrahub interactions into interhub profiles.
- **Downstream Consumers**: Compiled artifacts in `fsh-generated/resources/` directly seed:
  - `../fhir-ehealth-hub-simulator/`: Java / Spring Boot / HAPI FHIR server (copies to `data/`).
  - `../fhir-ehealthhub-simulator-viewer/`: Web console (copies to `public/fixtures/` and `public/ig/`).

---

## 2. Essential Commands

| Task | Command | Notes |
| :--- | :--- | :--- |
| **Fast FSH Compile** | `sushi .` | Compiles `input/fsh/*.fsh` to `fsh-generated/resources/`. Run after any FSH change. |
| **Full Build (Win)** | `.\deploy_site.ps1` or `.\_build.bat build` | Requires JDK 17+ and Ruby/Jekyll. Downloads `publisher.jar` to `input-cache/` if missing. |
| **Fast / Offline Build** | `.\_build.bat notx` or `./_build.sh notx` | Passes `-tx n/a` to skip remote terminology server checks (`tx.fhir.org`). |
| **Publisher without SUSHI** | `.\_build.bat nosushi` or `./_build.sh nosushi` | Runs publisher with `-no-sushi` if `sushi .` was already executed. |
| **Clean Build Artifacts** | `.\_build.bat clean` or `./_build.sh clean` | Wipes `temp/`, `output/`, `template/`, while preserving `publisher.jar`. |
| **Local Preview Server** | `node serve.js` | Serves `output/` at `http://localhost:8080/en/index.html`. Handles root 302 redirect. |
| **Alternative Preview** | `./_serve.sh` | Uses `npx http-server output/en -p 8080 -c-1 -o`. |

---

## 3. Critical FHIR & Architecture Rules

- **Document Bundles Only**: All clinical payloads are exchanged strictly as FHIR Bundles of type `document` (`Bundle.type = #document`), rooted in a `Composition` with all referenced resources included directly in the bundle.
- **Strict Endpoint Boundaries**: A responding hub serves only `DocumentReference` (POST search, `$retrieve-document`) and `Observation` (POST search). NEVER add endpoints for Patient, Practitioner, Organization, Specimen, or ServiceRequest, and never add operations that duplicate a search.
- **Logical References Instead of Endpoints**: Reference other resources either as contained resources (DocumentReference) or by business identifier only (`Reference.identifier` set, `Reference.reference` 0..0): patient by SSIN, practitioner/organisation by NIHDI/CBE, document by uniqueId (`urn:ietf:rfc:3986`). Use the `LogicalReference(element)` RuleSet in `be-interhub-observation.fsh`. Prohibit (0..0) references that have no national business identifier.
- **Laboratory Observation Search (`BeInterhubLabObservation`, Transaction 3)**:
  - `POST [base]/Observation/_search` with `patient.identifier` + `code` (LOINC); based on IHE QEDm PCC-44.
  - `derivedFrom` 1..1 = source document uniqueId; `homeCommunityId` 1..1 = hub to call `$retrieve-document` on (which accepts identifier-only references). This is the inline equivalent of IHE mXDE Provenance; do NOT introduce Provenance resources.
  - Responder rules: same access decision as the source document, only `current` documents, nothing from end-to-end encrypted documents.
- **No Cross-Hub Dereferencing (Prevent N+1 Queries)**:
  - In `DocumentReference`, authoring parties, custodians, and patient demographic snapshots MUST be **contained resources** (`DocumentReference.contained`).
  - Cross-document relationships (`relatesTo.target`) MUST use **logical references** by business identifier (`relatesTo.target.identifier`, system `urn:ietf:rfc:3986`), never resolvable cross-hub HTTP URLs.
- **POST-Everywhere Mandate (No FHIR GET Reads)**:
  - CapabilityStatements (`BeInterhubDocumentResponder`, `BeInterhubDocumentConsumer`) must declare search (POST) and extended operations (`$retrieve-document`), **never** `interaction = #read` on DocumentReference or Bundle. GET leaks patient SSIN or document IDs in server logs and URL paths.
- **Open Coding Slices on `system`**:
  - `category` and `type` slice on `system` with a required `cd-transaction` code slice.
  - Slicing is open: local hospital codings and multilingual descriptions MUST be preserved alongside national codes and NEVER stripped when relaying between hubs.
- **Inline HCParty Extension**:
  - `author`, `authenticator`, and `custodian` carry the inline `BeExtHcPartyType` extension (`be-ext-hcparty-type` bound to `be-vs-cd-hcparty`) so KMEHR party types travel directly on the reference.
- **Mandatory Routing Extension**:
  - `DocumentReference` and `BeInterhubLabObservation` mandate `BeExtHomeCommunityId` (1..1 MS, `valueUri`) carrying the regional hub OID (`urn:oid:1.3.6.1.4.1.21297.1.X`).
- **M2M Security Model**:
  - Interhub auth is machine-to-machine OAuth 2.0 `client_credentials` using the hub's eHealth enterprise certificate (mTLS RFC 8705 or `private_key_jwt` RFC 7523). No eID/Itsme or user auth code flows in hub-to-hub calls.

---

## 4. Documentation & Authoring Gotchas

- **No LaTeX in Markdown**: The IG Markdown processor has no LaTeX engine. Never write `$\rightarrow$` or `$\longleftrightarrow$`. Use literal unicode arrows (`→`, `↔`) in body text. Reword headings to plain text ("... to ...") so HTML anchors remain clean.
- **Mermaid v11 Syntax Trap**: In `classDiagram`, curly braces `{id}` close the class declaration and cause parse failures (`Syntax error in text mermaid version ...`). Use brackets `[id]` instead.
- **Registering New Narrative Pages**: Adding any `.md` file to `input/pagecontent/` requires updating both `pages:` and `menu:` in `sushi-config.yaml`. Unregistered files will not be included in the navigation or compiled build.
- **Custom Template**: Template is configured in `ig.ini` as `#local-template` (located in `./local-template`), extending `hl7.be.fhir.template`.
