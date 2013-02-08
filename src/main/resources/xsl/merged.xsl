<!--
    Author: Sarven Capadisli <info@csarven.ca>
    Author URI: http://csarven.ca/#i

    Description: XSLT for MAREC data
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:fn="http://270a.info/xpath-function/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:prov="http://www.w3.org/ns/prov#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:xkos="http://purl.org/linked-data/xkos#"
    xmlns:pso="http://www.patexpert.org/ontologies/pso.owl#"
    xmlns:pulo="http://www.patexpert.org/ontologies/pulo.owl#"
    xmlns:sumo="http://www.owl-ontologies.com/sumo.owl#"
    xmlns:pmo="http://www.patexpert.org/ontologies/pmo.owl#"
    xmlns:property="http://example.org/property/"
    xmlns:schema="http://schema.org/"
    xmlns:uuid="java:java.util.UUID"

    exclude-result-prefixes="xsl fn"
    >

<!--    xpath-default-namespace=""-->

<!--
TODO: ignore DTD check. saxonb-xslt breaks if offline
-->
	<!-- 
    <xsl:import href="common.xsl"/>
	-->
	
	<!-- COMMON BEGIN -->
	<!-- CONFIG START -->
    <xsl:variable name="xmlDocumentBaseURI" select="'http://example.org/'"/>
    <xsl:variable name="xslDocument" select="'https://github.com/fusepool/patents-reengineering/scripts/marec.xsl'"/>
    <xsl:variable name="baseURI" select="'http://example.org/'"/>
    <xsl:variable name="creator" select="'http://example.org/#i'"/>
    <xsl:variable name="lang" select="'en'"/>
    <xsl:variable name="uriThingSeparator" select="'/'"/>

    <xsl:variable name="provenance" select="concat($baseURI, 'provenance', $uriThingSeparator)"/>
    <xsl:variable name="concept" select="concat($baseURI, 'concept', $uriThingSeparator)"/>
    <xsl:variable name="code" select="concat($baseURI, 'code/')"/>
    <xsl:variable name="class" select="concat($baseURI, 'class', $uriThingSeparator)"/>
    <xsl:variable name="property" select="concat($baseURI, 'property', $uriThingSeparator)"/>
    <xsl:variable name="dataset" select="concat($baseURI, 'dataset/')"/>
    <xsl:variable name="patent" select="concat($baseURI, 'patent', $uriThingSeparator)"/>
    <xsl:variable name="patentFamily" select="concat($baseURI, 'family', $uriThingSeparator)"/>
    <xsl:variable name="party" select="concat($baseURI, 'party', $uriThingSeparator)"/>
