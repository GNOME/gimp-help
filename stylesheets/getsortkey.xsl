<?xml version="1.0" encoding="utf-8"?>
<!--
    This file is part of the gimp-help project and is
    (C) The GIMP Documentation Team.
    You may use this file in accordance to the GNU General Public License
    Version 2 which is available from http://www.gnu.org.
-->

<!--
    This file provides the template "gimp-help.help-id.sort"
    which generates a key for sorting <help-item>s.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gimp-help="http://www.gimp.org/docs"
                exclude-result-prefixes="gimp-help"
                version="1.0">

  <!-- Testing & debugging -->
  <xsl:param name="help-id.sort.debug" select="0"/>

  <!-- Top-level section numbers -->
  <xsl:variable name="division.id">66</xsl:variable>
  <xsl:variable name="appendix.id">77</xsl:variable>
  <xsl:variable name="biblio.id">88</xsl:variable>
  <xsl:variable name="index.id">99</xsl:variable>


  <!-- ============================================================= -->
  <xsl:template name="gimp-help.help-id.sort">
  <!-- ============================================================= -->
    <xsl:if test="$help-id.sort.debug>0">
      <xsl:message>
        <xsl:text>Debug getsortkey: processing </xsl:text>
        <xsl:value-of select="local-name()"/>
        <xsl:text> (element=</xsl:text>
        <xsl:value-of select="@element"/>
        <xsl:text>, targetptr=</xsl:text>
        <xsl:value-of select="@targetptr"/>
        <xsl:text>, number=</xsl:text>
        <xsl:value-of select="@number"/>
        <xsl:text>)</xsl:text>
      </xsl:message>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@number != ''">
        <!-- case 1: element has attribute "number" -->
        <xsl:choose>
          <!-- case 1a: simple or dotted number "1", "1.1", etc. (DocBook <sect*>) -->
          <xsl:when test="string(number(substring(@number,1,1))) != 'NaN'">
            <xsl:value-of select="@number"/>
          </xsl:when>
          <!-- case 1b: roman number "I", "II", etc. (DocBook <part>) -->
          <xsl:when test="starts-with(@number,'I') or
                          starts-with(@number,'V')">
            <xsl:variable name="roman">
              <xsl:call-template name="number.roman.decode">
                <xsl:with-param name="number" select="@number"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="concat($division.id,'.',$roman)"/>
          </xsl:when>
          <!-- case 1c: number "A", "B", "C", etc.(DocBook <appendix>) -->
          <xsl:when test="string-length(@number) = 1">
            <xsl:choose>
              <xsl:when test="number(translate(@number,'ABCDEF','123456'))">
                <xsl:value-of select="concat($appendix.id,'.',
                  translate(@number,'ABCDEF','123456'))"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:message>
                  <xsl:text>Warning: invalid number: </xsl:text>
                  <xsl:value-of select="@number"/>
                </xsl:message>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <!-- Error -->
          <xsl:otherwise>
            <xsl:message>
              <xsl:text>Warning: invalid number: </xsl:text>
              <xsl:value-of select="@number"/>
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise> <!-- @number = '' -->
        <xsl:choose>
          <!-- Special case: Bibliography -->
          <xsl:when test="@targetptr = 'bibliography'">
            <xsl:value-of select="$biblio.id"/>
          </xsl:when>
          <!-- Special case: Index -->
          <xsl:when test="@targetptr = 'gimp-help-index'">
            <xsl:value-of select="$index.id"/>
          </xsl:when>
          <xsl:when test="not(@targetptr)">
            <xsl:value-of select="0"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="sort.parent">
              <!--xsl:for-each select=".."-->
              <xsl:for-each select="parent::div|parent::obj">
                <xsl:call-template name="gimp-help.help-id.sort"/>
              </xsl:for-each>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$sort.parent!=''">
                <xsl:value-of select="concat($sort.parent,'.0.',position())"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="position()"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose> <!--@targetptr-->
      </xsl:otherwise>
    </xsl:choose> <!--@number-->
  </xsl:template>

  <!-- ============================================================= -->
  <xsl:template name="number.roman.decode">
  <!-- ============================================================= -->
    <xsl:param name="number" select="''"/>
    <xsl:variable name="head">
      <xsl:choose>
        <xsl:when test="$number = ''">0</xsl:when>
        <xsl:when test="starts-with($number,'IV')">4</xsl:when>
        <xsl:when test="starts-with($number,'I')">1</xsl:when>
        <xsl:when test="starts-with($number,'V')">5</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="tail">
      <xsl:choose>
        <xsl:when test="$number = ''"></xsl:when>
        <xsl:when test="starts-with($number,'IV')">
          <xsl:value-of select="substring($number,3)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring($number,2)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$tail != '' and $head > 0">
        <xsl:variable name="tail.decoded">
          <xsl:call-template name="number.roman.decode">
            <xsl:with-param name="number" select="$tail"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$head + $tail.decoded"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="number($head)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
