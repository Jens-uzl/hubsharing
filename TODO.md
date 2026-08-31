OPEN issues: 

[x] $\rightarrow$, $\longleftrightarrow$ $\longleftrightarrow$  $\longleftrightarrow$ $\longleftrightarrow$ is not rendering correctly
    FIXED: the IG markdown processor has no LaTeX support. All 16 occurrences replaced by
    unicode arrows (→ / ↔) in body text; in headings the arrow was reworded ("... to ...",
    "... and ...") so section anchors stay clean and linkable.
    Files: architecture.md, mapping-kmehr-to-hub.md, ehds-alignment.md, security.md

[x] envelope-and-metadata has a issue with the mermaid chart (Syntax error in text
mermaid version 11.14.0)
    FIXED: the class member "+url: https://hub.../fhir/Bundle/{id}" contained curly braces,
    which close the classDiagram class body -> parse error on that line. Changed to [id].
    Verified by parsing all 26 mermaid diagrams of the IG with mermaid 11 (0 failures), and
    by a control test confirming the pre-fix version still fails.

[x] Proposal 2: eHealth Platform IAM

• Centralized OIDC IdP
• eID / itsme® / Enterprise cert
• Automated consent validation

the proposal for INTERHUB communication is to use IAM (m2m) it does not rely on eID / Itsme, it uses a enterprise certificate for the hub to hub communication. 
    FIXED: security.md §2.2 rewritten as machine-to-machine only: OAuth 2.0 client_credentials
    with the hub's eHealth enterprise certificate (mTLS client auth RFC 8705 or private_key_jwt
    RFC 7523), organisation as token subject, no authorization-code flow, no OIDC ID token, no
    eID/itsme anywhere in the Interhub call. Added a token request + token claims example.
    Route-2 boxes in the security.md and architecture.md diagrams and the architecture.md
    route summary updated to match; comparison table header now says "National AS, M2M".

