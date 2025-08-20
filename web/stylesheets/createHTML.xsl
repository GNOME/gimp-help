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
  <xsl:param name="currentpage.marker"></xsl:param>
  <xsl:template name="home.navhead" />
  <xsl:template name="home.navhead.upperright" />

  <xsl:template name="allpages.banner">
    <div id="Header">
      <a href="https://docs.gimp.org" title="Home">
          <img src='Layout/202010-wilber-and-co.jpg' alt='Logo' class='logo' />
      </a>
    </div>
      <div id="Searchform">
          <form method="get" action="https://www.google.com/custom">
              <input type="text" name="q" size="25" maxlength="255"
                     value=""
                     class="searchinput"
                     title="Search performed by google.com" />
              <input type="submit" name="sa" value="Search docs.gimp.org"
                     title="Search performed by google.com" />
              <br/>
              <!-- FIXME: Instead of hardcoding the number use a variable! -->
              <input type="hidden" name="sitesearch" value="docs.gimp.org/3.0/" />
          </form>
      </div>
  </xsl:template>

  <!-- that's totally stupid, but it works for this one -->
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
