<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ditamsg="http://dita-ot.sourceforge.net/ns/200704/ditamsg"
                xmlns:related-links="http://dita-ot.sourceforge.net/ns/200709/related-links"
                xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
                xmlns:js="js"
                xmlns:util="util"
                exclude-result-prefixes="xs js util ditamsg related-links dita-ot">

  <xsl:import href="plugin:org.lwdita:xsl/dita2mdx.xsl"/>

  <xsl:template name="ast-attibutes"/>

  <xsl:variable name="codeblock-languge-prefix" as="xs:string?" select="'syntax-'"/>

  <xsl:template match="*" mode="chapterHead">
    <xsl:call-template name="getMeta"/>
  </xsl:template>

  <xsl:template name="getMeta">
    <xsl:variable name="fields" as="element()*">
      <xsl:call-template name="get-value">
        <xsl:with-param name="values" select="*[contains(@class, ' topic/title ')]"/>
      </xsl:call-template>
      <xsl:for-each select="*[contains(@class, ' topic/prolog ')] | /dita/*[1]/*[contains(@class, ' topic/prolog ')]">
        <xsl:call-template name="get-value">
          <xsl:with-param name="values" select="*[contains(@class, ' topic/author ')]"/>
        </xsl:call-template>
        <xsl:call-template name="get-value">
          <xsl:with-param name="values" select="*[contains(@class, ' topic/source ')]"/>
        </xsl:call-template>
        <xsl:call-template name="get-value">
          <xsl:with-param name="values" select="*[contains(@class, ' topic/publisher ')]"/>
        </xsl:call-template>
        <xsl:call-template name="get-value">
          <xsl:with-param name="values" select="*[contains(@class, ' topic/permissions ')]/@view"/>
          <xsl:with-param name="key" select="'permissions'"/>
        </xsl:call-template>
        <xsl:for-each select="*[contains(@class, ' topic/metadata ')]">
          <xsl:call-template name="get-value">
            <xsl:with-param name="values" select="*[contains(@class, ' topic/audience ')]"/>
          </xsl:call-template>
          <xsl:call-template name="get-value">
            <xsl:with-param name="values" select="*[contains(@class, ' topic/category ')]"/>
          </xsl:call-template>
          <xsl:call-template name="get-value">
            <xsl:with-param name="values" select="*[contains(@class, ' topic/keywords ')]/*[contains(@class, ' topic/keyword ')]"/>
          </xsl:call-template>
        </xsl:for-each>
        <xsl:call-template name="get-value">
          <xsl:with-param name="values" select="*[contains(@class, ' topic/resourceid ')]/@appid"/>
          <xsl:with-param name="key" select="'resourceid'"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>
    <xsl:if test="exists($fields)">
      <head>
        <map>
          <xsl:copy-of select="$fields"/>
        </map>
      </head>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/topic ')]/*[contains(@class, ' topic/title ')]">
    <xsl:param name="headinglevel" as="xs:integer">
      <xsl:choose>
        <xsl:when test="count(ancestor::*[contains(@class, ' topic/topic ')]) > 6">6</xsl:when>
        <xsl:otherwise><xsl:sequence select="count(ancestor::*[contains(@class, ' topic/topic ')])"/></xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:if test="$headinglevel gt 1">
      <header level="{$headinglevel}">
        <xsl:call-template name="commonattributes">
<!--          <xsl:with-param name="default-output-class">-->
<!--            <xsl:if test="$headinglevel eq 1 and name(..) ne 'topic'">-->
<!--              <xsl:value-of select="name(..)"/>-->
<!--            </xsl:if>-->
<!--          </xsl:with-param>-->
        </xsl:call-template>
        <xsl:attribute name="id" select="../@id"/>
        <xsl:apply-templates/>
      </header>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[@audience | @product | @platform | @otherprops]" priority="1000">
    <component name="Profile">
      <xsl:for-each select="@audience | @product | @platform | @otherprops">
        <prop name="{name()}">
          <js:array>
            <xsl:for-each select="tokenize(normalize-space(.), '\s+')">
              <js:string>
                <xsl:value-of select="."/>
              </js:string>
            </xsl:for-each>
          </js:array>
        </prop>
      </xsl:for-each>
      <xsl:next-match/>
    </component>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/note ')]" name="topic.note">
    <xsl:variable name="type" select="if (exists(@type)) then util:capitalize(@type) else 'Note'"/>
    <component type="{$type}">
      <xsl:apply-templates/>
    </component>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/pre ')]" name="topic.pre">
    <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
    <xsl:call-template name="spec-title-nospace"/>
    <codeblock>
      <xsl:attribute name="xml:space">preserve</xsl:attribute>
      <xsl:call-template name="commonattributes"/>
      <xsl:call-template name="setscale"/>
      <xsl:call-template name="setidaname"/>
      <xsl:apply-templates mode="text-only"/>
    </codeblock>
    <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
  </xsl:template>

  <!-- task -->

  <xsl:template match="*[contains-token(@class, 'task/steps')]" name="task.steps">
    <xsl:apply-templates select="." mode="generate-task-label">
      <xsl:with-param name="use-label">
        <xsl:call-template name="getVariable">
          <xsl:with-param name="id" select="'task_procedure'"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:apply-templates>
    <component name="Steps">
      <xsl:apply-templates/>
    </component>
  </xsl:template>

  <xsl:template match="*[contains-token(@class, 'task/steps')]/*[contains-token(@class, 'task/step')]" >
    <component name="Step">
      <prop name="title">
        <xsl:attribute name="value">
          <xsl:variable name="ast" as="item()*">
            <xsl:apply-templates select="*[contains-token(@class, 'task/cmd')]"/>
          </xsl:variable>
          <!-- TODO: only allow strong, emph, or code -->
          <xsl:apply-templates select="$ast" mode="ast"/>
        </xsl:attribute>
      </prop>
      <xsl:call-template name="commonattributes"/>
      <xsl:call-template name="setidaname"/>
      <xsl:apply-templates select="* except *[contains-token(@class, 'task/cmd')]"/>
    </component>
  </xsl:template>

  <!-- utils -->

  <xsl:function name="util:capitalize" as="xs:string">
    <xsl:param name="text" as="xs:string"/>
    <xsl:value-of select="concat(upper-case(substring($text, 1, 1)),
                                 substring($text, 2))"/>
  </xsl:function>

</xsl:stylesheet>