<!-- CONFIG END -->

    <xsl:variable name="now" select="fn:now()"/>

    <xsl:variable name="rdf" select="'http://www.w3.org/1999/02/22-rdf-syntax-ns#'"/>
    <xsl:variable name="rdfs" select="'http://www.w3.org/2000/01/rdf-schema#'"/>
    <xsl:variable name="owl" select="'http://www.w3.org/2002/07/owl#'"/>
    <xsl:variable name="xsd" select="'http://www.w3.org/2001/XMLSchema#'"/>
    <xsl:variable name="skos" select="'http://www.w3.org/2004/02/skos/core#'"/>
    <xsl:variable name="foaf" select="'http://xmlns.com/foaf/0.1/'"/>
    <xsl:variable name="schema" select="'http://schema.org/'"/>
    <xsl:variable name="prov" select="'http://www.w3.org/ns/prov#'"/>
    <xsl:variable name="pso" select="'http://www.patexpert.org/ontologies/pso.owl#'"/>
    <xsl:variable name="pulo" select="'http://www.patexpert.org/ontologies/pulo.owl#'"/>
    <xsl:variable name="sumo" select="'http://www.owl-ontologies.com/sumo.owl#'"/>
    <xsl:variable name="pmo" select="'http://www.patexpert.org/ontologies/pmo.owl#'"/>

    <!--Adapted from https://github.com/csarven/sdmx-to-qb/blob/master/scripts/common.xsl -->
    <xsl:template name="langTextNode">
        <xsl:if test="@xml:lang">
            <xsl:copy-of select="@*[name() = 'xml:lang']"/>
        </xsl:if>

        <xsl:choose>
            <xsl:when test="@lang">
                <xsl:attribute name="xml:lang" select="lower-case(@lang)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$lang">
                    <xsl:attribute name="xml:lang" select="$lang"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:value-of select="normalize-space(text())"/>
    </xsl:template>


    <!--Copied from https://github.com/csarven/sdmx-to-qb/blob/master/scripts/common.xsl -->
    <xsl:template name="rdfDatatypeXSD">
        <xsl:param name="type"/>

        <xsl:attribute name="rdf:datatype"><xsl:text>http://www.w3.org/2001/XMLSchema#</xsl:text><xsl:value-of select="$type"/></xsl:attribute>
    </xsl:template>


    <!--Copied from https://github.com/csarven/sdmx-to-qb/blob/master/scripts/common.xsl -->
    <xsl:template name="provActivity">
        <xsl:param name="provUsedA"/>
        <xsl:param name="provUsedB"/>
        <xsl:param name="provGenerated"/>

        <xsl:variable name="now" select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')"/>

        <rdf:Description rdf:about="{$provenance}activity{$uriThingSeparator}{replace($now, '\D', '')}">
            <rdf:type rdf:resource="{$prov}Activity"/>
<!--dcterms:title-->
            <prov:startedAtTime rdf:datatype="{$xsd}dateTime"><xsl:value-of select="$now"/></prov:startedAtTime>
            <prov:wasAssociatedWith rdf:resource="{$creator}"/>
            <prov:used rdf:resource="{$provUsedA}"/>
            <xsl:if test="$provUsedB">
                <prov:used rdf:resource="{$provUsedB}"/>
            </xsl:if>
            <prov:used rdf:resource="{$xslDocument}"/>
            <prov:generated>
                <rdf:Description rdf:about="{$provGenerated}">
                    <prov:wasDerivedFrom rdf:resource="{$provUsedA}"/>
                </rdf:Description>
            </prov:generated>
        </rdf:Description>
    </xsl:template>

    <!--Copied from https://github.com/csarven/sdmx-to-qb/blob/master/scripts/common.xsl -->
    <xsl:function name="fn:now">
        <xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')"/>
    </xsl:function>


    <xsl:template name="dateNormalized">
        <xsl:param name="date"/>

        <xsl:analyze-string select="$date" regex="([0-9]{{4}})([0-9]{{2}})([0-9]{{2}})">
            <xsl:matching-substring>                
                <xsl:call-template name="rdfDatatypeXSD">
                    <xsl:with-param name="type" select="'date'"/>
                </xsl:call-template>

                <xsl:value-of select="regex-group(1)"/><xsl:text>-</xsl:text><xsl:value-of select="regex-group(2)"/><xsl:text>-</xsl:text><xsl:value-of select="regex-group(3)"/>
            </xsl:matching-substring>

            <xsl:non-matching-substring>
                <xsl:value-of select="$date"/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
	
	<!-- COMMON END -->
	
	
    <xsl:output encoding="utf-8" indent="yes" method="xml" omit-xml-declaration="no"/>

    <xsl:strip-space elements="*"/>

    <xsl:template match="/patent-document">
        <rdf:RDF>
            <rdf:Description rdf:about="{$creator}">
                <rdf:type rdf:resource="{$prov}Agent"/>
            </rdf:Description>

            <xsl:variable name="ucid" select="@ucid"/>

            <xsl:variable name="patentURI">
                <xsl:value-of select="$patent"/>
                <xsl:value-of select="$ucid"/>
            </xsl:variable>

            <xsl:call-template name="provActivity">
                <xsl:with-param name="provUsedA" select="resolve-uri(tokenize(document-uri(/), '/')[last()], $xmlDocumentBaseURI)"/>
                <xsl:with-param name="provGenerated" select="$patentURI"/>
            </xsl:call-template>

            <rdf:Description rdf:about="{$patentURI}">
                <rdf:type rdf:resource="{$sumo}Patent"/>

                <xsl:call-template name="generalParameterEntities"/>

                <xsl:call-template name="family-id">
                    <xsl:with-param name="ucid" select="$ucid" tunnel="yes"/>
                </xsl:call-template>
            </rdf:Description>

            <xsl:call-template name="bibliographic-data">
                <xsl:with-param name="ucid" select="$ucid" tunnel="yes"/>
            </xsl:call-template>
