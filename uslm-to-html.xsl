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
                         uslm:engrossedAmendment | uslm:amendment | uslm:lawDoc">
        <div>
            <xsl:call-template name="process-attributes"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- Main element - add document-wide ToC -->
    <xsl:template match="uslm:main">
        <div>
            <xsl:call-template name="process-attributes"/>

            <!-- Generate document-wide table of contents -->
            <xsl:if test=".//uslm:title | .//uslm:chapter | .//uslm:section[not(ancestor::uslm:title or ancestor::uslm:chapter)]">
                <nav class="document-toc">
                    <h2 class="toc-heading">Table of Contents</h2>
                    <ul class="toc-list">
                        <xsl:call-template name="generate-document-toc"/>
                    </ul>
                </nav>
            </xsl:if>

            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- Title element - add chapter-level ToC -->
    <xsl:template match="uslm:title">
        <div>
            <xsl:call-template name="process-attributes"/>

            <!-- Output title num and heading first -->
            <xsl:apply-templates select="uslm:num | uslm:heading"/>

            <!-- Generate table of contents for chapters under this title -->
            <xsl:if test="uslm:chapter | uslm:section">
                <nav class="title-toc">
                    <h3 class="toc-heading">Chapters</h3>
                    <ul class="toc-list">
                        <!-- List all direct child chapters -->
                        <xsl:for-each select="uslm:chapter">
                            <xsl:call-template name="generate-toc-entry"/>
                        </xsl:for-each>
                        <!-- List any direct child sections (if not in chapters) -->
                        <xsl:for-each select="uslm:section">
                            <xsl:call-template name="generate-toc-entry"/>
                        </xsl:for-each>
                    </ul>
                </nav>
            </xsl:if>

            <!-- Process remaining children -->
            <xsl:apply-templates select="*[not(self::uslm:num or self::uslm:heading)]"/>
        </div>
    </xsl:template>

    <!-- Chapter element - add section-level ToC -->
    <xsl:template match="uslm:chapter">
        <div>
            <xsl:call-template name="process-attributes"/>

            <!-- Output chapter num and heading first -->
            <xsl:apply-templates select="uslm:num | uslm:heading"/>

            <!-- Generate section-level table of contents -->
            <xsl:if test="uslm:section">
                <nav class="chapter-toc">
                    <h4 class="toc-heading">Sections</h4>
                    <ul class="toc-list">
                        <xsl:for-each select="uslm:section">
                            <xsl:call-template name="generate-toc-entry"/>
                        </xsl:for-each>
                    </ul>
                </nav>
            </xsl:if>

            <!-- Process remaining children -->
            <xsl:apply-templates select="*[not(self::uslm:num or self::uslm:heading)]"/>
        </div>
    </xsl:template>

    <!-- Other major sections -->
    <xsl:template match="uslm:meta | uslm:preface | uslm:signatures | uslm:appendix |
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
    <!-- TABLE OF CONTENTS GENERATION                                       -->
    <!-- ================================================================== -->

    <!-- Generate document-wide table of contents -->
    <xsl:template name="generate-document-toc">
        <!-- Process titles - show chapters as nested items -->
        <xsl:for-each select="uslm:title">
            <li class="toc-item toc-title">
                <xsl:call-template name="generate-toc-link"/>

                <!-- Nested chapters within this title -->
                <xsl:if test="uslm:chapter">
                    <ul class="toc-list toc-nested">
                        <xsl:for-each select="uslm:chapter">
                            <li class="toc-item toc-chapter">
                                <xsl:call-template name="generate-toc-link"/>
                            </li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>

                <!-- Direct sections under title (not in chapters) -->
                <xsl:if test="uslm:section[not(ancestor::uslm:chapter)]">
                    <ul class="toc-list toc-nested">
                        <xsl:for-each select="uslm:section[not(ancestor::uslm:chapter)]">
                            <li class="toc-item toc-section">
                                <xsl:call-template name="generate-toc-link"/>
                            </li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
            </li>
        </xsl:for-each>

        <!-- Process chapters not within titles (direct children of main) -->
        <xsl:for-each select="uslm:chapter">
            <li class="toc-item toc-chapter">
                <xsl:call-template name="generate-toc-link"/>
            </li>
        </xsl:for-each>

        <!-- Process top-level sections (direct children of main, not in titles or chapters) -->
        <xsl:for-each select="uslm:section">
            <li class="toc-item toc-section">
                <xsl:call-template name="generate-toc-link"/>
            </li>
        </xsl:for-each>
    </xsl:template>

    <!-- Generate a single ToC entry (called within for-each) -->
    <xsl:template name="generate-toc-entry">
        <li class="toc-item toc-{local-name()}">
            <xsl:call-template name="generate-toc-link"/>
        </li>
    </xsl:template>

    <!-- Generate ToC link with number and heading -->
    <xsl:template name="generate-toc-link">
        <xsl:choose>
            <xsl:when test="@id">
                <a href="#{@id}" class="toc-link">
                    <xsl:call-template name="toc-text"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <span class="toc-link">
                    <xsl:call-template name="toc-text"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Extract text for ToC entry -->
    <xsl:template name="toc-text">
        <xsl:if test="uslm:num">
            <span class="toc-num">
                <xsl:value-of select="uslm:num"/>
            </span>
        </xsl:if>
        <xsl:if test="uslm:heading">
            <span class="toc-heading-text">
                <xsl:value-of select="uslm:heading"/>
            </span>
        </xsl:if>
    </xsl:template>

    <!-- ================================================================== -->
    <!-- SPECIAL CASES                                                      -->
    <!-- ================================================================== -->

    <!-- Notes with role="annotations" - add Annotations heading -->
    <xsl:template match="uslm:notes[@role='annotations']">
        <!-- First, output any sourceCredit elements (History section) -->
        <xsl:apply-templates select="uslm:sourceCredit"/>

        <!-- Then output the Annotations section with remaining content (only if content exists) -->
        <xsl:choose>
            <xsl:when test="*[not(self::uslm:sourceCredit)]">
                <div>
                    <xsl:call-template name="process-attributes"/>
                    <h4 class="annotations-heading">Annotations</h4>
                    <xsl:apply-templates select="*[not(self::uslm:sourceCredit)]"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div>
                    <xsl:call-template name="process-attributes"/>
                    <h4 class="annotations-heading">(No annotations)</h4>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- sourceCredit - add History heading -->
    <xsl:template match="uslm:sourceCredit">
        <div>
            <xsl:call-template name="process-attributes"/>
            <div class="heading">History</div>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- Section num - add colon after number -->
    <xsl:template match="uslm:section/uslm:num">
        <div>
            <xsl:call-template name="process-attributes"/>
            <xsl:apply-templates/>
            <xsl:text>:</xsl:text>
        </div>
    </xsl:template>

    <!-- Title and chapter heading - add typographical quotes -->
    <xsl:template match="uslm:title/uslm:heading | uslm:chapter/uslm:heading">
        <div>
            <xsl:call-template name="process-attributes"/>
            <xsl:text>“</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>”</xsl:text>
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
