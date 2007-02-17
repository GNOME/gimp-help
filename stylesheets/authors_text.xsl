<?xml version="1.0" encoding="UTF-8"?>

<!--  simple XSL transformation to create a text version from authors.xml  -->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dc="http://purl.org/dc/elements/1.1/">

  <xsl:output method="text" />

  <xsl:template match="/dc:gimp-authors">
    <xsl:text>This file is generated from authors.xml, do not edit it directly.
    </xsl:text>
    <xsl:text>
    Active content writers:
    =======================
    </xsl:text>
    <xsl:apply-templates select="//dc:creator" />
    
    <xsl:text>
    Contributors:
    =============
    </xsl:text>
    <xsl:apply-templates select="//dc:contributor" />
  </xsl:template>
 
  <!-- two simple transformations -->
  <!-- they should be enhanced though -->
  <xsl:template match="//dc:creator">
    <xsl:apply-templates match="." />
    <xsl:text> (</xsl:text>
    <xsl:value-of select="@lang" />
    <xsl:text>)
    </xsl:text>
  </xsl:template>

  <xsl:template match="//dc:contributor">
    <xsl:apply-templates match="." />
    <xsl:text>
    </xsl:text>
  </xsl:template>
</xsl:stylesheet>
