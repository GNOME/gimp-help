<?xml version="1.0" encoding="UTF-8"?>

<!--  simple XSL transformation to create a text version from authors.xml  -->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dc="http://purl.org/dc/elements/1.1/">

  <!-- template "lang.split" -->
  <xsl:import href="authors_common.xsl" />

  <xsl:output method="text" />

  <xsl:param name="roles">documenter translator artist technican</xsl:param>
  <xsl:param name="print.roles.with.lang">translator</xsl:param>

  <xsl:template match="/dc:gimp-authors">
    <xsl:text>This file is generated from authors.xml, do not edit it directly.

GIMP User Manual Contributors
=============================</xsl:text>
    <xsl:call-template name="print.listentry">
      <xsl:with-param name="roles">
        <xsl:value-of select="normalize-space($roles)"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <!-- ============================================================= -->
  <xsl:template name="print.listentry">
  <!-- ============================================================= -->
    <!-- parameter: space-separated list of roles -->
    <xsl:param name="roles" select="''"/>
    <xsl:variable name="role">
      <xsl:choose>
        <xsl:when test="contains($roles,' ')">
          <xsl:value-of select="substring-before($roles,' ')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$roles"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$role != ''">
      <xsl:variable name="name" select="concat($role,'s')"/>
      <xsl:choose>
        <xsl:when test="$name = 'documenters'">
          <xsl:text>

Documentation
-------------</xsl:text>
        </xsl:when>
        <xsl:when test="$name = 'translators'">
          <xsl:text>

Translations
------------</xsl:text>
        </xsl:when>
        <xsl:when test="$name = 'artists'">
          <xsl:text>

Graphics, Stylesheets
---------------------</xsl:text>
        </xsl:when>
        <xsl:when test="$name = 'technicans'">
          <xsl:text>

Build System, Technical Contributions
-------------------------------------</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>ERROR: Unknown role '</xsl:text>
            <xsl:value-of select="$name"/>
            <xsl:text>' in "authors_docbook.xml".</xsl:text>
          </xsl:message>
          <xsl:text>FIXME</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <!-- whether to print "John Doe (English)" or "John Doe" -->
      <xsl:variable name="with.language">
        <xsl:choose>
          <xsl:when test="contains($print.roles.with.lang, $role)">
            <xsl:value-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <!-- extract authors and contributors -->
      <xsl:choose>
        <!-- technicans may be creators or contributors -->
        <xsl:when test="$role = 'technican'">
          <xsl:for-each select="//dc:contributor[contains(@role, $role)] |
                                //dc:creator[contains(@role, $role)]">
            <xsl:call-template name="print.item">
              <xsl:with-param name="print.language" select="$with.language"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:when>
        <!-- print contributors? -->
        <xsl:when test="$role != 'creator'">
          <xsl:for-each select="//dc:contributor[contains(@role, $role)]">
            <xsl:call-template name="print.item">
              <xsl:with-param name="print.language" select="$with.language"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:when>
        <!-- print creators -->
        <xsl:otherwise>
          <xsl:for-each select="//dc:creator">
            <xsl:call-template name="print.item">
              <xsl:with-param name="print.language" select="$with.language"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
      <!-- if necessary, print next list entry -->
      <xsl:if test="contains($roles,' ')">
        <xsl:call-template name="print.listentry">
          <xsl:with-param name="roles">
            <xsl:value-of select="substring-after($roles,' ')"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- ============================================================= -->
  <xsl:template name="print.item">
  <!-- ============================================================= -->
    <xsl:param name="print.language">1</xsl:param>
    <xsl:text>
</xsl:text>
<xsl:apply-templates match="." />
    <xsl:if test="@lang != '' and $print.language != 0">
      <xsl:text>(</xsl:text>
      <xsl:call-template name="lang.split">
        <xsl:with-param name="lang" select="@lang" />
      </xsl:call-template>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
