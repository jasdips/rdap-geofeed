%%%
Title = "An RDAP Extension for Geofeed Data"
area = "Applications and Real-Time Area (ART)"
workgroup = "Registration Protocols Extensions (regext)"
abbrev = "rdap-geofeed"
ipr= "trust200902"

[seriesInfo]
name = "Internet-Draft"
value = "draft-ietf-regext-rdap-geofeed-08"
stream = "IETF"
status = "standard"
date = 2024-10-17T00:00:00Z

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

This document defines a new Registration Data Access Protocol (RDAP) extension, "geofeed1", for indicating that an RDAP
server hosts geofeed URLs for its IP network objects. It also defines a new media type and link relation type for the
associated link objects included in responses.

{mainmatter}

# Introduction

[@?RFC8805] and [@!RFC9632] detail the IP geolocation feed (commonly known as 'geofeed') file format and associated
access mechanisms. This document specifies how geofeed URLs can be accessed through RDAP. It defines a new RDAP
extension, "geofeed1", for indicating that an RDAP server hosts geofeed URLs for its IP network objects, as well as a
media type and a link relation type for the associated link objects.

## Requirements Language

The keywords "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED",
"NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [@!BCP14] when, and only
when, they appear in all capitals, as shown here.

Indentation and whitespace in examples are provided only to illustrate element relationships, and are not a REQUIRED
feature of this protocol.

"..." in examples is used as shorthand for elements defined outside of this document.

# Specification

## Media Type for a Geofeed Link {#media_type_for_a_geofeed_link}

[@!RFC9632] requires a geofeed file to be a UTF-8 [@!RFC3629] comma-separated values (CSV) file, with a series of "#"
comments at the end for the optional Resource Public Key Infrastructure (RPKI, [@?RFC6480]) signature. At first glance,
the "text/csv" media type ([@?I-D.shafranovich-rfc4180-bis, section 4]) seems like a good candidate for a geofeed file,
since it supports the "#" comments needed for including the RPKI signature.

However, although the CSV geofeed data could be viewed directly by a user such that the "text/csv" media type was
appropriate, the most common use case will involve it being processed by some sort of application first, in order to
facilitate subsequent address lookup operations. Therefore, using a new "application" media type with a "geofeed"
subtype ([@?RFC6838, section 4.2.5]) for the geofeed data is preferable to using "text/csv".

