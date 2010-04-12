<?xml version="1.0" encoding="UTF-8"?>

<!--  simple XSL transformation to create a text version from authors.xml  -->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dc="http://purl.org/dc/elements/1.1/">

  <!-- template "lang.split" -->
  <xsl:import href="authors_common.xsl" />

  <xsl:output method="text" />

  <xsl:template match="/dc:gimp-authors">
    <xsl:text>This file is generated from authors.xml, do not edit it directly.
</xsl:text>
    <xsl:text>
Active Contributors
===================
</xsl:text>
    <xsl:apply-templates select="//dc:creator" />

    <xsl:text>

Contributors in the past
========================

Writers
-------
</xsl:text>
    <xsl:apply-templates select="//dc:contributor[contains(@role, 'documenter')]" />

    <xsl:text>
Graphics, Stylesheets
---------------------
</xsl:text>
    <xsl:apply-templates select="//dc:contributor[contains(@role, 'artist')]" />

    <xsl:text>
Buildsystem, Technical Contributions
------------------------------------
</xsl:text>
    <xsl:apply-templates select="//dc:contributor[contains(@role, 'technican')]">
      <xsl:with-param name="print_language" select="0" />
    </xsl:apply-templates>

    <xsl:text>
</xsl:text>
  </xsl:template>
 
  <!-- Print creator/contributor and (optionally) his/her languages -->
  <xsl:template match="//dc:creator | //dc:contributor">
    <xsl:param name="print_language">1</xsl:param>
    <xsl:value-of select="."/>
    <xsl:if test="@lang != '' and $print_language != 0">
      <xsl:text> (</xsl:text>
      <xsl:call-template name="lang.split">
        <xsl:with-param name="lang" select="@lang" />
      </xsl:call-template>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:text>
</xsl:text>
  </xsl:template>

</xsl:stylesheet>
