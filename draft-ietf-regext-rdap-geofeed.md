%%%
Title = "An RDAP Extension for Geofeed Data"
area = "Applications and Real-Time Area (ART)"
workgroup = "Registration Protocols Extensions (regext)"
abbrev = "rdap-geofeed"
ipr= "trust200902"

[seriesInfo]
name = "Internet-Draft"
value = "draft-ietf-regext-rdap-geofeed-06"
stream = "IETF"
status = "standard"
date = 2024-06-04T00:00:00Z

[[author]]
initials="J."
surname="Singh"
fullname="Jasdip Singh"
organization="ARIN"
[author.address]
email = "jasdips@arin.net"

[[author]]
initials="T."
surname="Harrison"
fullname="Tom Harrison"
organization="APNIC"
[author.address]
email = "tomh@apnic.net"

%%%

.# Abstract

This document defines a new Registration Data Access Protocol (RDAP)
extension, "geofeed1", for indicating that an RDAP server hosts
geofeed URLs for its IP network objects.  It also defines a new media
type and link relation type for the associated link objects included
in responses.

{mainmatter}

# Introduction

[@!RFC8805] and [@?I-D.ietf-opsawg-9092-update] (obsoletes
[@!RFC9092]) detail the IP geolocation feed (commonly known as
'geofeed') file format and associated access mechanisms. This document
specifies how geofeed URLs can be accessed through RDAP. It defines a
new RDAP extension, "geofeed1", for indicating that an RDAP server
hosts geofeed URLs for its IP network objects, as well as a media type
and a link relation type for the associated link objects.

## Requirements Language

The keywords "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" in this document are to be interpreted as described in BCP
14 [@!RFC2119] [@!RFC8174] when, and only when, they appear in all
capitals, as shown here.

Indentation and whitespace in examples are provided only to illustrate
element relationships, and are not a REQUIRED feature of this
protocol.

"..." in examples is used as shorthand for elements defined outside of
this document.

# Specification

## Media Type for a Geofeed Link {#media_type_for_a_geofeed_link}

[@?I-D.ietf-opsawg-9092-update] requires a geofeed file to be a UTF-8
[@!RFC3629] comma-separated values (CSV) file, with a series of "#"
comments at the end for the optional Resource Public Key
Infrastructure (RPKI, [@!RFC6480]) signature. At first glance, the
"text/csv" media type ([@?I-D.shafranovich-rfc4180-bis, section 4])
seems like a good candidate for a geofeed file, since it supports the
"#" comments needed for including the RPKI signature.

However, although the CSV geofeed data could be viewed directly by a
user such that the "text/csv" media type was appropriate, the most
common use case will involve it being processed by some sort of
application first, in order to facilitate subsequent address lookup
operations.  Therefore, using a new "application" media type with a
"geofeed" subtype ([@!RFC6838, section 4.2.5]) for the geofeed data is
preferable to using "text/csv".

