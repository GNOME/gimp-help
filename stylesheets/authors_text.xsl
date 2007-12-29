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

  </xsl:template>
 
  <!-- two simple transformations -->
  <xsl:template match="//dc:creator | //dc:contributor">
    <xsl:param name="print_language">1</xsl:param>
    <xsl:text>  </xsl:text>
    <xsl:apply-templates match="." />
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

  <xsl:template name="lang.split">
    <xsl:param name="lang" />
    <xsl:choose>
      <xsl:when test="contains($lang, ' ')">
        <xsl:variable name="langid" select="substring-after($lang, ' ')" />
        <xsl:call-template name="print.lang">
          <xsl:with-param name="langid" select="$langid" />
        </xsl:call-template>
        <xsl:text>, </xsl:text>
        <xsl:call-template name="lang.split">
          <xsl:with-param name="lang" select="substring-before($lang, ' ')" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="print.lang">
          <xsl:with-param name="langid" select="$lang" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- yesss.. this can be way better implemented -->
  <xsl:template name="print.lang">
    <xsl:param name="langid" />
    <xsl:if test="$langid = 'de'">
      <xsl:text>German</xsl:text>
    </xsl:if>
    <xsl:if test="$langid = 'en'">
      <xsl:text>English</xsl:text>
    </xsl:if>
    <xsl:if test="$langid = 'it'">
      <xsl:text>Italian</xsl:text>
    </xsl:if>
    <xsl:if test="$langid = 'pl'">
      <xsl:text>Polish</xsl:text>
    </xsl:if>
    <xsl:if test="$langid = 'fr'">
      <xsl:text>French</xsl:text>
    </xsl:if>
    <xsl:if test="$langid = 'es'">
      <xsl:text>Spanish</xsl:text>
    </xsl:if>
    <xsl:if test="$langid = 'ko'">
      <xsl:text>Korean</xsl:text>
    </xsl:if>
    <xsl:if test="$langid = 'sv'">
      <xsl:text>Swedish</xsl:text>
    </xsl:if>
    <xsl:if test="$langid = 'ru'">
      <xsl:text>Russian</xsl:text>
    </xsl:if>
    <xsl:if test="$langid = 'cz'">
      <xsl:text>Czech</xsl:text>
    </xsl:if>
    <xsl:if test="$langid = 'nl'">
      <xsl:text>Dutch</xsl:text>
    </xsl:if>
    <xsl:if test="$langid = 'zh_CN'">
      <xsl:text>Chinese</xsl:text>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
