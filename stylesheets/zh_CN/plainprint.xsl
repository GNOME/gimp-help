<?xml version="1.0" encoding="utf-8"?>
<!-- This file is part of the gimp-help-2 project and is
     You may use this file in accordance to the GNU Free Documentation License
     Version 1.1 which is available from http://www.gnu.org. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="http://db2latex.sourceforge.net/xsl/docbook.xsl" />
  <xsl:param name="admon.graphics.path">../images/</xsl:param>
  <xsl:param name="callout.graphics.path">../images/callouts/</xsl:param>
  <xsl:param name="toc.section.depth">3</xsl:param>
  <xsl:output encoding="UTF-8" />
  <xsl:param name="latex.use.hyperref"/>
  <xsl:param name="latex.book.preamble.pre">
    <xsl:text>\usepackage{CJK}</xsl:text>   
  </xsl:param>
  <xsl:param name="latex.book.preamble.post">
    <xsl:text>\begin{CJK}{UTF8}{song}</xsl:text>
  </xsl:param>
  <xsl:param name="latex.babel.language">none</xsl:param>
  <xsl:param name="latex.inputenc"/>
</xsl:stylesheet>
