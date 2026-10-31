<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:js="js"
                version="3.0"
                exclude-result-prefixes="xs js">

  <xsl:output method="json"/>

  <xsl:template match="/">
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <xsl:template match="*[contains-token(@class, 'map/map')]" as="map(*)">
    <xsl:variable name="pages" as="item()*">
      <xsl:apply-templates select="*[contains-token(@class, 'map/topicref')]"/>
    </xsl:variable>
    <xsl:sequence select="map {
      '$schema': 'https://mintlify.com/docs.json',
      'theme': 'mint',
      'name': 'Com.elovirta.mitlify',
      'colors': map {
        'primary': '#16A34A'
      },
      'navigation': map {
(:        'groups': array {
          map {
            'group': 'group title',
            'pages': array {
                $pages
              }
          }
        } :)
        'pages': array {
          $pages
        }
      }
    }"/>
  </xsl:template>

  <xsl:template match="*[contains-token(@class, 'map/topicref')]
                        [@toc = 'no' or @processing-role = 'resource-only']"/>

  <xsl:template match="*[contains-token(@class, 'map/topicref')]
                        [empty(@toc) or @toc = 'yes']
                        [empty(@processing-role) or @processing-role = 'normal']">
    <xsl:variable name="items" select="*[contains-token(@class, 'map/topicref')]"/>
    <xsl:variable name="title" as="node()?"
                  select="(*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')],
                           @navtitle,
                           *[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/linktext ') or contains(@class, ' map/linktext ')])[1]"/>
    <xsl:variable name="id" as="xs:string?" select="if (exists(@href)) then replace(@href, '\.[^\.]+?$','') else ()"/>
    <xsl:choose>
      <!-- FIXME: Mintlify requires a workaround for external pages in navigation, skipping for now -->
      <xsl:when test="@scope = 'external'">
        <xsl:apply-templates select="$items"/>
      </xsl:when>
      <xsl:when test="empty($id) and empty($title)">
        <xsl:apply-templates select="$items"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="profiles" as="attribute()*" select="@audience, @product, @platform, @otherprops"/>
        <xsl:choose>
          <xsl:when test="$items">
            <xsl:variable name="pages" as="item()*">
              <xsl:apply-templates select="$items"/>
            </xsl:variable>
            <xsl:sequence select="map {
              'group': normalize-space($title),
              'root': $id,
              'pages': array {
                $pages
              }
            }"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="$id"/>
          </xsl:otherwise>
        </xsl:choose>
        <!--
        <xsl:if test="$profiles">
          <js:entry name="customProps">
            <js:object>
              <js:entry name="profile">
                <js:object>
                  <xsl:for-each select="$profiles">
                    <js:entry name="{name()}">
                      <js:array>
                        <xsl:for-each select="tokenize(normalize-space())">
                          <js:string>
                            <xsl:value-of select="."/>
                          </js:string>
                        </xsl:for-each>
                      </js:array>
                    </js:entry>
                  </xsl:for-each>
                </js:object>
              </js:entry>
            </js:object>
          </js:entry>
        </xsl:if>
        -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