[x] envelope-and-metadata
category[cdTransaction]	1..1	CodeableConcept	Document category coded using the Belgian CD-TRANSACTION code system (https://www.ehealth.fgov.be/standards/fhir/core/CodeSystem/cd-transaction, OID 1.3.6.1.4.1.21297.100.3.1). Examples: sumehr, labresult, discharge, telemonitoring, note, referral. 
we should be able to give multiple codes using diffrent codeSystems to a document; because it might contain local codes: "dischargeReport" might also say "daghospitalisatieVerslag" using another coding system, make sure this is compatible. 
    FIXED: category[cdTransaction].coding is now sliced (open, on system) with a mandatory
    cdTransactionCode slice; the blanket "every coding must be cd-transaction" constraint that
    blocked local codes is gone. Local/alternative codings of the same category are explicitly
    allowed and MUST NOT be dropped when relaying between hubs; category[cdTransaction].text
    added for uncoded local labels. Same rule documented for `type`.
    New envelope-and-metadata.md §4.2 states the four rules (same concept -> extra coding;
    different concept -> extra category element; no code -> text; search matches any coding)
    with a discharge/daghospitalisatieVerslag JSON example. DocRefLabReportExample now carries
    a local UZ Leuven catalogue coding next to the national one.

[x] author (cover all HCPARTY types) see: https://www.ehealth.fgov.be/standards/kmehr/en/tables/healthcare-party-type
    FIXED: author now allows Practitioner | PractitionerRole | Organization | Device | Patient |
    RelatedPerson (the full base set), so every CD-HCPARTY class is representable. Added the
    BeExtHcPartyType extension (be-ext-hcparty-type, valueCoding bound extensible to the HL7
    Belgium core value set be-vs-cd-hcparty, 241 codes) so the KMEHR party type travels INLINE
    next to the reference — no resolution needed to know whether an author is a laboratory, a
    retirement home or software. author.identifier and author.display are Must Support for the
    same reason. Class-by-class mapping table in envelope-and-metadata.md §3.5 and in
    mapping-kmehr-to-hub.md §3.3. Same treatment applied to Composition.author in both
    document profiles.

[x] authenticator	0..1	Reference(...)	Healthcare professional or organization legally validating/attesting the document. USE HCparty again
    FIXED: authenticator carries extension[hcPartyType], identifier and display, same as author;
    documented as "any CD-HCPARTY person, department or organisation type". Composition
    attester.party got the same treatment.

[x] custodian	0..1	Reference(Organization)	Organization responsible for the long-term maintenance of the document record (e.g., hospital vault).
    FIXED (assumed same intent as the two items above — please confirm): custodian is documented
    as a CD-HCPARTY *organisation* type (orghospital, orglaboratory, orgpharmacy, orgpractice,
    orgretirementhome, orgpolyclinic, ...) rather than "a hospital vault", and carries
    extension[hcPartyType], identifier (institution NIHDI / CBE) and display.

[x] relatesTo, try to find a way in fhir to not reference these things perse as references, but make it possible to reference a thing by buisness identifiers, because i don't want fhir references that point to additional endpoints that need to be resolved and queried for information leading to N+1
    FIXED: FHIR calls this a *logical reference* — Reference.identifier populated without
    Reference.reference. relatesTo.target.identifier is now mandatory (1..1, system =
    urn:ietf:rfc:3986) and carries the related document's uniqueId, i.e. exactly the value a
    consumer would pass to getTransaction. relatesTo.target.reference is optional and a consumer
    MUST NOT be required to dereference it. The same identifier-first rule is documented for
    subject, author, authenticator and custodian (SHOULD) in envelope-and-metadata.md §4.3,
    with the N+1 rationale and a JSON example; DocRefLabReportExample demonstrates a "replaces"
    relationship expressed purely by identifier.

[x] Scope & Architecture Boundaries: Interhub (Hub-to-Hub) vs. Intrahub (Clinical Apps to Hub)
    FIXED: Clarified across all diagrams and documentation that Interhub is strictly and exclusively
    Hub-to-Hub communication. Clinical applications (EHR, LIS, portals, telemonitoring apps) connect
    to their designated local Hub via Intrahub endpoints (KMEHR or internal protocols / standards),
    which are OUT OF SCOPE for this IG.
    Updated diagrams and descriptions in index.md, architecture.md, transactions.md, security.md,
    ihe-mhd-alignment.md, minimal-vs-comprehensive.md, envelope-and-metadata.md, be-interhub-capabilities.fsh,
    and README.md to show:
    Clinical Apps (EHR, portals, ...) -[Intrahub]-> Intrahub Endpoint -> Initiating Hub -[INTERHUB]-> Responding Hub(s).


[_] Key Domain Coverage: "what about the other document, the old KMEHR documents, this is also a part that we need to cover in this section"

[ ] DocumentReference.identifier slicing cannot be evaluated: identifier is sliced on `system`
    (#value), but the localId slice cannot fix a system (local systems are arbitrary), so the
    validator errors on every identifier of every DocumentReference example:
    "the discriminator [system] does not have fixed value, binding or existence assertions".
    Recommended fix: keep the uniqueId slice (system fixed to urn:ietf:rfc:3986) and drop the
    named localId slice — the open slicing already permits local identifiers; documentation and
    examples then use plain `identifier` entries instead of `identifier[localId]`.

[ ] BeInterhubDocumentBundle.entry slicing is discriminated by #profile on path `resource`,
    but the composition slice sets no profile, so EVERY entry matches the slice:
    "Bundle.entry:composition: max allowed = 1, but found 8" plus one error per non-Composition
    entry (~40 errors on each document bundle example).
    Recommended fix: discriminator type #type on path `resource` (the pattern used by IPS and
    IHE MHD document bundles), keeping `entry[composition].resource only Composition`.

================================================================================
GAPS vs. THE LIVE KMEHR HUB / METAHUB SERVICES
(added 2026-08-25 after reviewing the eHealthHubsClient reference implementation
 — intrahub v1/v3 and metahub v1/v2 protocols. The client is a sample and its
 mapping may itself be incomplete, so each item below is phrased as "the KMEHR
 service exists and the IG says nothing about it", not as "the client does X".)
================================================================================

--- A. HUB OPERATIONS THE IG DOES NOT COVER AT ALL ------------------------------

[ ] putTransaction / declareTransaction / revokeTransaction — PUBLISHING.
    The IG is read-only: it specifies getTransactionList (ITI-67) and
    getTransaction (ITI-68) and nothing else. A hub source therefore has no
    specified way to publish a document into a FHIR hub, to replace one, or to
    withdraw one that was entered in error. This is the single largest hole:
    `status = entered-in-error` and `relatesTo = replaces` are defined in the
    envelope but nothing can ever set them.
    Target: IHE MHD ITI-65 (Provide Document Bundle) + a DocumentReference
    update/delete contract, and a statement of who may publish on whose behalf.

[ ] requestPublication — asking a hub to (re)publish everything it holds for a
    patient. No FHIR equivalent proposed. Decide whether it survives the
    migration; if it does, it is an operation ($request-publication) rather
    than a REST verb.

[ ] getPatient / putPatient — the hub-local patient index (SSIN, name, birth
    date, sex, nationality, address with CD-ADDRESS / CD-FED-COUNTRY / NIS
    code). The IG assumes a patient is always addressable by SSIN and never
    says how a hub registers or resolves one.
    Target: PIXm (ITI-83) / PDQm (ITI-78) against BePatient.

[ ] getHCParty / putHCParty — the hub-level healthcare-party registry.
    Target: IHE mCSD (ITI-90) against BePractitioner / BeOrganization.

[ ] getAccessRight / putAccessRight / revokeAccessRight — per-document,
    per-party access rights held INSIDE a hub. The IG's trust model says access
    control is the initiating hub's business, which is a defensible position for
    the interhub channel, but it leaves these three operations with no successor
    and no statement that they are deliberately out of scope. Say which it is.

[ ] getHCPartyConsent / putHCPartyConsent / revokeHCPartyConsent — a healthcare
    party's own consent to participate in the hub system. Not mentioned anywhere.

--- B. METAHUB / NATIONAL REGISTERS ---------------------------------------------

[ ] getPatientLinks / declarePatientLink / revokePatientLink — WHICH HUBS HOLD
    DATA FOR THIS PATIENT. This is step 0 of every federated query, and the IG
    describes it only in prose ("the initiating hub retrieves the patient
    links", architecture.md §3.2). There is no FHIR interaction, no resource, no
    search parameter and no caching contract for it. Everything else in the
    guide depends on it.
    Also needs: what a client does with a link to a hub identifier it does not
    recognise, and the TTL / invalidation rule for a cached link set.

[ ] Informed consent register (getPatientConsent, getPatientConsentStatus,
    declarePatientConsent, revokePatientConsent — metahub AND hub-local). Not
    modelled. Concepts with no FHIR home today:
      • CD-CONSENTTYPE: retrospective vs prospective consent
      • signdate / revokedate
      • status GIVEN | REVOKED | DECEASED (deceased is a distinct state, not
        the absence of consent)
      • the eID card number recorded as evidence of who signed (EID-CARDNO)
      • the author chain that declared the consent
      • HUB-LOCAL consent (cd S="LOCAL" = "local") as a thing distinct from the
        national consent — the IG has no notion of a local consent at all
    Target: a Belgian Consent profile + read/declare/revoke interactions.

[ ] Therapeutic links (getTherapeuticLink / putTherapeuticLink /
    revokeTherapeuticLink). Not modelled. Carries CD-THERAPEUTICLINKTYPE,
    start/end date, and a free-text comment on revocation. The IG names
    therapeutic links repeatedly as an input to the initiating hub's access
    decision but never says how they are read or written.

[ ] Therapeutic exclusions (get/put/revokeTherapeuticExclusion) — the patient
    excluding a named practitioner or organisation. Not modelled. Note the
    matching semantics are not a plain identifier comparison: person exclusions
    are commonly evaluated on the PRACTICE prefix of the NIHDI number rather
    than the full number, organisation exclusions on the full institution
    number. Whatever FHIR shape is chosen (Consent with a deny provision.actor
    is the obvious candidate) must be able to express "this practice", not only
    "this person".

[ ] getMetahubDelta — a delta/synchronisation feed over the metahub registers,
    by register type and date range. No FHIR equivalent proposed
    (Subscriptions? bulk export? `_since` on a search?). Without it every
    consumer of the registers has to poll them whole.

--- C. ENVELOPE / TRANSACTION GAPS STILL OPEN -----------------------------------

[ ] `searchtype=local` search parameter is now DOCUMENTED in transactions.md
    §2.2 but has no formal SearchParameter resource and no CapabilityStatement
    entry. Define it (or replace it with an agreed standard mechanism) before
    the parameter is used in anger.

[ ] ITI-68 has nowhere to nominate the ENCRYPTION ACTOR. In the legacy
    getTransaction / getTransactionSet the caller supplies ID-ENCRYPTION-ACTOR,
    CD-ENCRYPTION-ACTOR and optionally ID-ENCRYPTION-APPLICATION in its own
    request, and the responding hub seals the payload for that actor at response
    time. A plain `GET /Bundle/{id}` cannot express this. Documented as an open
    question in end-to-end-encryption.md §2.1; needs an actual mechanism
    (header, search parameter, or token claim) that is covered by the request
    signature.

[ ] "The end user is the patient" has no normative representation. It changes
    what a client is allowed to display (the patient-access filter) and how the
    access is audited, but the only carrier proposed is an unverified claim
    (security.md §2.4). Decide whether that is sufficient.

[ ] No Binary profile / conformance rules for hub-rendered PDFs, now that
    transactions.md §3.4 makes them a first-class alternative content entry.

[ ] pharmaceuticalmedicationscheme is missing from the CD-TRANSACTION
    CodeSystem, although it is precisely the category that drives the
    transaction-set retrieval path.

[ ] DOCUMENT-TYPE COVERAGE (this is the concrete form of the open
    "Key Domain Coverage / the old KMEHR documents" item above). Only two of
    the twelve CD-TRANSACTION categories the IG itself publishes have a document
    profile and a format code: labresult and telemonitoring. sumehr, discharge,
    note, referral, prescription, radiology, vaccination, nursing, dietetics,
    paramedical (and pharmaceuticalmedicationscheme, once added) can all be
    discovered through getTransactionList but there is no specification of what
    comes back from getTransaction for any of them. Until that is filled in, a
    hub can advertise a discharge report it has no defined way to serve.
    Decide per category: native FHIR document profile, or KMEHR-in-a-lnk
    passthrough for the transition (mapping-kmehr-to-hub.md §4).

[ ] Imaging / PACS entries are not documents. Some hub transactions are not a
    retrievable payload at all but a deep link into an imaging portal (an SSO
    launch URL identified by a local id scheme). The IG has no model for a
    DocumentReference whose content is a launch link rather than a document,
    and no rule for how a consumer should render one.

[ ] Deduplication across hubs. Partial-failure handling is specified
    (transactions.md §2.4) but not what a client does when two hubs return the
    same underlying document. Related: the minted `identifier[uniqueId]` rule
    (mapping-kmehr-to-hub.md §2.1) is what makes dedup possible, so the two
    need to be specified together.

[ ] Paging contract for a federated fan-out search. `_count` and `_sort` are
    listed as supported, but nothing says how `Bundle.link[next]` behaves when
    the result set is assembled from several hubs answering at different speeds.

[ ] Patients without a usable SSIN. Hub responses may identify a patient by a
    non-INSS identifier (ID-PATIENT). The IG assumes SSIN throughout; say what
    a gateway does with the fallback.

[ ] Confidentiality (CD-CONFIDENTIALITY -> securityLabel) is mapped but never
    exemplified, and the guide does not state whether Belgian hubs actually
    populate it today. If they do not, say so, so implementers do not build
    filtering on an element that is always absent.

--- D. SECURITY / AUDIT ---------------------------------------------------------

[ ] getPatientAuditTrail (hub AND metahub) has no FHIR counterpart. The IG
    specifies how an AuditEvent is WRITTEN (security.md §5) but not how the
    recorded accesses are READ BACK — which is the half that discharges the
    Patient Rights Act transparency obligation. Needs: an AuditEvent profile,
    the search parameters (patient, date range, accessing party, operation,
    result limit), and a statement of who may call it. Flagged inline in
    security.md §5.

[ ] The token claim names introduced in security.md §2.2 / §2.4
    (`be:organization.ehp_number`, `be:recognised_hub`, `be:practitioner`,
    `be:software`, patient-as-requester) are proposals, not registered claims.
    They mirror the attributes the current eHealth STS assertion carries
    (`urn:be:fgov:ehealth:1.0:hub:ehp-number`,
    `urn:be:fgov:ehealth:1.0:certificateholder:organization:ehp-number`,
    `...:recognisedhub:boolean`). Get them registered or aligned with whatever
    eHealth IAM actually issues.