<!--            <xsl:apply-templates select="description"/>-->
<!--            <xsl:call-template name="claims">-->
<!--                <xsl:with-param name="patentURI" select="$patentURI" tunnel="yes"/>-->
<!--            </xsl:call-template>-->
<!--            <xsl:apply-templates select="drawings"/>-->
            <xsl:call-template name="copyright">
                <xsl:with-param name="ucid" select="$ucid" tunnel="yes"/>
            </xsl:call-template>
        </rdf:RDF>
    </xsl:template>

    <xsl:template name="bibliographic-data">
        <xsl:param name="ucid" tunnel="yes"/>

        <xsl:for-each select="bibliographic-data">
            <xsl:call-template name="publication-reference"/>
            <xsl:call-template name="application-reference"/>
            <xsl:call-template name="priority-claims"/>
<!--        <xsl:apply-templates select="dates-of-public-availability"/>-->
            <xsl:call-template name="technical-data"/>
            <xsl:call-template name="parties"/>
<!--        <xsl:apply-templates select="international-convention-data"/>-->
        </xsl:for-each>

    </xsl:template>


    <xsl:template name="publication-reference">
        <xsl:param name="ucid" tunnel="yes"/>

        <xsl:for-each select="publication-reference">
            <rdf:Description rdf:about="{$patent}{$ucid}">
                <dcterms:references>
                    <rdf:Description rdf:about="{$patent}{@ucid}/publication">
                        <rdf:type rdf:resource="{$pmo}IntellectualPropertyDocument"/>

                        <xsl:call-template name="generalParameterEntities"/>

                        <xsl:call-template name="document-id">
                            <xsl:with-param name="ucid" select="@ucid" tunnel="yes"/>
                        </xsl:call-template>
                    </rdf:Description>
                </dcterms:references>
            </rdf:Description>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="application-reference">
        <xsl:param name="ucid" tunnel="yes"/>

        <xsl:for-each select="application-reference">
            <rdf:Description rdf:about="{$patent}{$ucid}">
                <dcterms:references>
                    <rdf:Description rdf:about="{$patent}{@ucid}/application">
                        <rdf:type rdf:resource="{$pmo}IntellectualPropertyDocument"/>

                        <xsl:call-template name="generalParameterEntities"/>

                        <xsl:if test="@appl-type">
                            <property:appl-type><xsl:value-of select="@appl-type"/></property:appl-type>
                        </xsl:if>
                        <xsl:if test="@us-series-code">
                            <property:us-series-code><xsl:value-of select="@us-series-code"/></property:us-series-code>
                        </xsl:if>
                        <xsl:if test="@us-art-unit">
                            <property:us-art-unit><xsl:value-of select="@us-art-unit"/></property:us-art-unit>
                        </xsl:if>
                        <xsl:if test="@is-representative">
                            <property:is-representative><xsl:value-of select="@is-representative"/></property:is-representative>
                        </xsl:if>

                        <xsl:call-template name="document-id">
                            <xsl:with-param name="ucid" select="@ucid" tunnel="yes"/>
                        </xsl:call-template>
                    </rdf:Description>
                </dcterms:references>
            </rdf:Description>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="priority-claims">
        <xsl:param name="ucid" tunnel="yes"/>

        <xsl:variable name="id">
            <xsl:choose>
                <xsl:when test="date">
                    <xsl:value-of select="replace(normalize-space(date), '\s+', '')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="position()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
