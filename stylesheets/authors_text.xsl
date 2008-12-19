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

  <xsl:template name="print.lang">
    <xsl:param name="langid" />
    <!-- use underscores for spaces within languages,
         e.g. xx:Pidgin_English -->
    <xsl:variable name="languages">
      cz:Czech
      de:German
      en:English
      es:Spanish
      fr:French
      hr:Croatian
      it:Italian
      ko:Korean
      lt:Lithuanian
      nl:Dutch
      no:Norwegian
      pl:Polish
      ru:Russian
      sv:Swedish
      zh_CN:Chinese
    </xsl:variable>
    <xsl:variable name="tail"
      select="substring-after($languages,concat($langid,':'))"/>
    <xsl:if test="$tail != ''">
      <xsl:value-of select="translate(
                              normalize-space(substring-before($tail,' ')),
                              '_', ' ')"/>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
