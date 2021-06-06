<?xml version="1.0" encoding="utf-8"?>
<!--
    Customized docbook-xsl template to generate an additional class
    value for (inline)mediaobjects with condition attribute "float"

    This file is part of the gimp-help project.
    You may use this file in accordance to the GNU General Public License
    Version 2 which is available from http://www.gnu.org.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                version="1.0">

  <!-- The new class value, to be used via CSS stylesheets -->
  <xsl:param name="float-attribute">float-img</xsl:param>

  <!-- This is a customized version of the docbook-xsl-1.75.2 template
       (.../xhtml/html.xsl) -->
  <xsl:template match="inlinemediaobject[@condition='float'] |
                       mediaobject[@condition='float']"
                mode="class.value">
    <xsl:param name="class" select="local-name(.)"/>
    <xsl:choose>
      <xsl:when test="caption">
        <xsl:message>
          <xsl:text>Warning: Ignoring 'condition="float"' of mediaobject w/ caption</xsl:text>
        </xsl:message>
        <xsl:value-of select="$class"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($class, ' ', $float-attribute)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
