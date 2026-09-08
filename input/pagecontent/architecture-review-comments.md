# Architecture review comments extracted from PR #2

> This file contains review questions and drafting notes extracted from the proposed architecture update in PR #2. It is **not** normative specification content.

## 1. Scope and ecosystem framing (`# 1`, `## 1.1`, `## 1.2`)

### Comment A — Illustration placeholder

> "### 1.2 Intrahub versus interhub communication"

Original note (NL):
- "Eventueel zou een illustratie kunnen worden gebruikt gebaseerd op een slide van Frank Robbe."

### Comment B — Normative wording emphasis

> "This Implementation Guide ... FHIR-based Interhub standard for Hub-to-Hub metadata discovery (ITI-67) and document retrieval (ITI-68)."

Original note (NL):
- Strikethrough/edit around "normative" (`~~normative~~`) indicated uncertainty about the exact strength of wording.

## 2. Key actors and network diagram (`## 1.2 Key Actors & Nodes in the Network`)

### Comment C — Diagram arrow semantics

> Mermaid graph under "Key Actors & Nodes in the Network"

Original notes (NL):
- "Ik moet de tekening nog beter bekijken. De pijlen komen mogelijk verwarrend over, want wat stellen die uberhaupt voor?"
- "Het gaat blijkbaar niet om de richting van de communicatie."

### Comment D — Metahub paragraph markup

> "These registers are consulted by the **initiating hub** when it performs its own access control..."

Original note (NL):
- "[waarom bold]"

### Comment E — Hub list / Vitalink / runtime link resolution paragraph

> "The list is not closed, and not every node behaves identically... MUST treat the hub list as configuration resolved from the Metahub at runtime..."

Original note (NL):
- "[Dit moet ik nog beter lezen ... Dat van Vitalink vind ik een vreemde verwoording ... Resolving die links at run time dreigt als een rode lap te werken voor RSW.]"

### Comment F — Registry/indexing paragraph clarity

> "Each hub acts as a regional Document Registry and Document Gateway, managing indexing and cross-hub routing..."

Original note (NL):
- "[Ik vind het eerste deel van deze paragraaf vreemd verwoord ... Wil je een vergelijking trekken met XDS? ...]"

## 3. Hub source definition (`## 1.3 What Counts as a Hub Source`)

### Comment G — Terminology and section necessity

> "A **hub source** is any care organisation whose source system publishes documents on or shares them via a hub..."

Original notes (NL):
- "[Ik begrijp niet waarom zo'n indrukwekkende termen worden gebruikt ...]"
- "[Het is me eigenlijk niet duidelijk waarom je het hierover hebt. Ik doe een gok.]"
- "[Waarom authoritative en waarom moeten die data daar gestockeerd zijn?]"
- "[Zit deels in het vorige ... nog steeds niet duidelijk welke accenten je wil vermelden.]"
- "[Ik zou hier precies geen aparte sectie voor voorzien ...]"

## 4. SOAP-to-FHIR evolution diagram (`## 2. Evolution: From SOAP KMEHR to RESTful FHIR MHD`)

### Comment H — Unresolved wording alternatives

> "... updated Interhub specification ... **IHE MHD** on **HL7® FHIR® R4** ..."

Original notes (NL):
- Unresolved choice: "proposes [prescribes]"
- "[waarom R4?]"

### Comment I — "shape" and scope phrasing in explanatory paragraph

> "The diagram shows the *shape* of the exchange only..."

Original notes (NL):
- "[wat bedoel je met deze term?]"
- "[wat zijn dat?]" (about "clinical applications")
- "[maar dan weer niet voor bv. de huisartsenpakketten...]"

## 5. Routing and identifiers (`## 3. Federated Cross-Hub Routing & Identifiers`)

### Comment J — Heading/body alternatives

> "In a cross-hub exchange, an initiating hub queries or retrieves documents ..."

Original notes (NL):
- Strikethrough alternative in heading: `~~Federated~~Cross-Hub`
- "[information retrieval? Gaat het ooit om meer dan eenrichting?]"
- "[voor mij vreemde verwoording]" (about "What governs the routing itself ...")
- Minor edit trial in discovery bullet: `~~originally~~ made available by the metahub`

## 6. Dual-stack transition gateway (`## 4. Dual-Stack Gateway Architecture (Transition Phase)`)

### Comment K — Heading capitalization and term choices

> "Migration cannot be a flag day ... dual-stack mediation gateway ..."

Original notes (NL):
- "[Waarom Al Die HoofdLetters?]"
- "[mediation?]"
- "[wat bedoel je met deze term?]" (about "field-by-field")

## 7. Security summary and trust model (`## 5. Trust Model, Security Architecture & Connection Routes (Proposal)`)

### Comment L — Legal sentence and non-normative framing

> "Every Interhub transaction takes place under Belgian healthcare law, the Patient Rights Act and the GDPR."

Original note (NL):
- "[Dat lijkt me vanzelfsprekend ... vollediger moeten zijn ... door een jurist te laten schrijven.]"

### Comment M — Heading style and architecture support

> `### 5.1 Trust Model ...`

Original notes (NL):
- Concern over temporary heading style/capitalization: "HuBS ... InterHub CoMMunication"
- "[Vermelden dat dit ter informatie is? Het moet wel worden ondersteund door de architectuur, bv. wat betreft de toegangsmatrix.]"

### Comment N — Sensitive/disclaimer text and responsibility split

> Trust-model bullets describing initiating/responding hub checks

Original notes (NL):
- Embedded disclaimer draft: "Vitalink ... may not want to adhere to all of these rules."
- "[sommige van die zaken moet de initiating hub toch ook doen?]"

### Comment O — Section-title fit

> `### 5.2 Connection Routes`

Original note (NL):
- "[Moet ik nog lezen. Ik vind de titel alvast vreemd. Gaat het niet over authenticatie?]"
