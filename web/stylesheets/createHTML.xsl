<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns="http://www.w3.org/1999/xhtml"
    version="1.0">

  <xsl:import href="http://docbook.sourceforge.net/release/website/2.5.0/xsl/website.xsl" />


  <xsl:output   indent="yes"
                method="xml" 
                encoding="UTF-8"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
                doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
              />

  <xsl:param name="output-root">html</xsl:param>
  <xsl:param name="collect.xref.targets">yes</xsl:param>
  <xsl:template name="home.navhead" />
  <xsl:template name="home.navhead.upperright" />

  <xsl:template name="allpages.banner">
    <div id="Header">
      <a href="http://docs.gimp.org" title="Home">
          <img src='Layout/header.png' alt='Logo' class='logo' />
      </a>
      <a href="http://docs.gimp.org" title="Home">
          <img src='Layout/wilber.png' alt='Logo'  class="wilber"/>
      </a>
    </div>
      <div id="Searchform">
          <form method="get" action="http://www.google.com/custom">
              <input type="text" name="q" size="25" maxlength="255"
                     value=""
                     class="searchinput"
                     title="Search performed by google.com" />
              <input type="submit" name="sa" value="Search docs.gimp.org" 
                     title="Search performed by google.com" />
              <input type="hidden" name="cof"
              value="S:http://www.gimp.org;AH:center;LH:80px;LC:#17457c;L:http://docs.gimp.org/wilber.png;ALC:#991e1e;LW:80px;AWFID:5ab3786d3aacbee0;"
              />
              <input type="hidden" name="domains" value="docs.gimp.org" />
              <br/>
              <input type="hidden" name="sitesearch" value="docs.gimp.org" /> 
          </form>
      </div>
  </xsl:template>

  <!-- thats totally stupid, but it works for this one -->
  <xsl:template match="para[@class]">
    <p>
      <xsl:attribute name="class">
        <xsl:value-of select="@class" />
      </xsl:attribute>
      <xsl:apply-templates />
    </p>
  </xsl:template>

<!-- put your customizations here -->
</xsl:stylesheet>