<!--
XXX: Skips priority-claims without @ucid
-->
        <xsl:for-each select="priority-claims/priority-claim[@ucid]">
            <rdf:Description rdf:about="{$patent}{$ucid}">
                <property:priority-claim>
                    <rdf:Description rdf:about="{$patent}{@ucid}/publication{$uriThingSeparator}{$id}">
<!--
XXX: Normally we don't really want to define other patents from here. In case this patent is not declared anywhere else, there is at least this type.
-->
                        <rdf:type rdf:resource="{$pmo}PatentPublication"/>
                    </rdf:Description>
                </property:priority-claim>
            </rdf:Description>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="document-id">
        <xsl:param name="ucid" tunnel="yes"/>

        <xsl:variable name="referenceType">
            <xsl:choose>
                <xsl:when test="local-name() = 'publication-reference'">
                    <xsl:value-of select="'publication'"/>
                </xsl:when>
                <xsl:when test="local-name() = 'application-reference'">
                    <xsl:value-of select="'application'"/>
                </xsl:when>
                <xsl:when test="local-name() = 'priority-claim'">
                    <xsl:value-of select="'priority-claim'"/>
                </xsl:when>
                <xsl:otherwise>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:for-each select="document-id">
            <dcterms:hasPart>
                <xsl:variable name="id">
                    <xsl:choose>
                        <xsl:when test="date">
                            <xsl:value-of select="replace(normalize-space(date), '\s+', '')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="position()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <rdf:Description rdf:about="{$patent}{$ucid}/{$referenceType}{$uriThingSeparator}{$id}">
                    <rdf:type rdf:resource="{$pmo}PatentPublication"/>

                    <dcterms:isPartOf rdf:resource="{$patent}{$ucid}/{$referenceType}"/>

                    <xsl:call-template name="generalParameterEntities"/>

                    <xsl:apply-templates select="@format"/>

                    <xsl:if test="country">
                        <property:filing-office rdf:resource="{$code}filing-office{$uriThingSeparator}{country}"/>
                    </xsl:if>

                    <xsl:if test="doc-number">
                        <xsl:choose>
                            <xsl:when test="$referenceType = 'publication'">
                                <pmo:publicationNumber><xsl:value-of select="doc-number"/></pmo:publicationNumber>
                            </xsl:when>
                            <xsl:when test="$referenceType = 'application'">
                                <pmo:applicationNumber><xsl:value-of select="doc-number"/></pmo:applicationNumber>
                            </xsl:when>
                            <xsl:otherwise>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>

                    <xsl:if test="string-length(kind) = 2">
                        <pmo:kindCode><xsl:value-of select="kind"/></pmo:kindCode>
                        
                        <xsl:if test="country = 'EP'">
                            <rdf:type rdf:resource="{$pso}{kind}Document"/>
                        </xsl:if>
                    </xsl:if>

                    <xsl:if test="date">
                        <pmo:dateOfPublication>
                            <xsl:call-template name="dateNormalized">
                                <xsl:with-param name="date" select="date"/>
                            </xsl:call-template>
                        </pmo:dateOfPublication>
                    </xsl:if>

                    <xsl:apply-templates select="lang"/>
                </rdf:Description>
            </dcterms:hasPart>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="@format">
        <pulo:fileFormat><xsl:value-of select="."/></pulo:fileFormat>
    </xsl:template>

    <xsl:template match="lang">
        <dcterms:language><xsl:value-of select="lower-case(.)"/></dcterms:language>
    </xsl:template>


<!--    <technical-data status="new">-->
<!--      <classification-ipc status="new">-->
<!--        <edition>7</edition>-->
<!--        <main-classification status="new">C07C  45/50</main-classification>-->
<!--        <further-classification status="new">C07F   9/145</further-classification>-->
    <xsl:template name="technical-data">
        <xsl:param name="ucid" tunnel="yes"/>

        <xsl:for-each select="technical-data">
            <xsl:apply-templates select="classification-ipc"/>

            <rdf:Description rdf:about="{$patent}{$ucid}">
                <xsl:apply-templates select="invention-title"/>
            </rdf:Description>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="classification-ipc">
        <xsl:param name="ucid" tunnel="yes"/>

        <rdf:Description rdf:about="{$patent}{$ucid}">
            <xsl:for-each select="*[name() = 'main-classification' or name() = 'further-classification']">
                <xsl:variable name="id" select="normalize-space(replace(., '\s+', ''))"/>
