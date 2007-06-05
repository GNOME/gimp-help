<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:doc="http://nwalsh.com/xsl/documentation/1.0" exclude-result-prefixes="doc" version="1.0">

  <xsl:output method="xml" encoding="UTF-8" indent="yes" />

  <xsl:template match="/">
    <gimp-help>
      <xsl:apply-templates select="*"/>
    </gimp-help>
  </xsl:template>

  <xsl:template match="/div/div[@targetptr='help-missing']">
    <help-missing>
      <xsl:attribute name="ref">
        <xsl:value-of select="@href" />
      </xsl:attribute>
    </help-missing>
  </xsl:template>

  <xsl:template match="div|ttl">
    <xsl:choose>
      <xsl:when test="@targetptr">
        <help-item>
          <xsl:attribute name="id">
            <xsl:value-of select="@targetptr"/>
          </xsl:attribute>
          <xsl:attribute name="ref">
            <xsl:value-of select="@href"/>
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:choose>
              <xsl:when test="@number=''">
                <xsl:value-of select="normalize-space(ttl)" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat(@number, '. ', normalize-space(ttl))" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:attribute name="parent">
            <xsl:value-of select="../@targetptr" />
          </xsl:attribute>
        </help-item>
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <xsl:template match="*">
  </xsl:template>

</xsl:stylesheet>
