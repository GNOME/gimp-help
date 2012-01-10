<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:output method="xml" encoding="UTF-8" indent="yes" />

  <!-- include template "gimp-help.help-id.sort" -->
  <xsl:include href="getsortkey.xsl" />

  <xsl:param name="obj.missing.title.warning" select="0"/>
  <xsl:param name="obj.title.debug"           select="0"/>

  <xsl:template match="/">
    <gimp-help>
      <xsl:apply-templates select="*" />
    </gimp-help>
  </xsl:template>

  <xsl:template match="/div/div[@targetptr='help-missing']">
    <help-missing>
      <xsl:attribute name="ref">
        <xsl:value-of select="@href" />
      </xsl:attribute>
    </help-missing>
  </xsl:template>

  <xsl:template match="div">
    <xsl:choose>
      <xsl:when test="@targetptr">
        <help-item>
          <xsl:attribute name="id">
            <xsl:value-of select="@targetptr" />
          </xsl:attribute>
          <xsl:attribute name="ref">
            <xsl:value-of select="@href" />
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:choose>
              <xsl:when test="@number=''">
                <xsl:value-of select="normalize-space(ttl)" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of
                  select="concat(@number, '. ', normalize-space(ttl))" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:attribute name="parent">
            <xsl:value-of select="ancestor::div[@targetptr][1]/@targetptr"/>
          </xsl:attribute>
          <xsl:attribute name="sort">
            <xsl:call-template name="gimp-help.help-id.sort"/>
          </xsl:attribute>
        </help-item>
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates select="*" />
  </xsl:template>

  <xsl:template match="obj">
    <xsl:if test="@targetptr
              and not(@element = 'footnote')
              and not(@element = 'figure')
              and (starts-with(@targetptr, 'gimp-') or
                   starts-with(@targetptr, 'plug-in-') or
                   starts-with(@targetptr, 'script-fu-'))">
      <help-item>
        <xsl:attribute name="id">
          <xsl:value-of select="@targetptr" />
        </xsl:attribute>
        <xsl:attribute name="ref">
          <xsl:value-of select="@href" />
        </xsl:attribute>
        <xsl:attribute name="title">
          <xsl:choose>
            <xsl:when test="not(contains(ttl, '???')) and normalize-space(ttl) != ''">
              <!-- case 1: "obj" has "ttl" (title) attribute -->
              <xsl:value-of select="concat('(', normalize-space(ttl), ')')" />
              <xsl:if test="$obj.title.debug = 1">
                <xsl:message>
                  <xsl:text>Debug: GIMP help browser title (ttl) = </xsl:text>
                  <xsl:value-of select="concat('(', normalize-space(ttl), ')')" />
                </xsl:message>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise> <!-- "obj" without "ttl" attribute -->
              <xsl:variable name="xreftext.normalized">
                <xsl:if test="not(contains(xreftext,'???'))">
                  <xsl:value-of select="normalize-space(xreftext)"/>
                </xsl:if>
              </xsl:variable>
              <xsl:choose>
                <xsl:when test="$xreftext.normalized != ''">
                  <!-- case 3: "obj" has "xreftext" attribute -->
                  <xsl:value-of select="concat('(', $xreftext.normalized, ')')" />
                  <xsl:if test="$obj.title.debug = 1">
                    <xsl:message>
                      <xsl:text>Debug: GIMP help browser title (xreftext) = </xsl:text>
                      <xsl:value-of select="concat('(', $xreftext.normalized, ')')" />
                    </xsl:message>
                  </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                  <!-- case 4: "obj" has no "ttl" or "xreftext" attribute -->
                  <xsl:value-of select="concat('FIXME TITLE: ', @targetptr)" />
                  <xsl:if test="$obj.missing.title.warning = 1">
                    <xsl:message>
                      <xsl:text>Warning: </xsl:text>
                      <xsl:text>No GIMP help browser title for </xsl:text>
                      <xsl:value-of select="@element" />
                      <xsl:text> </xsl:text>
                      <xsl:value-of select="@targetptr" />
                    </xsl:message>
                  </xsl:if>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise> <!--end of "obj without ttl"-->
          </xsl:choose>
        </xsl:attribute> <!--title-->
        <xsl:attribute name="parent">
          <xsl:value-of select="ancestor::*[@targetptr][1]/@targetptr"/>
        </xsl:attribute>
        <xsl:attribute name="sort">
          <xsl:call-template name="gimp-help.help-id.sort"/>
        </xsl:attribute>
      </help-item>
    </xsl:if>
    <xsl:apply-templates select="*" />
  </xsl:template>

  <xsl:template match="*"></xsl:template>

</xsl:stylesheet>
