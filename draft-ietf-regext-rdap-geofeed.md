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
date = 2023-12-15T00:00:00Z

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

This document defines a new RDAP extension "geofeed1" for including a geofeed file URL in an IP Network object.

{mainmatter}

# Introduction

[@!RFC8805] and [@?I-D.ymbk-opsawg-9092-update] (obsoletes [@!RFC9092]) detail the IP geolocation feed (in short,
geofeed) concept. This document specifies how the geofeed data can be accessed through RDAP. It defines a new RDAP
extension "geofeed1" for including a geofeed file URL in an IP Network object.

## Requirements Language

The keywords "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD","SHOULD NOT", "RECOMMENDED",
"NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in BCP 14
[@!RFC2119] [@!RFC8174] when, and only when, they appear in all capitals, as shown here.

# Specification

## Extension

A new RDAP extension "geofeed1" is defined for accessing the geofeed data through RDAP. It updates the IP Network object
class definition ([@!RFC9083, section 5.4]) to include a new link object for the geofeed file URL in its "links" array
([@!RFC9083, section 4.2]).

An RDAP server conforming to this specification MUST include the "geofeed1" extension string in the "rdapConformance"
array for the IP Network lookup and search responses, as well as in the help response.

## Geofeed Link

The IP Network object class ([@!RFC9083, section 5.4]) MAY include a link object for the geofeed file URL (also referred
to as a Geofeed link object) in its "links" array, with the following REQUIRED JSON members:

* "value" -- The "value" JSON value is the context URI and set to an IP Network lookup URL ([@!RFC9082, section 3.1.1]).
* "rel" -- The "rel" JSON value is the link relation type and set to the "geo" string. The "geo" link relation type is
new and will be registered in the IANA Link Relations Registry (see the "Link Relations Registry" section).
* "href" -- The "href" JSON value is the target URI and set to the HTTPS URL of the geofeed file for the IP network in
the context URI.

Per the definition of a web link ([@!RFC8288]), a Geofeed link object may have additional JSON members.
Specifically:

* "type" -- The "type" JSON value is the media type for the target URI. Given that the geofeed data is mostly intended
for use by automated/scripted processes, it is RECOMMENDED that server operators set a media type in Geofeed link
objects. See the "Media Type for a Geofeed Link" section for acceptable "type" values.
* "hreflang" -- The "hreflang" JSON value is an attribute for the target URI and could be used to indicate the languages
the geofeed data is available in. It is OPTIONAL.

There MAY be zero or more Geofeed link objects in the "links" array of an IP Network object. In other words, the Geofeed
link objects are OPTIONAL.

## Media Type for a Geofeed Link

[@?I-D.ymbk-opsawg-9092-update] requires a geofeed file to be a UTF-8 CSV file, with a series of "#" comments at the end
for the optional RPKI signature. At first glance, the "text/csv" media type ([@!RFC7111, section 5.1]) seems like a good
candidate to represent a geofeed file, but it does not support the "#" comments needed to include the RPKI signature.

To enable including "#" comments for an RPKI signature, a new media type "application/geofeed+csv" will be registered in
the IANA Media Types Registry (see the "Media Types Registry" section). The "type" JSON value in a Geofeed link object
SHOULD be set to the "application/geofeed+csv" media type.

If alternative geofeed formats are defined in the future, they could be included in future versions of this
specification.

## Example

The following is an elided example of an IP Network object with a "geofeed" link:

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
            "href": "https://example.net/geofeed",
            "type": "application/geofeed+csv"
        },
        ...
    ],
    ...
}
```

# Redaction

Since the Geofeed link objects in the "links" array of an IP Network object are optional, the Redaction by Removal
method [@?I-D.ietf-regext-rdap-redacted] MUST be used when redacting them. The following is an elided example of an IP
Network object with redacted "geofeed" links:

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
        ...
    ],
    "redacted":
    [
        {
            "name":
            {
                "description": "Geofeed links"
            },
            "prePath": "$.links[?(@.rel=='geo')]",
            "method": "removal"
        }
    ],
    ...
}
```

# Privacy Considerations

When including a geofeed file URL in an IP Network object, an RDAP server operator SHOULD follow the guidance from
[@?I-D.ymbk-opsawg-9092-update, section 7] to not accidentally expose the location of an individual. 

# Security Considerations

[@?I-D.ymbk-opsawg-9092-update] requires an HTTPS URL for a geofeed file, and optionally RPKI-signing the data within.
Besides that, this document does not introduce any new security considerations past those already discussed in the
RDAP protocol specifications.

# IANA Considerations

## RDAP Extensions Registry

IANA is requested to register the following value in the RDAP Extensions Registry:

* Extension identifier: geofeed1
* Registry operator: Any
* Published specification: This document.
* Contact: IETF <iesg@ietf.org>
* Intended usage: This extension describes version 1 of a method to access the IP geolocation feed data through RDAP.

## Link Relations Registry

IANA is requested to register the following value in the Link Relations Registry:

* Relation Name: geo
* Description: Indicates that the link context has a resource with geographic information at the link target.
* Reference: This document.

## Media Types Registry

* Type name: application
* Subtype name: geofeed+csv
* Required parameters: N/A
* Optional parameters: N/A
* Encoding considerations: See [@?I-D.ymbk-opsawg-9092-update, section 2].
* Security considerations: See the "Security Considerations" section of this document.
* Interoperability considerations: There are no known interoperability problems regarding this media format.
* Published specification: This document.
* Applications that use this media type: Implementations of the Registration Data Access Protocol (RDAP) Extension for
Geofeed Data.
* Additional information: This media type is a product of the IETF REGEXT Working Group. The REGEXT charter, information
on the REGEXT mailing list, and other documents produced by the REGEXT Working Group can be found at https://datatracker.ietf.org/wg/regext/.
* Person & email address to contact for further information: IESG <iesg&ietf.org>
* Intended usage: COMMON
* Restrictions on usage: None
* Authors: Tom Harrison, Jasdip Singh
* Change controller: IETF
* Provisional Registration: No

# Acknowledgements

Gavin Brown suggested using a web link instead of a simple URI string to specify a geofeed file URL.

# Change History

## Changes from 00 to 01

* Now using a web link instead of a simple URI string to specify a geofeed file URL.
* Renamed the extension as "geofeed1" instead of "geofeedv1".
* Introduced the new "geo" link relation type.
* Introduced the new "application/geofeed+csv" media type.

{backmatter}
