<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!-- The language we are interested in -->
  <xsl:param name="profile.lang" select="'en'"/>

  <!-- Generate DocBook instance with correct DOCTYPE -->
  <xsl:output method="xml" encoding="utf-8"
    doctype-public="-//OASIS//DTD DocBook XML V4.5//EN"
    doctype-system="http://www.docbook.org/xml/4.5/docbookx.dtd"/>

  <!-- The root of all evil -->
  <xsl:template match="/">
    <xsl:apply-templates mode="profile"/>
  </xsl:template>

  <!-- Drop comments -->
  <!--
  <xsl:template match="comment()" mode="profile"></xsl:template>
  -->

  <!-- Extract matching nodes -->
  <xsl:template match="*" mode="profile">
    <xsl:variable name="lang.match">
      <xsl:choose>
        <!-- no 'lang' attribute always matches, since some parent node matched -->
        <xsl:when test="not(@lang)">1</xsl:when>
        <!-- test existing 'lang' attribute lang -->
        <xsl:when test="contains(concat(';', @lang, ';'),
                                 concat(';', $profile.lang, ';'))">
          <xsl:value-of select="1"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="$lang.match = '1'">
      <xsl:copy>
        <xsl:copy-of select="@*[local-name() != 'lang']"/>
        <xsl:apply-templates select="node()" mode="profile"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
