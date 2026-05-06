// ---- Extensions ----

Extension: TelemonitoringId
Id: telemonitoring-id
Title: "Telemonitoring Session Identifier"
Description: "Identifies the telemonitoring session this resource belongs to. Multiple resources may share the same telemonitoring session identifier."
* value[x] only Identifier
* valueIdentifier 1..1
* valueIdentifier.system 1..1
* valueIdentifier.value 1..1

Extension: Carepath
Id: carepath
Title: "Carepath"
Description: "The carepath associated with this telemonitoring session"
* extension contains
    carepathId 1..1 and
    version 0..1
* extension[carepathId].value[x] only string
* extension[carepathId] ^short = "Carepath identifier"
* extension[version].value[x] only string
* extension[version] ^short = "Carepath version"

Extension: PrescriberApplication
Id: prescriber-application
Title: "Prescriber Application"
Description: "The application used by the prescriber to initiate the telemonitoring session"
* value[x] only string
* valueString 1..1

// ---- Profile ----

Profile: TelemonitoringDiagnosticReport
Parent: DiagnosticReport
Title: "Telemonitoring Diagnostic Report"
Description: "A DiagnosticReport profile for sharing telemonitoring observations between hubs."

* extension contains
    TelemonitoringId named telemonitoringId 1..1 and
    Carepath named carepath 0..1 and
    PrescriberApplication named prescriberApplication 0..1 and
    PatientAuthentication named patientAuthentication 0..1

* status MS
* code 1..1 MS
* subject 1..1 MS
* subject only Reference(Patient)
* performer 0..* MS
* performer only Reference(Practitioner or Organization)
* result 0..* MS
* result only Reference(Observation)
* presentedForm 0..* MS

// ---- Example supporting resources ----

Instance: PrescriberExample
InstanceOf: Practitioner
Description: "An example prescriber"
* name[0].family = "Janssen"
* name[0].given[0] = "Peter"

// ---- Example instance ----

Instance: TelemonitoringDiagnosticReportExample
InstanceOf: TelemonitoringDiagnosticReport
Description: "An example of a telemonitoring diagnostic report based on the TMP base message structure"
* extension[telemonitoringId].valueIdentifier.system = "http://example.org/telemonitoring-id"
* extension[telemonitoringId].valueIdentifier.value = "tm-12345"
* extension[carepath].extension[carepathId].valueString = "holter-monitoring"
* extension[carepath].extension[version].valueString = "1.0"
* extension[prescriberApplication].valueString = "TeleMonApp v2.1"
* status = #registered
* code = http://example.org/service-types#telemonitoring "Telemonitoring"
* subject = Reference(PatientExample)
* performer = Reference(PrescriberExample)
* presentedForm[0].contentType = #application/pdf
* presentedForm[0].language = #nl
* presentedForm[0].url = "https://storage.example.org/attachments/doc1.pdf"
* presentedForm[0].size = 1024
* presentedForm[0].title = "Monitoring Report"
