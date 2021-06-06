<?xml version="1.0" encoding="utf-8"?>
<!-- This file is part of the gimp-help project and is
     (C) 2002, 2003, 2004, 2005, 2006, 2007 Daniel Egger, Róman Joost
     You may use this file in accordance to the GNU General Public License
     Version 2 which is available from http://www.gnu.org. -->

<!-- Usage: include this file from "stylesheets/plainhtml.xsl".  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
             xmlns="http://www.w3.org/1999/xhtml">

  <!--
      template: output.html.stylesheets

      This is a modified copy of the docbook-xsl-1.72 template;
      it will replace the original template.
      Its string value is a list of HTML <link> tags with attribute
      rel="stylesheet" as produced by the original docbook-xsl
      template, and (if xsl:parameter "html.stylesheet.alternate" is
      not empty) a list of HTML <link> tags with attributes
      rel="alternate stylesheet" and title="[filename without '.css']".
  -->
  <xsl:template name="output.html.stylesheets">
    <xsl:param name="stylesheets" select="''"/>

    <xsl:choose>
      <xsl:when test="contains($stylesheets, ' ')">
        <link rel="stylesheet" href="{substring-before($stylesheets, ' ')}">
          <xsl:if test="$html.stylesheet.type != ''">
            <xsl:attribute name="type">
              <xsl:value-of select="$html.stylesheet.type"/>
            </xsl:attribute>
          </xsl:if>
        </link>
        <xsl:call-template name="output.html.stylesheets">
          <xsl:with-param name="stylesheets" select="substring-after($stylesheets, ' ')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$stylesheets != ''">
        <link rel="stylesheet" href="{$stylesheets}">
          <xsl:if test="$html.stylesheet.type != ''">
            <xsl:attribute name="type">
              <xsl:value-of select="$html.stylesheet.type"/>
            </xsl:attribute>
          </xsl:if>
        </link>

        <!-- here's our modification, calling the new template below -->
        <xsl:if test="$html.stylesheet.alternate != ''">
          <xsl:call-template name="output.html.stylesheet.alternates">
            <xsl:with-param name="alternates"
              select=" normalize-space($html.stylesheet.alternate)" />
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!--
      template: output.html.stylesheets.alternates

      This is also a modified copy of the docbook-xsl-1.72 template.
      It produces the HTML <link> tags for alternate styleshhets,
      using the file's basename without '.css' extension as the
      title attribute.
  -->
  <xsl:template name="output.html.stylesheet.alternates">
    <!-- parameter: a space-separated list of filenames -->
    <xsl:param name="alternates" select="''"/>

    <xsl:choose>
      <xsl:when test="contains($alternates, ' ')">
        <xsl:variable name="href" select="substring-before($alternates, ' ')"/>
        <link rel="alternate stylesheet" href="{$href}">
          <xsl:attribute name="type">
            <xsl:value-of select="text/css"/>
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:value-of select="substring-before($href, '.')"/>
          </xsl:attribute>
        </link>
        <xsl:call-template name="output.html.stylesheet.alternates">
          <xsl:with-param name="alternates" select="substring-after($alternates, ' ')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$alternates != ''">
        <xsl:variable name="href" select="$alternates"/>
        <link rel="alternate stylesheet" href="{$href}">
          <xsl:attribute name="type">
            <xsl:value-of select="'text/css'"/>
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:value-of select="substring-before($href, '.')"/>
          </xsl:attribute>
        </link>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
