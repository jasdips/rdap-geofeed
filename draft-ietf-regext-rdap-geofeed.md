%%%
Title = "An RDAP Extension for Geofeed Data"
area = "Applications and Real-Time Area (ART)"
workgroup = "Registration Protocols Extensions (regext)"
abbrev = "rdap-geofeed"
ipr= "trust200902"

[seriesInfo]
name = "Internet-Draft"
value = "draft-ietf-regext-rdap-geofeed-00"
stream = "IETF"
status = "standard"
date = 2023-12-11T00:00:00Z

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

This document defines a new RDAP extension `geofeedv1` for including a geofeed
file URL in an IP Network object.

{mainmatter}

# Introduction

[@!RFC8805] and [@?I-D.ymbk-opsawg-9092-update] (obsoletes [@!RFC9092]) detail
the IP geolocation feed (in short, geofeed) concept. This document specifies
how the geofeed data can be accessed through RDAP. It defines a new RDAP
extension `geofeedv1` for including a geofeed file URL in an IP Network object.

## Requirements Language

The keywords "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 [@!RFC2119] [@!RFC8174]
when, and only when, they appear in all capitals, as shown here.

# Specification

## Extension

A new RDAP extension `geofeedv1` is defined for accessing the geofeed data
through RDAP. It extends the IP Network object class [@!RFC9083] to include
a new `geofeed` member.

An RDAP server conforming to this specification MUST include the `geofeedv1`
extension string in the `rdapConformance` array for the IP Network lookup and
search responses, as well as in the help response.

## Geofeed Member

The IP Network object class is extended to include a new `geofeed` member, as
specified below:

geofeed — a string specifying the HTTPS URL of the geofeed file for an IP
          network [@!RFC9092]

Since this specification extends the base definition of the IP Network object
class, per [@!RFC7480, section 6], the `geofeed` member name MUST be prefixed
with the `geofeedv1` extension string, followed by an underscore:
`geofeedv1_geofeed`.

The `geofeed` member is OPTIONAL for the `geofeedv1` extension. Furthermore,
the Redaction by Removal method [@?I-D.ietf-regext-rdap-redacted] SHOULD be
used when redacting this member.

## Example

Here is an elided example of an IP Network object with the `geofeedv1` extension
and the `geofeedv1_geofeed` member:

```
{
  "rdapConformance" : [
    "rdap_level_0",
    "geofeedv1"
  ],
  "objectClassName" : "ip network",
  "handle" : "XXXX-RIR",
  "startAddress" : "2001:db8::",
  "endAddress" : "2001:db8:0:ffff:ffff:ffff:ffff:ffff",
  "ipVersion" : "v6",
  "name": "NET-RTR-1",
  "type" : "DIRECT ALLOCATION",
  "country" : "AU",
  "parentHandle" : "YYYY-RIR",
  "status" : [ "active" ],
  …
  "geofeedv1_geofeed" : "https:example.net/geofeed"
}
```

# Privacy Considerations

When including a geofeed file URL in an IP Network object, an RDAP server
operator SHOULD follow the guidance from [@?I-D.ymbk-opsawg-9092-update, section 7]
to not accidentally expose the location of an individual. 

# Security Considerations

[@?I-D.ymbk-opsawg-9092-update] requires an HTTPS URL for a geofeed file, and
optionally RPKI-signing the data within. Besides that, this document does not
introduce any new security considerations past those already discussed in the
RDAP protocol specifications.

# IANA Considerations

IANA is requested to register the following value in the RDAP Extensions
Registry:

Extension identifier: geofeedv1

Registry operator: Any

Published specification: This document.

Contact: IETF <iesg@ietf.org>

Intended usage: This extension describes version 1 of a method to access the IP
                geolocation feed data through RDAP.

{backmatter}
