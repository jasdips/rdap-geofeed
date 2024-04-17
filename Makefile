all: draft-ietf-regext-rdap-geofeed.txt

draft-ietf-regext-rdap-geofeed.txt: draft-ietf-regext-rdap-geofeed.xml
	xml2rfc draft-ietf-regext-rdap-geofeed.xml

draft-ietf-regext-rdap-geofeed.xml: draft-ietf-regext-rdap-geofeed.md
	mmark draft-ietf-regext-rdap-geofeed.md > draft-ietf-regext-rdap-geofeed.xml
