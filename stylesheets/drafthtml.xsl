<?xml version="1.0" encoding="utf-8"?>
<!-- This file is part of the gimp-help project and is
     (C) 2008 The GIMP Documentation Team.
     You may use this file in accordance to the GNU General Public License
     Version 2 which is available from http://www.gnu.org.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns="http://www.w3.org/1999/xhtml">
  <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/xhtml/docbook.xsl" />
  <xsl:output method="html" indent="yes"/>

  <xsl:param name="admon.graphics" select="1" />
  <xsl:param name="admon.graphics.path">images/</xsl:param>
  <xsl:param name="callout.graphics.path">images/callouts/</xsl:param>
  <xsl:param name="generate.index">0</xsl:param>
  <xsl:param name="html.stylesheet">
    gimp-help-plain.css gimp-help-screen.css gimp-help-custom.css gimp-help-draft.css
  </xsl:param>
  <xsl:param name="make.valid.html" select="1" />
  <xsl:param name="id.warnings" select="0" />
  <xsl:param name="use.id.as.filename">1</xsl:param>
  <xsl:param name="navig.graphics" select="0" />
  <xsl:param name="navig.showtitles" select="0" />

</xsl:stylesheet>
