<?xml version="1.0" encoding="utf-8"?>

<!--
  This file is part of the gimp-help-2 project and is
  You may use this file in accordance to the GNU Free Documentation License
  Version 1.1 which is available from http://www.gnu.org.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!--
    The following parameters overwrite the defaults of the dblatex package:
  -->

  <!-- enable processing of unicode characters -->
  <xsl:param name="latex.unicode.use">1</xsl:param>

  <!-- define what to show in the toc -->
  <xsl:param name="doc.lot.show">table,example</xsl:param>

  <!-- show dblatex logo - the project deserves it! -->
  <xsl:param name="doc.publisher.show">0</xsl:param>

  <!-- hide image-object callouts -->
  <xsl:param name="imageobjectco.hide">1</xsl:param>

  <!-- old values, taken over from db2latex -->
  <xsl:param name="admon.graphics" select="1" />
  <xsl:param name="admon.graphics.path">../images</xsl:param>
  <xsl:param name="callout.graphics">1</xsl:param>
  <xsl:param name="callout.graphics.path">../images/callouts/</xsl:param>
  <xsl:param name="generate.callout.arearefs">1</xsl:param>
  <xsl:param name="generate.index">1</xsl:param>
  <xsl:param name="insert.xref.page.number">1</xsl:param>
  <xsl:param name="latex.document.font">palatino</xsl:param>
  <xsl:param name="latex.documentclass">scrreprt</xsl:param>
  <xsl:param name="latex.is.draft">0</xsl:param>
  <xsl:param name="latex.use.ltxtable">0</xsl:param>
  <xsl:param name="latex.use.overpic">1</xsl:param>
  <xsl:param name="latex.use.tabularx">0</xsl:param>
  <xsl:param name="section.autolabel" select="1" />
  <xsl:param name="toc.section.depth">2</xsl:param>

</xsl:stylesheet>