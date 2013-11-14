<?xml version="1.0" encoding="UTF-8"?>

<!--  template(s) common to "authors_docbook.xsl" and "author_text.xsl"  -->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dc="http://purl.org/dc/elements/1.1/">

  <!-- ============================================================= -->
  <xsl:template name="lang.split">
  <!-- ============================================================= -->
    <!--
        Convert space-separated list of language ids
        to comma separated list of language names,
        e.g., "de en fr" to "German, English, French"
    -->
    <xsl:param name="lang"/>
    <xsl:choose>
      <xsl:when test="contains($lang, ' ')">
        <xsl:call-template name="print.lang">
          <xsl:with-param name="langid" select="substring-before($lang,' ')"/>
        </xsl:call-template>
        <xsl:text>, </xsl:text>
        <xsl:call-template name="lang.split">
          <xsl:with-param name="lang" select="substring-after($lang,' ')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="print.lang">
          <xsl:with-param name="langid" select="$lang"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ============================================================= -->
  <xsl:template name="print.lang">
  <!-- ============================================================= -->
    <!--
        Convert language id to language name (e.g., "en" to "English")
    -->
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
      ja:Japanese
      ko:Korean
      lt:Lithuanian
      nl:Dutch
      no:Norwegian
      pl:Polish
      ru:Russian
      sv:Swedish
      zh_CN:Chinese
      pt_BR:Brasilian
      fi:Finnish
      da:Danish
      el:Greek
    </xsl:variable>
    <xsl:variable name="tail"
      select="substring-after($languages,concat($langid,':'))"/>
    <xsl:choose>
      <xsl:when test="$tail != ''">
        <xsl:value-of select="translate(
                                normalize-space(substring-before($tail,' ')),
                                '_', ' ')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$langid"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>

