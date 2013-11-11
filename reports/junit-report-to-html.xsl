<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="testsuites">
        <div>
            <ul class="symbolSummary">
                <xsl:for-each select="testsuite/testcase">
                    <xsl:choose>
                        <xsl:when test="failure"><li class="failed"/></xsl:when>
                        <xsl:when test="error"><li class="failed"/></xsl:when>
                        <xsl:otherwise><li class="passed"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </ul>
            <div class="results">
                <div class="summary">
                    <xsl:for-each select="testsuite">
                        <div>
                            <xsl:attribute name="class">
                                <xsl:choose>
                                    <xsl:when test="testcase/failure">suite failed</xsl:when>
                                    <xsl:when test="testcase/error">suite failed</xsl:when>
                                    <xsl:otherwise>suite passed</xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <a class="description"><xsl:value-of select="@name"/> (<xsl:value-of select="@time"/>s)</a>
                            <xsl:for-each select="testcase">
                                <div>
                                    <xsl:attribute name="class">
                                        <xsl:choose>
                                            <xsl:when test="failure">specSummary failed</xsl:when>
                                            <xsl:when test="error">specSummary failed</xsl:when>
                                            <xsl:otherwise>specSummary passed</xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                    <a class="description"><xsl:value-of select="@name"/> <xsl:if test="@time > 0">(<xsl:value-of select="time"/>s)</xsl:if></a>
                                    <xsl:for-each select="failure">
                                        <div class="stackTrace"><xsl:value-of select="text()"/></div>
                                    </xsl:for-each>
                                    <xsl:for-each select="error">
                                        <div class="stackTrace"><xsl:value-of select="text()"/></div>
                                    </xsl:for-each>
                                </div>
                            </xsl:for-each>
                        </div>
                    </xsl:for-each>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>