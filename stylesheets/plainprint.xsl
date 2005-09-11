<?xml version="1.0" encoding="utf-8"?>
<!-- This file is part of the gimp-help-2 project and is 
     You may use this file in accordance to the GNU Free Documentation License
     Version 1.1 which is available from http://www.gnu.org. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="http://db2latex.sourceforge.net/xsl/docbook.xsl" />
  <xsl:param name="generate.index">1</xsl:param>
  <xsl:param name="section.autolabel" select="1" />
  <xsl:param name="admon.graphics" select="1" />
  <xsl:param name="admon.graphics.path">../images</xsl:param>
  <xsl:param name="callout.graphics">1</xsl:param>
  <xsl:param name="callout.graphics.path">../images/callouts/</xsl:param>
  <xsl:param name="generate.callout.arearefs">1</xsl:param>
  <xsl:param name="latex.document.font">palatino</xsl:param>
  <xsl:param name="latex.use.tabularx">0</xsl:param>
  <xsl:param name="latex.use.ltxtable">0</xsl:param>
  <xsl:param name="latex.use.overpic">1</xsl:param>
  <xsl:param name="latex.documentclass">scrreprt</xsl:param>
  <xsl:param name="insert.xref.page.number">1</xsl:param>
  <xsl:param name="latex.is.draft">1</xsl:param>
  
  <xsl:output encoding="UTF-8"/>
  <xsl:variable name="latex.inputenc">utf8</xsl:variable>
  <xsl:variable name="latex.use.ucs">1</xsl:variable>
  <xsl:variable name="latex.ucs.options">postscript</xsl:variable>
  
  <!-- suppress any element with a html role -->
  <xsl:template match="*[@role='html']" />
 
  <!-- handle highlights element -->
  <xsl:template match='highlights'>
    <xsl:value-of select='normalize-space(node())' />
  </xsl:template>
  
  <!-- bigger margin-top for variablelist/title -->
  <xsl:template match="variablelist/title|orderedlist/title|itemizedlist/title|simplelist/title">
		<xsl:param name="style" select="$latex.list.title.style"/>
    <xsl:text>\vspace{0.5cm}&#10;</xsl:text>
		<xsl:text>&#10;{\noindent </xsl:text>
		<xsl:value-of select="$style"/>
		<xsl:text>{\large </xsl:text>
		<xsl:apply-templates/>
		<xsl:text>}}&#10;</xsl:text>
	</xsl:template>

  <!-- handle sidewaystable elements -->
  <xsl:template match="table[@orient='land']">
    <xsl:variable name="placement">
      <xsl:call-template name="generate.formal.title.placement">
        <xsl:with-param name="object">table</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="position">
      <xsl:call-template name="generate.latex.float.position">
        <xsl:with-param name="default" select="'htb'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="caption">
      <xsl:call-template name="generate.sidewaystable.caption"/>
    </xsl:variable>
    <xsl:call-template name='map.begin'>
      <xsl:with-param name="object" select="//table" />
      <xsl:with-param name="keyword" select="'sidewaystable'" />
      <xsl:with-param name="role" select="'begin'" />
      <xsl:with-param name='string' select='$position' />
    </xsl:call-template>
    <xsl:if test="$placement='before'">
      <xsl:text>\captionswapskip{}</xsl:text>
      <xsl:value-of select="$caption" />
      <xsl:text>\captionswapskip{}</xsl:text>
    </xsl:if>
    
    <!-- handle the table content -->
    <xsl:call-template name="content-templates"/>
    
    <xsl:call-template name='map.end'>
      <xsl:with-param name="object" select="//table" />
      <xsl:with-param name="keyword" select="'sidewaystable'" />
      <xsl:with-param name="role" select="'begin'" />
      <xsl:with-param name='string' select='$position' />
  </xsl:call-template>
  </xsl:template>

  <!-- generate a caption for sidewaystable -->
  <xsl:template name="generate.sidewaystable.caption">
    <xsl:for-each select="ancestor-or-self::table[@orient='land']">
      <xsl:text>{</xsl:text>
      <xsl:value-of select="$latex.table.caption.style"/>
      <xsl:text>{\caption{</xsl:text>
      <xsl:apply-templates select="title" mode="caption.mode"/>
      <xsl:text>}</xsl:text>
      <!-- XXX leads to multiple defined labels
        <xsl:call-template name="label.id"/> 
        -->
      <xsl:text>}}&#10;</xsl:text>
    </xsl:for-each>
  </xsl:template>

	<!-- common preamble
       overrridden to insert a \usepackage{textcomp} here, because it's
       needed for euro symbols
    -->
  <xsl:template name="generate.latex.common.preamble">
		<xsl:choose>
			<xsl:when test="$latex.pdf.support=1"><xsl:value-of select="$latex.pdf.preamble"/></xsl:when>
			<xsl:otherwise><xsl:text>\usepackage{graphicx}&#10;</xsl:text></xsl:otherwise>
		</xsl:choose>
		<xsl:if test="local-name(.)='article'">
			<xsl:value-of select="$latex.article.varsets"/>
		</xsl:if>
		<xsl:if test="local-name(.)='book'">
			<xsl:value-of select="$latex.book.varsets"/>
		</xsl:if>
		<xsl:if test="$latex.bridgehead.in.lot=1">
			<xsl:text><![CDATA[
\makeatletter
% redefine the listoffigures and listoftables so that the name of the chapter
% is printed whenever there are figures or tables from that chapter. encourage
% pagebreak prior to the name of the chapter (discourage orphans).
\let\save@@chapter\@chapter
\let\save@@l@figure\l@figure
\let\the@l@figure@leader\relax
\def\@chapter[#1]#2{\save@@chapter[{#1}]{#2}%
\addtocontents{lof}{\protect\def\the@l@figure@leader{\protect\pagebreak[0]\protect\contentsline{chapter}{\protect\numberline{\thechapter}#1}{}{\thepage}}}%
\addtocontents{lot}{\protect\def\the@l@figure@leader{\protect\pagebreak[0]\protect\contentsline{chapter}{\protect\numberline{\thechapter}#1}{}{\thepage}}}%
}
\renewcommand*\l@figure{\the@l@figure@leader\let\the@l@figure@leader\relax\save@@l@figure}
\let\l@table\l@figure
\makeatother
]]></xsl:text>
		</xsl:if>
		<xsl:if test="$latex.use.fancyhdr=1">
			<xsl:text>\usepackage{fancyhdr}&#10;</xsl:text>
			<xsl:text>\renewcommand{\headrulewidth}{0.4pt}&#10;</xsl:text>
			<xsl:text>\renewcommand{\footrulewidth}{0.4pt}&#10;</xsl:text>
			<xsl:if test="$latex.fancyhdr.truncation.partition!=''">
				<xsl:variable name="partition">
					<xsl:value-of select="round(number($latex.fancyhdr.truncation.partition))"/>
				</xsl:variable>
				<xsl:variable name="left.fraction">
					<xsl:choose>
						<xsl:when test="$partition&lt;1">
							<xsl:text>0</xsl:text>
						</xsl:when>
						<xsl:when test="$partition>97">
							<xsl:text>.98</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<!-- example: 60 becomes .59 -->
							<xsl:value-of select="($partition - 1) div 100"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="right.fraction" select="0.98 - number($left.fraction)"/>
				<xsl:text>% Safeguard against long headers.&#10;</xsl:text>
				<xsl:text>\IfFileExists{truncate.sty}{&#10;</xsl:text>
				<xsl:text>\usepackage{truncate}&#10;</xsl:text>
				<xsl:text>% Use an ellipsis when text would be larger than x% of the text width.&#10;</xsl:text>
				<xsl:text>% Preserve left/right text alignment using \hfill (works for English).&#10;</xsl:text>
				<xsl:choose>
					<xsl:when test="$latex.fancyhdr.truncation.style='lr'">
						<!-- left vs. right -->
						<xsl:choose>
							<xsl:when test="$left.fraction &gt; 0.02">
								<xsl:text>\fancyhead[ol]{\truncate{</xsl:text><xsl:value-of select="$left.fraction"/><xsl:text>\textwidth}{\sl\leftmark}}&#10;</xsl:text>
								<xsl:text>\fancyhead[el]{\truncate{</xsl:text><xsl:value-of select="$left.fraction"/><xsl:text>\textwidth}{\sl\leftmark}}&#10;</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>\fancyhead[ol]{}&#10;</xsl:text>
								<xsl:text>\fancyhead[el]{}&#10;</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="$right.fraction &gt; 0.02">
								<xsl:text>\fancyhead[or]{\truncate{</xsl:text><xsl:value-of select="$right.fraction"/><xsl:text>\textwidth}{\hfill\sl\rightmark}}&#10;</xsl:text>
								<xsl:text>\fancyhead[er]{\truncate{</xsl:text><xsl:value-of select="$right.fraction"/><xsl:text>\textwidth}{\hfill\sl\rightmark}}&#10;</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>\fancyhead[or]{}&#10;</xsl:text>
								<xsl:text>\fancyhead[er]{}&#10;</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<!-- inside vs. outside -->
						<xsl:choose>
							<xsl:when test="$left.fraction &gt; 0.02">
								<xsl:text>\fancyhead[ol]{\truncate{</xsl:text><xsl:value-of select="$left.fraction"/><xsl:text>\textwidth}{\sl\leftmark}}&#10;</xsl:text>
								<xsl:text>\fancyhead[er]{\truncate{</xsl:text><xsl:value-of select="$left.fraction"/><xsl:text>\textwidth}{\hfill\sl\rightmark}}&#10;</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>\fancyhead[ol]{}&#10;</xsl:text>
								<xsl:text>\fancyhead[er]{}&#10;</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="$right.fraction &gt; 0.02">
								<xsl:text>\fancyhead[el]{\truncate{</xsl:text><xsl:value-of select="$right.fraction"/><xsl:text>\textwidth}{\sl\leftmark}}&#10;</xsl:text>
								<xsl:text>\fancyhead[or]{\truncate{</xsl:text><xsl:value-of select="$right.fraction"/><xsl:text>\textwidth}{\hfill\sl\rightmark}}&#10;</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>\fancyhead[el]{}&#10;</xsl:text>
								<xsl:text>\fancyhead[or]{}&#10;</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>}{\typeout{WARNING: truncate.sty wasn't available and functionality was skipped.}}&#10;</xsl:text>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$latex.fancyhdr.style='natural'">
					<xsl:text><![CDATA[
\makeatletter
% Override the default from fancyhdr (which would be to have all-caps headings).
\newcommand{\dblatex@chaptermark}[1]{\markboth{{\ifnum \c@secnumdepth>\m@ne \@chapapp\ \thechapter. \ \fi #1}}{}}
\def\dblatex@chaptersmark#1{\markboth{{#1}}{}}
\newcommand{\dblatex@sectionmark}[1]{\markright{{\ifnum \c@secnumdepth >\z@ \thesection. \ \fi #1}}}
\let\dblatex@ps@fancy\ps@fancy
\def\ps@fancy{
	\dblatex@ps@fancy
	\let\chaptermark\dblatex@chaptermark
	\let\sectionmark\dblatex@sectionmark
}
\makeatother
]]></xsl:text>
				</xsl:when>
			</xsl:choose>
			<xsl:call-template name="generate.latex.pagestyle"/>
			<!-- 
			Add dollar...
			<xsl:if test="latex.fancyhdr.lh !=''"><xsl:text>\lhead{</xsl:text><xsl:value-of select="$latex.fancyhdr.lh"/><xsl:text>}&#10;</xsl:text></xsl:if>
			<xsl:if test="latex.fancyhdr.ch !=''"><xsl:text>\chead{</xsl:text><xsl:value-of select="$latex.fancyhdr.ch"/><xsl:text>}&#10;</xsl:text></xsl:if>
			<xsl:if test="latex.fancyhdr.rh !=''"><xsl:text>\rhead{</xsl:text><xsl:value-of select="$latex.fancyhdr.rh"/><xsl:text>}&#10;</xsl:text></xsl:if>
			<xsl:if test="latex.fancyhdr.lf !=''"><xsl:text>\lfoot{</xsl:text><xsl:value-of select="$latex.fancyhdr.lf"/><xsl:text>}&#10;</xsl:text></xsl:if>
			<xsl:if test="latex.fancyhdr.cf !=''"><xsl:text>\cfoot{</xsl:text><xsl:value-of select="$latex.fancyhdr.cf"/><xsl:text>}&#10;</xsl:text></xsl:if>
			<xsl:if test="latex.fancyhdr.rf !=''"><xsl:text>\rfoot{</xsl:text><xsl:value-of select="$latex.fancyhdr.rf"/><xsl:text>}&#10;</xsl:text></xsl:if> 
			-->
		</xsl:if>
		<xsl:text>% ---------------------- &#10;</xsl:text>
		<xsl:text>% Most Common Packages   &#10;</xsl:text>
		<xsl:text>% ---------------------- &#10;</xsl:text>
		<xsl:if test="$latex.use.varioref=1">
			<xsl:text>\usepackage[</xsl:text>
			<xsl:value-of select="$latex.varioref.options"/>
			<xsl:text>]{varioref} &#10;</xsl:text>
		</xsl:if>
		<xsl:text>\usepackage{latexsym}         &#10;</xsl:text>
		<xsl:if test="$latex.use.dcolumn=1">
			<xsl:text>\usepackage{dcolumn}      &#10;</xsl:text>
			<xsl:text>% Default decimal point-style column&#10;</xsl:text>
			<xsl:text>\newcolumntype{d}{D{</xsl:text>
			<xsl:call-template name="gentext.dingbat">
				<xsl:with-param name="dingbat">decimalpoint</xsl:with-param>
			</xsl:call-template>
			<xsl:text>}{</xsl:text>
			<xsl:choose>
				<xsl:when test="$latex.decimal.point!=''">
					<xsl:value-of select="$latex.decimal.point"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="gentext.dingbat">
						<xsl:with-param name="dingbat">latexdecimal</xsl:with-param>
					</xsl:call-template>
				 </xsl:otherwise>
			</xsl:choose>
			<xsl:text>}{-1}}&#10;</xsl:text>
		</xsl:if>
		<xsl:text>\usepackage{enumerate}         &#10;</xsl:text>
		<xsl:if test="$latex.use.fancybox=1">
			<!-- must be before \usepackage{fancyvrb} -->
			<xsl:text>\usepackage{fancybox}      &#10;</xsl:text>
		</xsl:if>
		<xsl:text>\usepackage{float}       &#10;</xsl:text>
		<xsl:text>\usepackage{ragged2e}       &#10;</xsl:text>
		<xsl:if test="$latex.use.fancyvrb=1">
			<!-- must be after \usepackage{fancybox} -->
			<xsl:text>\usepackage{fancyvrb}         &#10;</xsl:text>
			<xsl:text>\makeatletter\@namedef{FV@fontfamily@default}{\def\FV@FontScanPrep{}\def\FV@FontFamily{}}\makeatother&#10;</xsl:text>
			<xsl:if test="$latex.fancyvrb.tabsize!=''">
				<xsl:text>\fvset{obeytabs=true,tabsize=</xsl:text>
				<xsl:value-of select="$latex.fancyvrb.tabsize"/>
				<xsl:text>}&#10;</xsl:text>
			</xsl:if>
		</xsl:if>
		<xsl:if test="$latex.use.isolatin1=1">
			<xsl:message>Please use $latex.inputenc='latin1' instead of $latex.use.isolatin1='1'.</xsl:message>
			<xsl:text>\usepackage{isolatin1}         &#10;</xsl:text>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="$latex.use.parskip=1">
				<xsl:text>\usepackage{parskip}         &#10;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<!-- hack from parksip to stop excess whitespace after figure captions -->
				<xsl:text><![CDATA[\makeatletter
\let\dblatex@center\center\let\dblatex@endcenter\endcenter
\def\dblatex@nolistI{\leftmargin\leftmargini\topsep\z@ \parsep\parskip \itemsep\z@}
\def\center{\let\@listi\dblatex@nolistI\@listi\dblatex@center\let\@listi\@listI\@listi}
\def\endcenter{\dblatex@endcenter}
\makeatother
]]></xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="$latex.use.rotating=1"><xsl:text>\usepackage{rotating}         &#10;</xsl:text></xsl:if>
		<xsl:if test="$latex.use.subfigure=1"><xsl:text>\usepackage{subfigure}         &#10;</xsl:text></xsl:if>
		<xsl:if test="$latex.use.tabularx=1"><xsl:text>\usepackage{tabularx}         &#10;</xsl:text></xsl:if>
		<xsl:if test="$latex.use.ltxtable=1 or $latex.use.longtable=1"><xsl:text>\usepackage{longtable}         &#10;</xsl:text></xsl:if>
		<xsl:if test="$latex.use.umoline=1"><xsl:text>\usepackage{umoline}         &#10;</xsl:text></xsl:if>
		<xsl:if test="$latex.use.url=1"><xsl:text>\usepackage{url}         &#10;</xsl:text></xsl:if>
		<xsl:if test="$latex.math.support=1"><xsl:value-of select="$latex.math.preamble"/></xsl:if>

		<!-- Configure document font. -->
		<xsl:if test="$latex.document.font != 'default'">
			<xsl:text>% ---------------&#10;</xsl:text>
			<xsl:text>% Document Font  &#10;</xsl:text>
			<xsl:text>% ---------------&#10;</xsl:text>
			<xsl:text>\usepackage{</xsl:text><xsl:value-of select="$latex.document.font"/><xsl:text>}&#10;</xsl:text>
		</xsl:if>

    <!-- use textcomp -->
    <xsl:text>% ---------------&#10;</xsl:text>
    <xsl:text>% Textcomp for Euro sign  &#10;</xsl:text>
    <xsl:text>% ---------------&#10;</xsl:text>
    <xsl:text>\usepackage{textcomp}&#10;</xsl:text>

		<xsl:if test="$latex.use.hyperref=1">
			<xsl:call-template name="latex.hyperref.preamble"/>
		</xsl:if>
		<xsl:value-of select="$latex.admonition.environment"/>
		<xsl:call-template name="latex.float.preamble"/>
		<xsl:call-template name="latex.graphicext"/>
		<xsl:choose>
			<xsl:when test='$latex.caption.swapskip=1'>
				<xsl:text>% --------------------------------------------&#10;</xsl:text>
				<xsl:text>% $latex.caption.swapskip enabled for $formal.title.placement support&#10;</xsl:text>
				<xsl:text>\newlength{\docbooktolatextempskip}&#10;</xsl:text>
				<xsl:text>\newcommand{\captionswapskip}{\setlength{\docbooktolatextempskip}{\abovecaptionskip}</xsl:text>
				<xsl:text>\setlength{\abovecaptionskip}{\belowcaptionskip}</xsl:text>
				<xsl:text>\setlength{\belowcaptionskip}{\docbooktolatextempskip}}&#10;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>\newcommand{\captionswapskip}{}&#10;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test='$latex.hyphenation.tttricks=1'>
			<xsl:text>% --------------------------------------------&#10;</xsl:text>
			<xsl:text>% Better linebreaks&#10;</xsl:text>
			<xsl:text>\newcommand{\docbookhyphenatedot}[1]{{\hyphenchar\font=`\.\relax #1\hyphenchar\font=`\-}}&#10;</xsl:text>
			<xsl:text>\newcommand{\docbookhyphenatefilename}[1]{{\hyphenchar\font=`\.\relax #1\hyphenchar\font=`\-}}&#10;</xsl:text>
			<xsl:text>\newcommand{\docbookhyphenateurl}[1]{{\hyphenchar\font=`\/\relax #1\hyphenchar\font=`\-}}&#10;</xsl:text>
		</xsl:if>
		<!--
		<xsl:message>$document.xml.language: '<xsl:value-of select="$document.xml.language"/>'</xsl:message>
		<xsl:message>$latex.language.option: '<xsl:value-of select="$latex.language.option"/>'</xsl:message>
		-->
		<xsl:if test="$latex.language.option!='none'">
			<xsl:text>\usepackage[</xsl:text><xsl:value-of select="$latex.language.option" /><xsl:text>]{babel} &#10;</xsl:text>
		</xsl:if>
		<xsl:if test="$latex.use.hyperref='1'">
			<xsl:text>% Guard against a problem with old package versions.&#10;</xsl:text>
			<xsl:text>\makeatletter&#10;</xsl:text>
			<xsl:text>\AtBeginDocument{&#10;</xsl:text>
			<xsl:text>\DeclareRobustCommand\ref{\@refstar}&#10;</xsl:text>
			<xsl:text>\DeclareRobustCommand\pageref{\@pagerefstar}&#10;</xsl:text>
			<xsl:text>}&#10;</xsl:text>
			<xsl:text>\makeatother&#10;</xsl:text>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="$latex.is.draft!=''">
				<xsl:if test="$latex.is.draft=1">
					<xsl:call-template name="generate.latex.draft.preamble"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="(/set|/book|/article)[1]/@status='draft'">
					<xsl:call-template name="generate.latex.draft.preamble"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
  <!-- biblio format -->
  <xsl:template name="biblioentry.output.format">
		<xsl:param name="biblioentry.label"/>
		<xsl:param name="biblioentry.id"/>
		<xsl:choose>
			<xsl:when test="$latex.biblioentry.style='ieee' or $latex.biblioentry.style='IEEE'">
				<xsl:text>% -------------- biblioentry &#10;</xsl:text>
				<xsl:text>\bibitem</xsl:text>
				<xsl:text>{</xsl:text>
				<xsl:value-of select="$biblioentry.id"/>
				<xsl:text>}\docbooktolatexbibaux{</xsl:text>
				<xsl:call-template name="generate.label.id"/>
				<xsl:text>}{</xsl:text>
				<xsl:value-of select="$biblioentry.id"/>
				<xsl:text>}&#10;\hypertarget{</xsl:text>
				<xsl:call-template name="generate.label.id"/>
				<xsl:text>}&#10;</xsl:text>
				<xsl:apply-templates select="author|authorgroup" mode="bibliography.mode"/>
				<xsl:value-of select="$biblioentry.item.separator"/>
				<xsl:text>\emph{</xsl:text> <xsl:apply-templates select="title" mode="bibliography.mode"/><xsl:text>}</xsl:text>
				<xsl:for-each select="child::copyright|child::publisher|child::pubdate|child::pagenums|child::isbn">
					<xsl:value-of select="$biblioentry.item.separator"/>
					<xsl:apply-templates select="." mode="bibliography.mode"/>
				</xsl:for-each>
				<xsl:text>. </xsl:text>
				<xsl:text>&#10;&#10;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>% -------------- biblioentry &#10;</xsl:text>
				<xsl:choose>
					<xsl:when test="$biblioentry.label=''">
						<xsl:text>\bibitem</xsl:text> 
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>\bibitem[{</xsl:text>
						<xsl:call-template name="normalize-scape">
							<xsl:with-param name="string" select="$biblioentry.label"/>
						</xsl:call-template>
						<xsl:text>}]</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>{</xsl:text>
				<xsl:value-of select="$biblioentry.id"/>
				<xsl:text>}\docbooktolatexbibaux{</xsl:text>
				<xsl:call-template name="generate.label.id"/>
				<xsl:text>}{</xsl:text>
				<xsl:value-of select="$biblioentry.id"/>
				<xsl:text>}&#10;\hypertarget{</xsl:text>
				<xsl:call-template name="generate.label.id"/>
        <xsl:text>}&#10;</xsl:text>
				<xsl:apply-templates select="author|authorgroup" mode="bibliography.mode"/>
				<xsl:value-of select="$biblioentry.item.separator"/>
				<xsl:text>{\emph{</xsl:text> <xsl:apply-templates select="title" mode="bibliography.mode"/> <xsl:text>}}</xsl:text>
				<xsl:for-each select="child::copyright|child::publisher|child::pubdate|child::pagenums|child::isbn|child::editor|child::releaseinfo">
					<xsl:value-of select="$biblioentry.item.separator"/>
					<xsl:apply-templates select="." mode="bibliography.mode"/>
				</xsl:for-each>
				<xsl:text>.</xsl:text>
				<xsl:text>&#10;&#10;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

  <!-- fixes the placement of an \index command before a <para></para>
  which leads into a linebreak and a whitespace in the finished pdf -->
	<xsl:template match="indexterm">
		<xsl:if test="$latex.generate.indexterm='1'">
			<xsl:variable name="idxterm">
				<xsl:apply-templates mode="indexterm"/>
			</xsl:variable>

			<xsl:if test="@class and @zone">
				<xsl:message terminate="yes">Error: Only one attribute (@class or @zone) is in indexterm possible!</xsl:message>
			</xsl:if>

			<xsl:choose>
				<xsl:when test="@class='startofrange'">
					<xsl:text>\index{</xsl:text>
					<xsl:value-of select="$idxterm"/>
					<xsl:text>|(}</xsl:text>
				</xsl:when>
				<xsl:when test="@class='endofrange'">
					<xsl:choose>
						<xsl:when test="count(key('indexterm-range',@startref)) = 0">
							<xsl:message terminate="yes"><xsl:text>Error: No indexterm with </xsl:text>
							<xsl:text>id='</xsl:text><xsl:value-of select="@startref"/>
							<xsl:text>' found!</xsl:text>
							<xsl:text>  Check your attributs id/startref in your indexterms!</xsl:text>
							</xsl:message>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="thekey" select="key('indexterm-range',@startref)"/>
							<xsl:for-each select="$thekey[1]">
								<xsl:text>\index{</xsl:text>
								<xsl:apply-templates mode="indexterm"/>
								<xsl:text>|)}</xsl:text>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>\index{</xsl:text>
					<xsl:value-of select="$idxterm"/>
					<xsl:text>}%&#10;</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
  

</xsl:stylesheet>
