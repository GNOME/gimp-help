<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns="http://www.w3.org/1999/xhtml">

  <xsl:output method="xml" encoding="UTF-8" indent="yes" />

  <xsl:variable name="vocab" select="document('languageVocab.xml')" />
  <xsl:variable name="splitstr" select="' '" />

  <!-- The tokenizer splits all languages and creates for each language
       a link element with the href pointing to the concatenated result
       of the language id and the given filename parameter.
    -->
  <xsl:template name="gimp.help.linguas.tokenize">
    <xsl:param name="linguas" />
    <xsl:param name="filename" />
    <xsl:param name="tail">
      <xsl:value-of select="substring-after($linguas, $splitstr)" />
    </xsl:param>
    <xsl:param name="lang">
      <xsl:choose>
        <xsl:when test="contains($linguas, $splitstr)">
          <xsl:value-of select="substring-before($linguas, $splitstr)"/>
        </xsl:when>
        <xsl:when test="$linguas != ''">
          <xsl:value-of select="$linguas"/>
        </xsl:when>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="uri">
      <xsl:value-of select="concat('../', $lang, '/', $filename)" />
    </xsl:param>

    <xsl:call-template name="create_link">
      <xsl:with-param name="href" select="$uri" />
      <xsl:with-param name="title" select="$vocab/vocab/item[@value=$lang]" />
    </xsl:call-template>

    <xsl:if test="$tail != ''">
      <xsl:call-template name="gimp.help.linguas.tokenize">
        <xsl:with-param name="linguas" select="$tail" />
        <xsl:with-param name="filename" select="$filename" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="create_link">
    <xsl:param name="href" />
    <xsl:param name="title" />

    <xsl:element name="a">
      <xsl:attribute name="href">
        <xsl:value-of select="$href" />
      </xsl:attribute>
      <xsl:attribute name="title">
        <xsl:value-of select="$title" />
      </xsl:attribute>

      <xsl:value-of select="$title" />
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
