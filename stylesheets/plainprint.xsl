<?xml version="1.0" encoding="utf-8"?>

<!--
  This file is part of the gimp-help project and is
  (C) 2002, 2003, 2004, 2005, 2006 Daniel Egger, Róman Joost
  You may use this file in accordance to the GNU General Public License
  Version 2 which is available from http://www.gnu.org.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!--
    The following parameters overwrite the defaults of the dblatex package:
  -->

  <!-- enable processing of unicode characters -->
  <xsl:param name="latex.unicode.use">1</xsl:param>
  <xsl:param name="latex.encoding">utf8</xsl:param>

  <!-- define what to show in the toc -->
  <xsl:param name="doc.lot.show">example</xsl:param>

  <!-- hide image-object callouts -->
  <xsl:param name="imageobjectco.hide">1</xsl:param>

  <!-- limit the toc depth to sect2 headings -->
  <xsl:param name="toc.section.depth">2</xsl:param>

  <!-- create links to glossterms automatically -->
  <xsl:param name="glossterm.auto.link">1</xsl:param>

  <!-- put titles above the elements -->
  <xsl:param name="equation.title.top">1</xsl:param>
  <xsl:param name="figure.title.top">1</xsl:param>
  <xsl:param name="table.title.top">1</xsl:param>

  <!-- use the following admonition images -->
  <xsl:param name="figure.tip">images/tip.png</xsl:param>
  <xsl:param name="figure.note">images/note.png</xsl:param>
  <xsl:param name="figure.caution">images/caution.png</xsl:param>

  <!-- use relative URIs (in fileref attributes) in the generated output -->
  <xsl:param name="keep.relative.image.uris" select="1"/>
  <!--
    The following templates (may) override the defaults:
  -->

  <!-- suppress all elements which are obviously for HTML generation -->
  <xsl:template match="*[@role='html']" />

</xsl:stylesheet>
