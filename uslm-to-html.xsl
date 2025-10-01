<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:uslm="http://schemas.gpo.gov/xml/uslm"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="uslm dc html">
    
    <xsl:output method="html" 
                indent="yes" 
                encoding="UTF-8"/>
    
    <!-- Root template - creates HTML document structure -->
    <xsl:template match="/">
        <html lang="{/*/@xml:lang}">
            <head>
                <meta charset="UTF-8"/>
                <title>
                    <xsl:choose>
                        <xsl:when test="//dc:title">
                            <xsl:value-of select="//dc:title"/>
                        </xsl:when>
                        <xsl:otherwise>USLM Document</xsl:otherwise>
                    </xsl:choose>
                </title>
                <link rel="stylesheet" type="text/css" href="uslm-html.css"/>
            </head>
            <body>
                <xsl:apply-templates/>
            </body>
        </html>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- ELEMENT TYPE MAPPINGS                                              -->
    <!-- ================================================================== -->
    
    <!-- Rule 1: Marker, inline, or string types → <span> elements -->
    <xsl:template match="uslm:marker | uslm:inline | uslm:br | uslm:img | uslm:center | uslm:fillIn | 
                         uslm:checkBox | uslm:b | uslm:i | uslm:qualifier | uslm:sub | uslm:sup | 
                         uslm:headingText | uslm:span | uslm:shortTitle | uslm:term | uslm:entity |
                         uslm:ref | uslm:date | uslm:amendingAction">
        <span>
            <xsl:call-template name="process-attributes"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- Rule 2: Block or content types → <div> elements -->
    <xsl:template match="uslm:block | uslm:content | uslm:quotedContent | uslm:fragment | 
                         uslm:signatures">
        <div>
            <xsl:call-template name="process-attributes"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- Rule 3: Layout elements → <table> elements -->
    <xsl:template match="uslm:layout">
        <table>
            <xsl:call-template name="process-attributes"/>
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    
    <!-- Layout children → <tr> elements, except columns -->
    <xsl:template match="uslm:layout/*[not(self::uslm:column)]">
        <tr>
            <xsl:call-template name="process-attributes"/>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>
    
    <!-- Columns within layout → single <tr> with <td> cells -->
    <xsl:template match="uslm:layout[uslm:column]">
        <table>
            <xsl:call-template name="process-attributes"/>
            <tr>
                <xsl:for-each select="uslm:column">
                    <td>
                        <xsl:call-template name="process-attributes"/>
                        <xsl:apply-templates/>
                    </td>
                </xsl:for-each>
            </tr>
        </table>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- SPECIFIC USLM ELEMENTS (mapped to div by default)                 -->
    <!-- ================================================================== -->
    
    <!-- Document structure elements -->
    <xsl:template match="uslm:bill | uslm:resolution | uslm:pLaw | uslm:statutesAtLarge | 
                         uslm:statuteCompilation | uslm:cfrDoc | uslm:frDoc | uslm:uscDoc | 
                         uslm:engrossedAmendment | uslm:amendment">
        <div>
            <xsl:call-template name="process-attributes"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- Major sections -->
    <xsl:template match="uslm:meta | uslm:preface | uslm:main | uslm:signatures | uslm:appendix | 
                         uslm:section | uslm:subsection | uslm:paragraph | uslm:subparagraph | 
                         uslm:clause | uslm:subclause | uslm:item | uslm:subitem | uslm:level |
                         uslm:chapeau | uslm:longTitle | uslm:enactingFormula | uslm:attestation |
                         uslm:endorsement">
        <div>
            <xsl:call-template name="process-attributes"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- Text content elements -->
    <xsl:template match="uslm:text | uslm:heading | uslm:subheading | uslm:num | uslm:docTitle | 
                         uslm:officialTitle | uslm:slugLine | uslm:congress | uslm:session | 
                         uslm:docNumber | uslm:currentChamber | uslm:actionDescription">
        <div>
            <xsl:call-template name="process-attributes"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- Metadata elements (usually hidden) -->
    <xsl:template match="dc:*">
        <div style="display: none;">
            <xsl:call-template name="process-attributes"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- ATTRIBUTE PROCESSING                                               -->
    <!-- ================================================================== -->
    
    <xsl:template name="process-attributes">
        <!-- Rule 4: @role attribute handling -->
        <xsl:choose>
            <xsl:when test="@role">
                <xsl:attribute name="role">
                    <xsl:value-of select="@role"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="role">
                    <xsl:value-of select="local-name()"/>
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
        
        <!-- Rule 5: @class attribute composition -->
        <xsl:attribute name="class">
            <xsl:value-of select="local-name()"/>
            <xsl:if test="@role">
                <xsl:text>_</xsl:text>
                <xsl:value-of select="@role"/>
            </xsl:if>
            <xsl:if test="@class">
                <xsl:text> </xsl:text>
                <xsl:value-of select="@class"/>
            </xsl:if>
        </xsl:attribute>
        
        <!-- Rule 6: @xml:lang → @lang -->
        <xsl:if test="@xml:lang">
            <xsl:attribute name="lang">
                <xsl:value-of select="@xml:lang"/>
            </xsl:attribute>
        </xsl:if>
        
        <!-- Rule 7: Direct attribute mappings -->
        <xsl:copy-of select="@style | @id | @href | @idref | @src | @alt | @colspan | @rowspan"/>
        
        <!-- Rule 8: Other attributes with data-uslm- prefix -->
        <xsl:for-each select="@*[not(local-name() = 'role' or local-name() = 'class' or local-name() = 'style' or 
                                     local-name() = 'id' or local-name() = 'href' or local-name() = 'idref' or 
                                     local-name() = 'src' or local-name() = 'alt' or local-name() = 'colspan' or 
                                     local-name() = 'rowspan') and not(namespace-uri() = 'http://www.w3.org/XML/1998/namespace')]">
            <xsl:attribute name="data-uslm-{local-name()}">
                <xsl:value-of select="."/>
            </xsl:attribute>
        </xsl:for-each>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- SPECIAL CASES                                                      -->
    <!-- ================================================================== -->

    <!-- Notes with role="annotations" - add Annotations heading -->
    <xsl:template match="uslm:notes[@role='annotations']">
        <div>
            <xsl:call-template name="process-attributes"/>
            <h4 class="annotations-heading">Annotations</h4>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- sourceCredit - add History heading -->
    <xsl:template match="uslm:sourceCredit">
        <div>
            <xsl:call-template name="process-attributes"/>
            <div class="heading">History</div>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- ================================================================== -->
    <!-- DEFAULT TEMPLATE                                                   -->
    <!-- ================================================================== -->

    <!-- Default template for any unmatched elements - treat as div -->
    <xsl:template match="*">
        <div>
            <xsl:call-template name="process-attributes"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- Text nodes pass through unchanged -->
    <xsl:template match="text()">
        <xsl:copy/>
    </xsl:template>
    
    <!-- Comments pass through unchanged -->
    <xsl:template match="comment()">
        <xsl:copy/>
    </xsl:template>
    
</xsl:stylesheet>
