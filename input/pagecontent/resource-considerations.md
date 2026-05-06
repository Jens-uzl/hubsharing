# Resource considerations

This page contains an explanation of the different profiles that have been considered as a carrier of the observation(s) and metadata like `telemonitoring-id`.

## Requirements

1. The profile should append metadata like 'patient-id', 'telemonitoring-id' to one or more observations. 
2. The profile should encompass multiple caresets that are defined in these structures: https://build.fhir.org/ig/hl7-be/patient-monitoring/en/artifacts.html
3. The profile will have to be able to be converted into a MinimalDocumentReference and a DocumentReference, so that it can be shared between hubs.

## Considerations

### Bundle
An initial consideration was to a [Bundle (messaging type)](https://build.fhir.org/messaging.html).
The metadata could then reside in the MessageHeader resource.
This didn't really fit since this seems to be more event-driven, and because this feels like it steers towards an actual routing system for messages, none which are required here. 

A second consideration was to use a FHIR document, more specific as a [document Composition](https://build.fhir.org/documents.html).
This is not used because a composition seems to more reference an actual report with an actual readable interpretation.
Since the observations that we want to share don't specifically require a readable representation, but should initially be focussed on sharing the actual caresets, this approach seems to be a bit too much. 
A composition might be used later together with the conversion to a (Minimal)DocumentReference if required, since Compositions are documents and transform to a DocumentReference. 
The biggest issue for the Composition is that the narrative text in `section.text` is a required field. 
The biggest reason why Composition can fit is because `section.entry` can actually point to the resources that are used in this composition. 
An extra plus is that compositions are immutable.
They break the link with their underlying resources.
This provides a useful snapshot that can easily be timestamped and shared without the need for synchronization.

### Another Observation

There is a case to be made that there could be a `meta` observation that relates to the other `Observation` resources.
The issue here is that this limits the encapsulation of the sources to the `Observation`-profile. 
Other profiles in the caresets, like a `QuestionnaireResponse`, might not fit as easily. 

The concept where this meta-observation will inherit from for example a `HolterObservation` is because the caresets have different observations.
For every one of these another `Observation` would be made then. 

### ServiceRequest

While a [`ServiceRequest`](https://www.hl7.org/fhir/R4/servicerequest.html) doesn't straight up fit because it's not an order, it seems to have enough support to make the metadata fit.
A `ServiceRequest` can also contain links to related `Observation` resources through the use of related `reasonReference` attributes.
The biggest issue here is that this represents an Order, while the current interpretation in [the example json message from the tmp platform](tmp-base-message.md) is more like a report.

## DiagnosticReport (current option)

A [`DiagnosticReport`](https://www.hl7.org/fhir/R4/diagnosticreport.html) seems to be a good fit as well.
It has the options in `.result` to contain a set of Observations.
It also represents the results more strongly then the request in `ServiceRequest`.  