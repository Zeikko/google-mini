<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <!-- Template to produce results in JSON format
    ** Philip McAllister, 01/10/2012
    ** icerunner@gmail.com
    ** Released under Creative Commons CC BY-SA 3.0
    ** The templates json.xsl and jsonp.xsl are released under Creative Commons license "Attribution-ShareAlike 3.0 Unported" http://creativecommons.org/licenses/by-sa/3.0/
    ** Please share any improvements or alterations you make to this template and please leave these comments in.
    -->

    <xsl:output method="text"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="GSP"/>
    </xsl:template>
    
    <xsl:template match="GSP">
        <xsl:text disable-output-escaping="yes">{    "query": "</xsl:text>
        <xsl:call-template name="replace_apos">
            <xsl:with-param name="string" select="Q" />
        </xsl:call-template>
        <xsl:text>",
        </xsl:text>

        <xsl:if test="GM">
            <xsl:text disable-output-escaping="yes">    "keymatch": [
            </xsl:text>     
            <xsl:apply-templates select="GM" />
            <xsl:text>    ],
            </xsl:text>
        </xsl:if>

            <xsl:text disable-output-escaping="yes">    "dynamic_navigation": [
            </xsl:text>     
            <xsl:apply-templates select="/GSP/RES/PARM" />
            <xsl:text>    ],
            </xsl:text>
      
        <xsl:apply-templates select="RES" />
    
        <xsl:call-template name="results_navigation_wrapper">
            <xsl:with-param name="prev" select="RES/NB/PU"/>
            <xsl:with-param name="next" select="RES/NB/NU"/>
            <xsl:with-param name="view_begin" select="RES/@SN"/>
            <xsl:with-param name="view_end" select="RES/@EN"/>
            <xsl:with-param name="guess" select="RES/M"/>
        </xsl:call-template>
    
        <xsl:text disable-output-escaping="yes">
            }
