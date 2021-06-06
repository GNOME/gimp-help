<?xml version="1.0" encoding="UTF-8"?>
<!--
    Simple XSL transformation to create MAINTAINERS text version from
    gimp-help.doap.

    This file is part of the gimp-help project and is
    (C) 2010 The GIMP Documentation Team (License: GPL).
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:doap="http://usefulinc.com/ns/doap#"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:gnome="http://api.gnome.org/doap-extensions#">

  <xsl:output method="text"/>

  <!-- valid mode: 'maintainers' (we may add 'authors' in the future) -->
  <xsl:param name="doap2text.mode" select="'maintainers'"/>
  <!-- not used yet -->
  <xsl:param name="doap2text.debug" select="0"/>
  <!-- add an "automatically generated" note? -->
  <xsl:param name="doap2text.maintainers.add-footnote" select="1"/>


  <!--=======================================================-->
  <xsl:template match="/doap:Project">
  <!--=======================================================-->
    <xsl:variable name="doap2text.target">
      <xsl:value-of select="$doap2text.mode"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$doap2text.target='maintainers'">
        <xsl:text>Currently active maintainers
----------------------------
</xsl:text>
        <xsl:apply-templates select="doap:maintainer/foaf:Person"
          mode="maintainers"/>
        <xsl:if test="$doap2text.maintainers.add-footnote=1">
          <xsl:text>
(This file was generated automatically
from "gimp-help.doap". Do not edit.)
</xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$doap2text.target='authors'">
        <xsl:message terminate="yes">
          <xsl:text>Error: Generating AUTHORS from gimp-help.doap is </xsl:text>
          <xsl:text>not implemented yet.</xsl:text>
        </xsl:message>
      </xsl:when>
      <xsl:when test="$doap2text.target=''">
        <xsl:message terminate="yes">
          <xsl:text>Error: 'doap2text.mode' parameter not set.</xsl:text>
        </xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          <xsl:text>Error: Unknown doap2text.mode specified: </xsl:text>
          <xsl:value-of select="$doap2text.target"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--===============================================================-->
  <xsl:template match="doap:maintainer/foaf:Person" mode="maintainers">
  <!--===============================================================-->
    <xsl:text>
</xsl:text>
    <xsl:value-of select="foaf:name"/>
    <xsl:text>
E-mail: </xsl:text>
    <xsl:variable name="mbox">
      <xsl:choose>
        <xsl:when test="contains(foaf:mbox/@rdf:resource,'mailto:')">
          <xsl:value-of select="substring-after(foaf:mbox/@rdf:resource,':')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="foaf:mbox/@rdf:resource"/>
          <xsl:message>
            <xsl:text>doap2text.xsl: warning: missing "mailto:" in "</xsl:text>
            <xsl:value-of select="foaf:mbox/@rdf:resource"/>
            <xsl:text>"</xsl:text>
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$mbox"/>
    <xsl:text>
Userid: </xsl:text>
    <xsl:value-of select="gnome:userid"/>
    <xsl:text>
</xsl:text>
  </xsl:template>

</xsl:stylesheet>