<!--
TODO: Differentiate between main-classification and further-classification
-->
                <pmo:classifiedAs>
<!--
XXX: Maybe switch to a code list
-->
                    <rdf:Description rdf:about="{$concept}{$id}">
                        <xsl:call-template name="generalParameterEntities"/>

                        <rdf:type rdf:resource="{$pmo}PatentClassificationCategory"/>
                        <rdf:type rdf:resource="{$pmo}IPCCategory"/>
                        <rdf:type rdf:resource="{$skos}Concept"/>

                        <pmo:classifiedPatent rdf:resource="{$patent}{$ucid}"/>

                        <skos:inScheme rdf:resource="{$concept}ipc"/>
                        <skos:topConceptOf>
                            <rdf:Description rdf:about="{$concept}ipc">
                                <skos:hasTopConcept rdf:resource="{$concept}{$id}"/>
                                <pmo:classifiedPatent rdf:resource="{$concept}{$id}"/>
                            </rdf:Description>
                        </skos:topConceptOf>

                        <pmo:classificationCode><xsl:value-of select="$id"/></pmo:classificationCode>
                        <skos:notation><xsl:value-of select="$id"/></skos:notation>
                    </rdf:Description>
                </pmo:classifiedAs>
            </xsl:for-each>
        </rdf:Description>
    </xsl:template>

    <xsl:template match="invention-title">
        <dcterms:title><xsl:call-template name="langTextNode"/></dcterms:title>
    </xsl:template>


    <xsl:template name="parties">
        <xsl:for-each select="parties">
            <xsl:apply-templates select="applicants/applicant"/>
            <xsl:apply-templates select="inventors/inventor"/>
            <xsl:apply-templates select="assignees/assignee"/>
            <xsl:apply-templates select="agents/agent"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="applicants/applicant">
        <xsl:call-template name="party-members"/>
    </xsl:template>

    <xsl:template match="inventors/inventor">
        <xsl:call-template name="party-members"/>
    </xsl:template>

    <xsl:template match="assignees/assignee">
        <xsl:call-template name="party-members"/>
    </xsl:template>

    <xsl:template match="agents/agent">
        <xsl:call-template name="party-members"/>
    </xsl:template>

    <xsl:template name="party-members">
        <xsl:param name="ucid" tunnel="yes"/>

        <xsl:variable name="party-type" select="local-name()"/>
        <xsl:variable name="id" select="@mxw-id"/>

        <xsl:variable name="party-type-property">
            <xsl:choose>
                <xsl:when test="local-name() = 'applicant' or
                                local-name() = 'inventor' or
                                local-name() = 'assignee'
                                ">
                    <xsl:value-of select="concat('pmo:', $party-type)"/>
                </xsl:when>
                <xsl:when test="local-name() = 'agent'">
                    <xsl:value-of select="'property:agent'"/>
                </xsl:when>
                <xsl:otherwise>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <rdf:Description rdf:about="{$patent}{$ucid}">
            <xsl:for-each select="addressbook">
                <xsl:element name="{$party-type-property}">
                    <xsl:call-template name="addressbook">
                        <xsl:with-param name="id" select="$id"/>
                        <xsl:with-param name="party-type" select="$party-type"/>
                    </xsl:call-template>
                </xsl:element>
            </xsl:for-each>
        </rdf:Description>
    </xsl:template>

    <xsl:template name="addressbook">
        <xsl:param name="ucid" tunnel="yes"/>
        <xsl:param name="id"/>
        <xsl:param name="party-type"/>