</xsl:text>  
    </xsl:template>
    
    <!-- Results settings -->
    <xsl:template name="results_navigation_wrapper">
        <xsl:param name="prev"/>
        <xsl:param name="next"/>
        <xsl:param name="view_begin"/>
        <xsl:param name="view_end"/>
        <xsl:param name="guess"/>

        <xsl:text disable-output-escaping="yes">
            "results_nav": {
            "total_results": "</xsl:text>
        <xsl:value-of select="$guess" />
        <xsl:text>",
            "results_start": "</xsl:text>
        <xsl:value-of select="$view_begin" />
        <xsl:text>",
            "results_end": "</xsl:text>
        <xsl:value-of select="$view_end" />
        <xsl:text>",
            "current_view": "</xsl:text>
        <xsl:value-of select="$view_begin - 1" />
        <xsl:text>"</xsl:text>
        <xsl:if test="/GSP/RES/NB/PU">
            <xsl:text>,
                "have_prev": "1"</xsl:text>
        </xsl:if>
        <xsl:if test="/GSP/RES/NB/NU">
            <xsl:text>,
                "have_next": "1"</xsl:text>
        </xsl:if>
        <xsl:text>
            }</xsl:text>

    </xsl:template>

    <!-- Dynamic Navigation -->
    <xsl:template match="PARM">
        <xsl:for-each select="PMT">
        <xsl:for-each select="PV[position() &lt; 11 and @C != '0']">
        <xsl:text disable-output-escaping="yes">    {
        </xsl:text>
        <xsl:text disable-output-escaping="yes">        "name": "</xsl:text>
        <xsl:call-template name="replace_apos">
            <xsl:with-param name="string" select="@V" />
        </xsl:call-template>
        <xsl:text disable-output-escaping="yes">",
            "count": "</xsl:text>
	<xsl:value-of select='@C'/>
        <xsl:text disable-output-escaping="yes">"
            }</xsl:text>
        <xsl:if test="position() != last()">
            <xsl:text>,
            </xsl:text>
        </xsl:if>
	</xsl:for-each>
        <xsl:if test="position() != last()">
            <xsl:text>,
            </xsl:text>
        </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- Keymatch -->
    <xsl:template match="GM">
        <xsl:text disable-output-escaping="yes">    {
        </xsl:text>
        <xsl:text disable-output-escaping="yes">        "title": "</xsl:text>
        <xsl:value-of select="GD" />
        <xsl:text disable-output-escaping="yes">",
            "url": "</xsl:text>
        <xsl:value-of select="GL" />
        <xsl:text disable-output-escaping="yes">"
            }</xsl:text>
        <xsl:if test="position() != last()">
            <xsl:text>,
            </xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="RES">  
        <xsl:text disable-output-escaping="yes">    "results": [</xsl:text>
        <xsl:apply-templates select="R"/>
        <xsl:text disable-output-escaping="yes">
            ],</xsl:text>
    </xsl:template>

    <xsl:template match="R">         
        <xsl:text disable-output-escaping="yes">
            {
        </xsl:text>
        <xsl:apply-templates select="U"/>
        <xsl:apply-templates select="T"/>
        <xsl:apply-templates select="S"/>
        <xsl:apply-templates select="HAS"/>
                
        <xsl:if test="string(@MIME)">
            <xsl:text disable-output-escaping="yes">,
                "mime": "</xsl:text>
            <xsl:value-of select ="@MIME" />
            <xsl:text disable-output-escaping="yes">"</xsl:text>
        </xsl:if>
        
        <xsl:if test="string(FS[@NAME='date']/@VALUE)">
            <xsl:text disable-output-escaping="yes">,
                "date": "</xsl:text>
            <xsl:value-of select ="FS[@NAME='date']/@VALUE" />
            <xsl:text disable-output-escaping="yes">"</xsl:text>
        </xsl:if>

        <!--Include image meta tag in results list-->
        <xsl:for-each select="MT">
            <xsl:if test="@N='gsa_image' and @V!=''">
                <xsl:text disable-output-escaping="yes">,
                    "image": "</xsl:text>
                <xsl:value-of select ="@V" />
                <xsl:text disable-output-escaping="yes">"</xsl:text>
            </xsl:if>
        </xsl:for-each>

        <!--Include article-id meta tag in results list-->
        <xsl:for-each select="MT">
            <xsl:if test="@N='article-id' and @V!=''">
                <xsl:text disable-output-escaping="yes">,
                    "articleId": "</xsl:text>
                <xsl:value-of select ="@V" />
                <xsl:text disable-output-escaping="yes">"</xsl:text>
            </xsl:if>
        </xsl:for-each>

        <!--Include authors meta tag in results list-->
        <xsl:for-each select="MT">
            <xsl:if test="@N='authors' and @V!=''">
                <xsl:text disable-output-escaping="yes">,
                    "authors": "</xsl:text>
                <xsl:value-of select ="@V" />
                <xsl:text disable-output-escaping="yes">"</xsl:text>
            </xsl:if>
        </xsl:for-each>

        <!--Include category meta tag in results list-->
        <xsl:for-each select="MT">
            <xsl:if test="@N='category' and @V!=''">
                <xsl:text disable-output-escaping="yes">,
                    "categories": "</xsl:text>
                <xsl:value-of select ="@V" />
                <xsl:text disable-output-escaping="yes">"</xsl:text>
            </xsl:if>
        </xsl:for-each>

        <!--Include program-title meta tag in results list-->
        <xsl:for-each select="MT">
            <xsl:if test="@N='program-title' and @V!=''">
                <xsl:text disable-output-escaping="yes">,
                    "programTitle": "</xsl:text>
                <xsl:value-of select ="@V" />
                <xsl:text disable-output-escaping="yes">"</xsl:text>
            </xsl:if>
        </xsl:for-each>

        <!--Include program-description meta tag in results list-->
        <xsl:for-each select="MT">
            <xsl:if test="@N='program-description' and @V!=''">
                <xsl:text disable-output-escaping="yes">,
                    "programDescription": "</xsl:text>
                <xsl:value-of select ="@V" />
                <xsl:text disable-output-escaping="yes">"</xsl:text>
            </xsl:if>
        </xsl:for-each>

        <!--Include category meta tag in results list-->
        <xsl:for-each select="MT">
            <xsl:if test="@N='media' and @V!=''">
                <xsl:text disable-output-escaping="yes">,
                    "media": "</xsl:text>
                <xsl:value-of select ="@V" />
                <xsl:text disable-output-escaping="yes">"</xsl:text>
            </xsl:if>
        </xsl:for-each>

        <!--Include media-start-date meta tag in results list-->
        <xsl:for-each select="MT">
            <xsl:if test="@N='media-start-date' and @V!=''">
                <xsl:text disable-output-escaping="yes">,
                    "mediaStartDate": "</xsl:text>
                <xsl:value-of select ="@V" />
                <xsl:text disable-output-escaping="yes">"</xsl:text>
            </xsl:if>
        </xsl:for-each>

        <!--Include media-expiration-date meta tag in results list-->
        <xsl:for-each select="MT">
            <xsl:if test="@N='media-expiration-date' and @V!=''">
                <xsl:text disable-output-escaping="yes">,
                    "mediaExpirationDate": "</xsl:text>
                <xsl:value-of select ="@V" />
                <xsl:text disable-output-escaping="yes">"</xsl:text>
            </xsl:if>
        </xsl:for-each>

        <!--Include areena-channel meta tag in results list-->
        <xsl:for-each select="MT">
            <xsl:if test="@N='areena-channel' and @V!=''">
                <xsl:text disable-output-escaping="yes">,
                    "areenaChannel": "</xsl:text>
                <xsl:value-of select ="@V" />
                <xsl:text disable-output-escaping="yes">"</xsl:text>
            </xsl:if>
        </xsl:for-each>

        <!--Include areena-service meta tag in results list-->
        <xsl:for-each select="MT">
            <xsl:if test="@N='areena-service' and @V!=''">
                <xsl:text disable-output-escaping="yes">,
                    "areenaService": "</xsl:text>
                <xsl:value-of select ="@V" />
                <xsl:text disable-output-escaping="yes">"</xsl:text>
            </xsl:if>
        </xsl:for-each>

        <!--Include page-type meta tag in results list-->
        <xsl:for-each select="MT">
            <xsl:if test="@N='page-type' and @V!=''">
                <xsl:text disable-output-escaping="yes">,
                    "pageType": "</xsl:text>
                <xsl:value-of select ="@V" />
                <xsl:text disable-output-escaping="yes">"</xsl:text>
            </xsl:if>
        </xsl:for-each>

        <!--Include serie-id meta tag in results list-->
        <xsl:for-each select="MT">
            <xsl:if test="@N='serie-id' and @V!=''">
                <xsl:text disable-output-escaping="yes">,
                    "serieId": "</xsl:text>
                <xsl:value-of select ="@V" />
                <xsl:text disable-output-escaping="yes">"</xsl:text>
            </xsl:if>
        </xsl:for-each>

        <!--Include program-id meta tag in results list-->
        <xsl:for-each select="MT">
            <xsl:if test="@N='program-id' and @V!=''">
                <xsl:text disable-output-escaping="yes">,
                    "programId": "</xsl:text>
                <xsl:value-of select ="@V" />
                <xsl:text disable-output-escaping="yes">"</xsl:text>
            </xsl:if>
        </xsl:for-each>

        <!--Include original-title meta tag in results list-->
        <xsl:for-each select="MT">
            <xsl:if test="@N='original-title' and @V!=''">
                <xsl:text disable-output-escaping="yes">,
                    "originalTitle": "</xsl:text>
                <xsl:value-of select ="@V" />
                <xsl:text disable-output-escaping="yes">"</xsl:text>
            </xsl:if>
        </xsl:for-each>

        <!--Include original-description meta tag in results list-->
        <xsl:for-each select="MT">
            <xsl:if test="@N='original-description' and @V!=''">
                <xsl:text disable-output-escaping="yes">,
                    "originalDescription": "</xsl:text>
                <xsl:value-of select ="@V" />
                <xsl:text disable-output-escaping="yes">"</xsl:text>
            </xsl:if>
        </xsl:for-each>

        <!--Include stream-starts meta tag in results list-->
        <xsl:for-each select="MT">
            <xsl:if test="@N='stream-starts' and @V!=''">
                <xsl:text disable-output-escaping="yes">,
                    "streamStarts": "</xsl:text>
                <xsl:value-of select ="@V" />
                <xsl:text disable-output-escaping="yes">"</xsl:text>
            </xsl:if>
        </xsl:for-each>

        <!--Include page-views meta tag in results list-->
        <xsl:for-each select="MT">
            <xsl:if test="@N='page-views' and @V!=''">
                <xsl:text disable-output-escaping="yes">,
                    "pageViews": "</xsl:text>
                <xsl:value-of select ="@V" />
                <xsl:text disable-output-escaping="yes">"</xsl:text>
            </xsl:if>
        </xsl:for-each>

        <!--Include keywords meta tag in results list-->
        <xsl:for-each select="MT">
            <xsl:if test="@N='keywords' and @V!=''">
                <xsl:text disable-output-escaping="yes">,
                    "keywords": "</xsl:text>
				        <xsl:call-template name="replace_apos">
				            <xsl:with-param name="string" select="@V" />
				        </xsl:call-template>
                <xsl:text disable-output-escaping="yes">"</xsl:text>
            </xsl:if>
        </xsl:for-each>

        <xsl:text disable-output-escaping="yes">
            }</xsl:text>
        <xsl:if test="position() != last()">
            <xsl:text>,</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="U">
        <xsl:text disable-output-escaping="yes">            "url": "</xsl:text>
        <xsl:value-of select="." />
        <xsl:text disable-output-escaping="yes">",
        </xsl:text>
    </xsl:template>

    <xsl:template match="T">
        <xsl:text disable-output-escaping="yes">            "title": "</xsl:text>
        <xsl:call-template name="replace_apos">
            <xsl:with-param name="string" select="." />
        </xsl:call-template>
        <xsl:text disable-output-escaping="yes">",
        </xsl:text>
    </xsl:template>

    <xsl:template match="S">
        <xsl:text disable-output-escaping="yes">            "summary": "</xsl:text>
        <xsl:variable name="replaced_apos">
            <xsl:call-template name="replace_apos">
                <xsl:with-param name="string" select="." />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="replaced_br">
            <xsl:call-template name="replace_br">
                <xsl:with-param name="string" select="$replaced_apos" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="escape_backslash">
            <xsl:with-param name="string" select="$replaced_br" />
        </xsl:call-template>
        <xsl:text disable-output-escaping="yes">"</xsl:text>
    </xsl:template>
    
    <xsl:template match="HAS">
        <xsl:if test="string(C/@SZ)">
            <xsl:text disable-output-escaping="yes">,
                "size": "</xsl:text>
            <xsl:value-of select="C/@SZ" />
            <xsl:text disable-output-escaping="yes">"</xsl:text>
        </xsl:if>
    </xsl:template>
    

    <!-- *** Find and replace *** -->
    <xsl:template name="replace_string">
        <xsl:param name="find"/>
        <xsl:param name="replace"/>
        <xsl:param name="string"/>
        <xsl:choose>
            <xsl:when test="contains($string, $find)">
                <xsl:value-of select="substring-before($string, $find)" />
                <xsl:value-of select="$replace" />
                <xsl:call-template name="replace_string">
                    <xsl:with-param name="find" select="$find"/>
                    <xsl:with-param name="replace" select="$replace"/>
                    <xsl:with-param name="string"
                                    select="substring-after($string, $find)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="replace_apos">
        <xsl:param name="string"/>
        <xsl:variable name="apos">"</xsl:variable>
        <xsl:call-template name="replace_string">
            <xsl:with-param name="string" select="$string"/>
            <xsl:with-param name="find" select="$apos"/>
            <xsl:with-param name="replace" select="'&amp;#34;'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="replace_br">
        <xsl:param name="string"/>
        <xsl:call-template name="replace_string">
            <xsl:with-param name="string" select="$string"/>
            <xsl:with-param name="find" select="'&lt;br&gt;'"/>
            <xsl:with-param name="replace" select="''"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="escape_backslash">
        <xsl:param name="string"/>
        <xsl:call-template name="replace_string">
            <xsl:with-param name="string" select="$string"/>
            <xsl:with-param name="find" select="'\'"/>
            <xsl:with-param name="replace" select="'\\'"/>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
