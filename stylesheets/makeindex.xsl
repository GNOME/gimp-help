<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:doc="http://nwalsh.com/xsl/documentation/1.0" exclude-result-prefixes="doc" version="1.0">
  
  <xsl:output method="xml" encoding="UTF-8" indent="yes" />
  
  <xsl:template match="/">
    <gimp-help>
      <xsl:apply-templates select="*"/>
    </gimp-help>
  </xsl:template>
  
  <xsl:template match="/div/div[@targetptr='help-missing']">
    <help-missing>
      <xsl:attribute name="ref">
        <xsl:value-of select="@href" />
      </xsl:attribute>
    </help-missing>
  </xsl:template>
  
  <xsl:template match="div|obj|ttl">
    <xsl:choose>
      <!-- skip area elements, because the help browser cannot link to
      them anyway and we don't want them in the statistics
      //-->
      <xsl:when test="@element='area'">
      </xsl:when>
      <xsl:when test="@targetptr">
        <help-item>
          <xsl:attribute name="id"> 
            <xsl:value-of select="@targetptr"/>
          </xsl:attribute>
          <xsl:attribute name="ref"> 
            <xsl:value-of select="@href"/>
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:value-of select="ttl" />
          </xsl:attribute>
        </help-item>
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates select="*"/>
  </xsl:template>
  
  
  
  <xsl:template match="*">
  </xsl:template>
  
  <!--
<xsl:template match="*" mode="process.root">
  <xsl:variable name="doc" select="self::*"/>

  <xsl:call-template name="root.messages"/>

  <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <xsl:call-template name="system.head.content">
        <xsl:with-param name="node" select="$doc"/>
      </xsl:call-template>
      <xsl:call-template name="head.content">
        <xsl:with-param name="node" select="$doc"/>
      </xsl:call-template>
      <xsl:call-template name="user.head.content">
        <xsl:with-param name="node" select="$doc"/>
      </xsl:call-template>
    </head>
    <body>
      <xsl:call-template name="body.attributes"/>
      <xsl:call-template name="user.header.content">
        <xsl:with-param name="node" select="$doc"/>
      </xsl:call-template>
      <xsl:apply-templates select="."/>
      <xsl:call-template name="user.footer.content">
        <xsl:with-param name="node" select="$doc"/>
      </xsl:call-template>
    </body>
  </html>
</xsl:template>
-->
  
</xsl:stylesheet>