To that end, this document registers a new "application/geofeed+csv" media type in the IANA Media Types Registry (see
(#media_types_registry)), and a new "+csv" suffix in the IANA Structured Syntax Suffixes Registry (see
(#structured_syntax_suffixes_registry)).

## Geofeed Link {#geofeed_link}

An RDAP server that hosts geofeed URLs for its IP network objects ([@!RFC9083, section 5.4]) may include link objects
for those geofeed URLs in IP network objects in its responses. These link objects are added to the "links" member of
each object ([@!RFC9083, section 4.2]).

In RDAP, the "value", "rel", and "href" JSON members are REQUIRED for any link object. Additionally, for a geofeed link
object, the "type" JSON member is RECOMMENDED. The geofeed-specific components of a link object are like so:

* "rel" -- The link relation type is set to "geo". This is a new link relation type for geographical data, registered in
  the IANA Link Relations Registry (see (#link_relations_registry)) by this document.
* "href" -- The target URL is set to the HTTPS URL of the geofeed file for an IP network.
* "type" -- "application/geofeed+csv" (see (#media_type_for_a_geofeed_link)).

An IP network object returned by an RDAP server may contain zero, one, or multiple geofeed link objects. An example
scenario where more than one geofeed link object would be returned is where the server is able to represent that data in
multiple languages (see the "hreflang" member of the link object).

## Extension Identifier

This document defines a new extension identifier, "geofeed1", for use by servers that host geofeed URLs for their IP
network objects and include geofeed URL link objects in their responses to clients in accordance with (#geofeed_link). A
server that uses this extension identifier MUST include it in the "rdapConformance" array for any lookup or search
response containing an IP network object, as well as in the help response. Here is an elided example for this inclusion:

```
{
    "rdapConformance": [ "rdap_level_0", "geofeed1", ... ],
    ...
}
```

An RDAP server may make use of the "application/geofeed+csv" media type and the "geo" link relation defined in this
specification in its responses without including the "geofeed1" extension identifier in those responses, because RDAP
servers are free to use any registered media type or link relation in a standard response (without implementing any
particular extension). The additional value of the extension identifier here is that it signals to the client that the
server hosts geofeed URLs for its IP network objects. This is useful where a client receives an IP network object
without a geofeed link object, because in that case the client can infer that no geofeed data is available for that
object, since the server would have provided it if it were available.

Although a server may use registered media types in its link objects without any restrictions, it may be useful to
define new RDAP extensions for those media types in order for the server to communicate to clients that it will make
data for that type accessible, in the same way that the server does with the "geofeed1" extension identifier.

## Example

The following is an elided example of an IP network object with a geofeed link object:

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

# Operational Considerations

When an RDAP server is queried for an IP network for a given address range, it is required to return the most-specific
IP network object that covers the address range. That IP network object may not have an associated geofeed link, but it
is possible that a less-specific IP network object does have such a link. Clients attempting to retrieve geofeed data
for a given address range via RDAP should consider whether to retrieve the parent object for the initial response (and
so on, recursively) in the event that the initial response does not contain geofeed data. Conversely, server operators
should consider interface options for resource holders in order to support the provisioning of geofeed links for all
networks covered by the associated data.

It is common for a resource holder to maintain a single geofeed file containing the geofeed data for all of their
resources. The resource holder then updates each of their network object registrations to refer to that single geofeed
file. As with geofeed references in inetnum objects (per [@!RFC9632]), clients who find a geofeed link object within an
IP network object MUST ignore geofeed data from that link that is outside the IP network object's address range.

[@?RFC8805, section 3.2] recommends that consumers of geofeed data verify that the publisher of the data is
authoritative for the relevant resources. The RDAP bootstrap process ([@!RFC9224]) helps clients with this
recommendation, since a client following that process will be directed to the RDAP server that is able to make
authoritative statements about the disposition of the relevant resources.

# Privacy Considerations

When including a geofeed file URL in an IP network object, it is expected that the service provider publishing the
geofeed file has followed the guidance from [@!RFC9632, section 7] to not accidentally expose the location of an
individual.

Many jurisdictions have laws or regulations that restrict the use of "personal data", per the definition in [@?RFC6973].
Given that, registry operators should ascertain whether the regulatory environment in which they operate permits
implementation of the functionality defined in this document.

# Security Considerations {#security_considerations}

[@!RFC9632] requires an HTTPS URL for a geofeed file. The geofeed file may also contain an RPKI signature. Besides that,
this document does not introduce any new security considerations past those already discussed in the RDAP protocol
specifications.

# IANA Considerations

## RDAP Extensions Registry

IANA is requested to register the following value in the RDAP Extensions Registry at [@RDAP-EXTENSIONS]:

* Extension identifier: geofeed1
* Registry operator: Any
* Published specification: This document.
* Contact: IETF <iesg@ietf.org>
* Intended usage: This extension describes version 1 of a method to access the IP geolocation feed data through RDAP.

## Link Relations Registry {#link_relations_registry}

IANA is requested to register the following value in the Link Relations Registry at [@LINK-RELATIONS]:

* Relation Name: geo
* Description: Indicates that the link context has a resource with geographic information at the link target.
* Reference: This document.

## Media Types Registry {#media_types_registry}

IANA is requested to register the following value in the Media Types Registry at [@MEDIA-TYPES]:

* Type name: application
* Subtype name: geofeed+csv
* Required parameters: N/A
* Optional parameters: N/A
* Encoding considerations: See [@!RFC9632, section 2].
* Security considerations: See (#security_considerations) of this document.
* Interoperability considerations: There are no known interoperability problems regarding this media format.
* Published specification: This document.
* Applications that use this media type: Implementations of the Registration Data Access Protocol (RDAP) Extension for
  Geofeed Data. Furthermore, any application that processes the CSV geofeed data.
* Additional information: This media type is a product of the IETF REGEXT Working Group. The REGEXT charter, information
  on the REGEXT mailing list, and other documents produced by the REGEXT Working Group can be found at [@REGEXT].
* Person & email address to contact for further information: IETF <iesg@ietf.org>
* Intended usage: COMMON
* Restrictions on usage: None
* Authors: Tom Harrison, Jasdip Singh
* Change controller: IETF
* Provisional Registration: No

## Structured Syntax Suffixes Registry {#structured_syntax_suffixes_registry}

IANA is requested to register the following value in the Structured Syntax Suffixes Registry
at [@STRUCTURED-SYNTAX-SUFFIXES]:

* Name: Comma-Separated Values (CSV)
* +suffix: +csv
* References: [@?RFC4180], [@?RFC7111]
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

# Implementation Status

NOTE: Please remove this section and the reference to RFC 7942 prior
to publication as an RFC.

This section records the status of known implementations of the
protocol defined by this specification at the time of posting of this
Internet-Draft, and is based on a proposal described in [@?RFC7942].
The description of implementations in this section is intended to
assist the IETF in its decision processes in progressing drafts to
RFCs.  Please note that the listing of any individual implementation
here does not imply endorsement by the IETF.  Furthermore, no effort
has been spent to verify the information presented here that was
supplied by IETF contributors.  This is not intended as, and must not
be construed to be, a catalog of available implementations or their
features.  Readers are advised to note that other implementations may
exist.

According to RFC 7942, "this will allow reviewers and working groups
to assign due consideration to documents that have the benefit of
running code, which may serve as evidence of valuable experimentation
and feedback that have made the implemented protocols more mature.  It
is up to the individual working groups to use this information as they
see fit".

## RIPE NCC

 * Responsible Organization: RIPE NCC
 * Location: https://rdap.db.ripe.net
 * Description: An RDAP server returning geofeed data.
 * Level of Maturity: This is a production implementation.
 * Coverage: This implementation covers all of the features described in this specification.
 * Contact Information: Ed Shryane, eshryane@ripe.net

# Acknowledgements

Mark Kosters provided initial support and encouragement for this work, along with the [@!RFC9632] authors. Gavin Brown
suggested using a web link instead of a simple URL string to specify a geofeed file URL. Andy Newton, James Gould, Scott
Hollenbeck, and Mario Loffredo also provided valuable feedback for this document.

# Change History

(Remove this section before publication.)

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

## Changes from 05 to 06

* The extension identifier inclusion is now a must.
* Added the "Operational Considerations" section to clarify the geofeed file and IP networks relationship, as well as
  how RDAP Bootstrap helps with a recommendation from RFC 8805.
* Updated the "Privacy Considerations" section to clarify the service provider responsibility.

## Changes from 06 to 07

* Updated the extension identifier text so as to clarify that the media type and link relation can be used independently
  of that identifier.

## Changes from 07 to 08

* Added implementation status section.

{backmatter}

<reference anchor='LINK-RELATIONS' target='https://www.iana.org/assignments/link-relations/'>
    <front>
        <title>Link Relations</title>
        <author>
            <organization>IANA</organization>
        </author>
    </front>
</reference>

<reference anchor='MEDIA-TYPES' target='https://www.iana.org/assignments/media-types/'>
    <front>
        <title>Media Types</title>
        <author>
            <organization>IANA</organization>
        </author>
    </front>
</reference>

<reference anchor='RDAP-EXTENSIONS' target='https://www.iana.org/assignments/rdap-extensions/'>
    <front>
        <title>RDAP Extensions</title>
        <author>
            <organization>IANA</organization>
        </author>
    </front>
</reference>

<reference anchor='REGEXT' target='https://datatracker.ietf.org/wg/regext/'>
    <front>
        <title>Registration Protocols Extensions</title>
        <author>
            <organization>IETF</organization>
        </author>
    </front>
</reference>

<reference anchor='STRUCTURED-SYNTAX-SUFFIXES' target='https://www.iana.org/assignments/media-type-structured-suffix/'>
    <front>
        <title>Structured Syntax Suffixes</title>
        <author>
            <organization>IANA</organization>
        </author>
    </front>
</reference>
