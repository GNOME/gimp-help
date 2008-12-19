<?xml version="1.0" encoding="utf-8"?>
<!--
    This is a simple stylesheet to merge the glossary files.
    Additionally, the "glossterm" tags will be unified.
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Generate DocBook instance with correct DOCTYPE -->
  <xsl:output method="xml" encoding="utf-8"
    doctype-public="-//OASIS//DTD DocBook XML V4.5//EN"
    doctype-system="http://www.docbook.org/xml/4.5/docbookx.dtd"/>

  <xsl:template match="glossary">
    <!--XXX: is this really the correct way to add a namespace?-->
    <glossary xmlns:xi="http://www.w3.org/2001/XInclude">
      <xsl:for-each select="@*">
        <xsl:attribute name="{name()}">
          <xsl:value-of select="." />
        </xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates/>
    </glossary>
  </xsl:template>

  <xsl:template match="glossdiv">
    <!--xsl:element name="{local-name(.)}">
      <xsl:if test="@lang">
        <xsl:attribute name="lang">
          <xsl:value-of select="@lang" />
        </xsl:attribute>
      </xsl:if-->
      <!-- XXX: it seems that sorting does not work with
           multiple source files... -->
      <xsl:apply-templates select="glossentry">
        <xsl:sort select="@id" />
      </xsl:apply-templates>
    <!--/xsl:element-->
  </xsl:template>

  <xsl:template match="glossentry">
    <xsl:choose>
      <xsl:when test="count(glossterm) = 1 and
                      glossterm/phrase and
                      not(glossterm/@lang)">
        <!-- <glossterm> <phrase lang="xx"> <phrase lang="yy"> ... -->
        <xsl:copy-of select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{local-name(.)}">
          <xsl:attribute name="id">
            <xsl:value-of select="@id" />
          </xsl:attribute>
          <xsl:if test="@lang">
            <xsl:attribute name="lang">
              <xsl:value-of select="@lang" />
            </xsl:attribute>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="count(glossterm) > 1">
              <!-- <glossterm lang="xx">... <glossterm lang="yy"> ... -->
              <xsl:call-template name="glossterms" />
              <xsl:apply-templates select="*[local-name() != 'glossterm']" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="glossterm">
    <xsl:element name="{local-name()}">
      <xsl:choose>
        <xsl:when test="phrase">
          <!-- <glossterm lang="xx"> <phrase> ... -->
          <xsl:variable name="termlang" select="@lang"/>
          <xsl:for-each select="phrase">
            <xsl:element name="phrase">
              <xsl:choose>
                <xsl:when test="@lang">
                  <xsl:attribute name="lang">
                    <xsl:value-of select="@lang" />
                  </xsl:attribute>
                </xsl:when>
                <xsl:when test="$termlang">
                  <xsl:attribute name="lang">
                    <xsl:value-of select="$termlang" />
                  </xsl:attribute>
                </xsl:when>
              </xsl:choose>
              <xsl:value-of select="." />
            </xsl:element>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <!-- <glossterm lang="xx"> ... </glossterm> -->
          <xsl:element name="phrase">
            <xsl:if test="@lang">
              <xsl:attribute name="lang">
                <xsl:value-of select="@lang" />
              </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="." />
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <!-- <glossterm lang="xx">... <glossterm lang="yy"> ... -->
  <xsl:template name="glossterms">
    <xsl:element name="glossterm">
      <xsl:for-each select="glossterm">
        <xsl:element name="phrase">
          <xsl:attribute name="lang">
            <xsl:value-of select="@lang" />
          </xsl:attribute>
          <xsl:value-of select="." />
        </xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <xsl:template match="simplelist|anchor" />

  <!--xsl:template match="glossdef|indexterm|title"-->
  <xsl:template match="*">
    <xsl:copy-of select="." />
  </xsl:template>

</xsl:stylesheet>