<!--
XXX: Perhaps switch to blank nodes instead
-->
        <rdf:Description rdf:about="urn:uuid:{uuid:randomUUID()}">
            <xsl:choose>
                <xsl:when test="$party-type = 'applicant'">
                    <rdf:type rdf:resource="{$sumo}CognitiveAgent"/>
                    <rdf:type rdf:resource="{$foaf}Organization"/>
                    <pmo:applicantOf rdf:resource="{$patent}{$ucid}"/>
                </xsl:when>
                <xsl:when test="$party-type = 'inventor'">
                    <rdf:type rdf:resource="{$sumo}Human"/>
                    <rdf:type rdf:resource="{$foaf}Person"/>
                    <pmo:inventorOf rdf:resource="{$patent}{$ucid}"/>
                </xsl:when>
                <xsl:when test="$party-type = 'assignee'">
                    <rdf:type rdf:resource="{$sumo}CognitiveAgent"/>
                    <rdf:type rdf:resource="{$foaf}Organization"/>
                    <pmo:assigneeOf rdf:resource="{$patent}{$ucid}"/>
                </xsl:when>
                <xsl:when test="$party-type = 'agent'">
                    <rdf:type rdf:resource="{$sumo}Agent"/>
                    <rdf:type rdf:resource="{$foaf}Agent"/>
                    <property:agentOf rdf:resource="{$patent}{$ucid}"/>
                </xsl:when>
                <xsl:otherwise>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:choose>
                <xsl:when test="name">
                    <foaf:name><xsl:value-of select="name"/></foaf:name>
                </xsl:when>
                <xsl:when test="prefix or last-name or orgname">
                    <xsl:if test="prefix">
                        <foaf:honorificPrefix><xsl:value-of select="prefix"/></foaf:honorificPrefix>
                    </xsl:if>
                    <xsl:if test="last-name">
                        <foaf:lastName><xsl:value-of select="last-name"/></foaf:lastName>
                    </xsl:if>
                    <xsl:if test="orgname">
                        <foaf:name><xsl:value-of select="orgname"/></foaf:name>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:if test="first-name">
                <foaf:firstName><xsl:value-of select="first-name"/></foaf:firstName>
            </xsl:if>

            <xsl:if test="middle-name">
            </xsl:if>

            <xsl:if test="suffix">
                <foaf:honorificSuffix><xsl:value-of select="suffix"/></foaf:honorificSuffix>
            </xsl:if>

            <xsl:if test="iid">
            </xsl:if>

            <xsl:if test="role">
                <foaf:title><xsl:value-of select="role"/></foaf:title>
            </xsl:if>

            <xsl:if test="orgname">
                <foaf:name><xsl:value-of select="orgname"/></foaf:name>
            </xsl:if>

            <xsl:if test="department">
            </xsl:if>

            <xsl:if test="synonym">
            </xsl:if>

            <xsl:if test="registered-number">
                <property:registered-number><xsl:value-of select="registered-number"/></property:registered-number>
            </xsl:if>

            <xsl:apply-templates select="address"/>

            <xsl:apply-templates select="phone"/>
            <xsl:apply-templates select="fax"/>
            <xsl:apply-templates select="email"/>
            <xsl:apply-templates select="url"/>
            <xsl:apply-templates select="ead"/>
        </rdf:Description>
    </xsl:template>

    <xsl:template match="phone">
        <foaf:phone rdf:resource="tel:{normalize-space(phone)}"/>
    </xsl:template>
    <xsl:template match="fax">
        <schema:faxNumber><xsl:value-of select="fax"/></schema:faxNumber>
    </xsl:template>
    <xsl:template match="email">
        <foaf:mbox rdf:resource="mailto:{normalize-space(email)}"/>
    </xsl:template>
    <xsl:template match="url">
        <foaf:page rdf:resource="{normalize-space(url)}"/>
    </xsl:template>
    <xsl:template match="ead">
        <property:ead><xsl:value-of select="ead"/></property:ead>
    </xsl:template>

    <xsl:template match="address">
        <schema:address>
            <rdf:Description>
                <rdf:type rdf:resource="{$schema}PostalAddress"/>
                <xsl:if test="address-1">
                    <schema:streetAddress><xsl:value-of select="address1"/></schema:streetAddress>
                </xsl:if>
                <xsl:if test="address-2">
                    <schema:streetAddress><xsl:value-of select="address2"/></schema:streetAddress>
                </xsl:if>
                <xsl:if test="address-3">
                    <schema:streetAddress><xsl:value-of select="address3"/></schema:streetAddress>
                </xsl:if>
                <xsl:if test="mailcode">
                </xsl:if>
                <xsl:if test="pobox">
                    <schema:postOfficeBoxNumber><xsl:value-of select="pobox"/></schema:postOfficeBoxNumber>
                </xsl:if>
                <xsl:if test="room">
                </xsl:if>
                <xsl:if test="address-floor">
                </xsl:if>
                <xsl:if test="building">
                </xsl:if>
                <xsl:if test="street">
                    <schema:streetAddress><xsl:value-of select="street"/></schema:streetAddress>
                </xsl:if>
                <xsl:if test="city">
                    <schema:addressLocality><xsl:value-of select="city"/></schema:addressLocality>
                </xsl:if>
                <xsl:if test="state">
                    <schema:addressRegion><xsl:value-of select="state"/></schema:addressRegion>
                </xsl:if>
                <xsl:if test="postcode">
                    <schema:postalCode><xsl:value-of select="postcode"/></schema:postalCode>
                </xsl:if>
                <xsl:if test="country">
                    <schema:addressCountry rdf:resource="{$code}country{$uriThingSeparator}{normalize-space(country)}"/>
                </xsl:if>
            </rdf:Description>
        </schema:address>
    </xsl:template>


    <xsl:template name="generalParameterEntities">
        <xsl:apply-templates select="@id"/>