To that end, this document registers a new "application/geofeed+csv"
media type in the IANA Media Types Registry (see
(#media_types_registry)), and a new "+csv" suffix in the IANA
Structured Syntax Suffixes Registry (see
(#structured_syntax_suffixes_registry)).

## Geofeed Link

An RDAP server that hosts geofeed URLs for its IP network objects
([@!RFC9083, section 5.4]) may include link objects for those geofeed
URLs in IP network objects in its responses.  These link objects are
added to the "links" member of each object ([@!RFC9083, section 4.2]).

In RDAP, the "value", "rel", and "href" JSON members are REQUIRED for
any link object.  Additionally, for a geofeed link object, the "type"
JSON member is RECOMMENDED.  The geofeed-specific components of a link
object are like so:

* "rel" -- The link relation type is set to "geo". This is a new link
  relation type for geographical data, registered
  in the IANA Link Relations Registry (see (#link_relations_registry))
  by this document.
* "href" -- The target URL is set to the HTTPS URL of the geofeed
  file for an IP network.
* "type" -- "application/geofeed+csv" (see (#media_type_for_a_geofeed_link)).

An IP network object returned by an RDAP server may contain zero, one,
or multiple geofeed link objects.  An example scenario where more than
one geofeed link object would be returned is where the server is able
to represent that data in multiple languages (see the "hreflang"
member of the link object).

## Extension Identifier

An RDAP server that returns geofeed link objects in accordance with
this specification is RECOMMENDED to include the "geofeed1" extension
identifier in the "rdapConformance" array for any lookup or search
response containing an IP network object, as well as in the help
response. Here is an elided example for this inclusion:

```
{
    "rdapConformance": [ "rdap_level_0", "geofeed1", ... ],
    ...
}
```

Extension identifier inclusion is not mandatory, because RDAP does not
require that an extension identifier be included in responses merely
to make use of new media types or link relation types.  An RDAP server
that includes the "geofeed1" identifier is signalling to clients that
it hosts geofeed URLs and will return those URLs in accordance with
this specification where they are available.  The main benefit of
including the identifier is that it permits a client to determine that
a server does host geofeed URLs, which is useful where a client
receives an IP network object without a geofeed URL, for example.

Although a server may use registered media types in its link objects
without any restrictions, it may be useful to define new RDAP
extensions for those media types in order for the server to
communicate to clients that it will make data for that type
accessible, in the same way that the server does with the "geofeed1"
extension identifier.

## Example

The following is an elided example of an IP network object with a
geofeed link object:

```
{
    "objectClassName": "ip network",
    "handle": "XXXX-RIR",
    "startAddress": "2001:db8::",
    "endAddress": "2001:db8:0:ffff:ffff:ffff:ffff:ffff",
    "ipVersion": "v6",
    "name": "NET-RTR-1",
    "type": "DIRECT ALLOCATION",
    "country": "AU",
    "parentHandle": "YYYY-RIR",
    "status": [ "active" ],
    "links":
     [
        {
            "value": "https://example.net/ip/2001:db8::/48",
            "rel": "self",
            "href": "https://example.net/ip/2001:db8::/48",
            "type": "application/rdap+json"
        },
        {
            "value": "https://example.net/ip/2001:db8::/48",
            "rel": "geo",
            "href": "https://example.com/geofeed",
            "type": "application/geofeed+csv"
        },
        ...
    ],
    ...
}
```

# Privacy Considerations

When including a geofeed file URL in an IP network object, an RDAP
server operator SHOULD follow the guidance from
[@?I-D.ietf-opsawg-9092-update, section 7] to not accidentally expose
the location of an individual.

Many jurisdictions have laws or regulations that restrict the use of
"personal data", per the definition in [@!RFC6973].  Given that,
registry operators should ascertain whether the regulatory environment
in which they operate permits implementation of the functionality
defined in this document.

# Security Considerations {#security_considerations}

[@?I-D.ietf-opsawg-9092-update] requires an HTTPS URL for a geofeed
file.  The geofeed file may also contain an RPKI signature.  Besides
that, this document does not introduce any new security considerations
past those already discussed in the RDAP protocol specifications.

# IANA Considerations

## RDAP Extensions Registry

IANA is requested to register the following value in the RDAP Extensions Registry at
https://www.iana.org/assignments/rdap-extensions/:

* Extension identifier: geofeed1
* Registry operator: Any
* Published specification: This document.
* Contact: IETF <iesg@ietf.org>
* Intended usage: This extension describes version 1 of a method to access the IP geolocation feed data through RDAP.

## Link Relations Registry {#link_relations_registry}

IANA is requested to register the following value in the Link Relations Registry at
https://www.iana.org/assignments/link-relations/:

* Relation Name: geo
* Description: Indicates that the link context has a resource with geographic information at the link target.
* Reference: This document.

## Media Types Registry {#media_types_registry}

IANA is requested to register the following value in the Media Types Registry at
https://www.iana.org/assignments/media-types/:

* Type name: application
* Subtype name: geofeed+csv
* Required parameters: N/A
* Optional parameters: N/A
* Encoding considerations: See [@?I-D.ietf-opsawg-9092-update, section 2].
* Security considerations: See (#security_considerations) of this document.
* Interoperability considerations: There are no known interoperability problems regarding this media format.
* Published specification: This document.
* Applications that use this media type: Implementations of the Registration Data Access Protocol (RDAP) Extension for
  Geofeed Data. Furthermore, any application that processes the CSV geofeed data.
* Additional information: This media type is a product of the IETF REGEXT Working Group. The REGEXT charter, information
  on the REGEXT mailing list, and other documents produced by the REGEXT Working Group can be found at
  https://datatracker.ietf.org/wg/regext/.
* Person & email address to contact for further information: IETF <iesg@ietf.org>
* Intended usage: COMMON
* Restrictions on usage: None
* Authors: Tom Harrison, Jasdip Singh
* Change controller: IETF
* Provisional Registration: No

## Structured Syntax Suffixes Registry {#structured_syntax_suffixes_registry}

IANA is requested to register the following value in the Structured Syntax Suffixes Registry at
https://www.iana.org/assignments/media-type-structured-suffix/:

* Name: Comma-Separated Values (CSV)
* +suffix: +csv
* References: [@!RFC4180], [@!RFC7111]
* Encoding Considerations: Same as "text/csv".
* Interoperability Considerations: Same as "text/csv".
* Fragment Identifier Considerations:

  The syntax and semantics of fragment identifiers specified for +csv SHOULD be as specified for "text/csv".

  The syntax and semantics for fragment identifiers for a specific "xxx/yyy+csv" SHOULD be processed as follows:

  For cases defined in +csv, where the fragment identifier resolves per the +csv rules, then as specified in +csv.

  For cases defined in +csv, where the fragment identifier does not resolve per the +csv rules, then as specified in
  "xxx/yyy+csv".

  For cases not defined in +csv, then as specified in "xxx/yyy+csv".

* Security Considerations: Same as "text/csv".
* Contact: IETF <iesg@ietf.org>

# Acknowledgements

Mark Kosters provided initial support and encouragement for this work, along with the [@!RFC9092] authors. Gavin Brown
suggested using a web link instead of a simple URL string to specify a geofeed file URL. Andy Newton, James Gould, and
Scott Hollenbeck also provided valuable feedback for this document.

# Change History

## Changes from 00 to 01

* Now using a web link instead of a simple URL string to specify a geofeed file URL.
* Renamed the extension as "geofeed1" instead of "geofeedv1".
* Introduced the new "geo" link relation type.
* Introduced the new "application/geofeed+csv" media type.

## Changes from 01 to 02

* Updated the "Requirements Language" section for examples.
* Added an example for RDAP conformance.
* Updated the rationale for using the new "application/geofeed+csv" media type.
* Updated the "Applications that use this media type" section for the "application/geofeed+csv" registration.

## Changes from 02 to 03

* Removed "value" and "hreflang" explanations from the "Geofeed Link" section. Further, clarified the cardinality of
  geofeed link objects.
* Updated extensibility verbiage in the "Media Type for a Geofeed Link" section.
* In the "Example" section, updated the domain in "href" of the geofeed link object to contrast with the domain in
  "value" to highlight that "href" is for a geofeed file hosted at a network operator site whereas "value" is for an IP
  network object from an RDAP server.
* Removed the "Redaction" section since the geofeed files are public to start with.
* Added URLs for various IANA registries.

## Changes from 03 to 04

* Updated the criteria for including the extension identifier in "rdapConformance".

## Changes from 04 to 05

* Made various editorial changes.

{backmatter}
