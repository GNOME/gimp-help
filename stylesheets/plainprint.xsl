<?xml version="1.0" encoding="utf-8"?>
<!-- This file is part of the gimp-help-2 project and is 
     You may use this file in accordance to the GNU Free Documentation License
     Version 1.1 which is available from http://www.gnu.org. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="http://db2latex.sourceforge.net/xsl/docbook.xsl" />
  <xsl:param name="generate.index">1</xsl:param>
  <xsl:param name="admon.graphics" select="1" />
  <xsl:param name="admon.graphics.path">../images/</xsl:param>
  <xsl:param name="callout.graphics.path">../images/callouts/</xsl:param>
  <xsl:param name="section.autolabel" select="1" />
  <xsl:output encoding="UTF-8" />
  <xsl:variable name='latex.inputenc'>utf8</xsl:variable>
  <xsl:variable name="latex.use.ucs">1</xsl:variable>                     
  <xsl:variable name="latex.ucs.options">postscript</xsl:variable>


  <!-- suppress any element with a html role -->
  <xsl:template match="*[@role='html']" />

</xsl:stylesheet>