<!--        <xsl:apply-templates selet="@mxw-id"/>-->

        <xsl:apply-templates select="@status"/>

<!--        <xsl:apply-templates selet="@load-source"/>-->

<!--        <xsl:apply-templates selet="@ref-ucid"/>-->
    </xsl:template>

    <xsl:template match="@id">
        <dcterms:identifier><xsl:value-of select="."/></dcterms:identifier>
    </xsl:template>

    <xsl:template match="@status">
        <property:status><xsl:value-of select="."/></property:status>
    </xsl:template>

    <xsl:template name="family-id">
        <xsl:param name="ucid" tunnel="yes"/>

        <pmo:patentFamily>
            <rdf:Description rdf:about="{$patentFamily}{@family-id}">
                <rdf:type rdf:resource="{$pmo}PatentFamily"/>
                <rdf:type rdf:resource="{$skos}Collection"/>
<!--
TODO:
Add members
-->
                <skos:notation><xsl:value-of select="@family-id"/></skos:notation>
            </rdf:Description>
        </pmo:patentFamily>
    </xsl:template>

    <xsl:template match="description">
    </xsl:template>

<!--    <xsl:template name="claims">-->
<!--        <xsl:param name="patentURI" tunnel="yes"/>-->

<!--        <xsl:for-each select="claims">-->
<!--            <xsl:variable name="lang" select="@lang"/>-->

<!--            <xsl:for-each select="claim">-->
<!--                <rdf:Description rdf:about="{$claim}{@num}">-->
<!--                    <rdf:type rdf:resource="{$pso}Claim"/>-->
<!--                    <rdf:type rdf:resource="{$skos}Concept"/>-->

<!--                    <skos:definition xml:lang="{lower-case($lang)}"><xsl:value-of select="claim-text/normalize-space(text())"/></skos:definition>	-->
<!--                </rdf:Description>-->
<!--            </xsl:for-each>-->
<!--        </xsl:for-each>-->
<!--    </xsl:template>-->


    <xsl:template match="drawings">
    </xsl:template>

    <xsl:template name="copyright">
        <xsl:param name="ucid" tunnel="yes"/>

        <xsl:for-each select="copyright">
            <rdf:Description rdf:about="{$patent}{$ucid}">
                <dcterms:license><xsl:value-of select="normalize-space(.)"/></dcterms:license>
            </rdf:Description>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>