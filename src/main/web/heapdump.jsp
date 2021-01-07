<!--
- Copyright (C) 2019 Ignite Realtime Foundation. All rights reserved.
-
- Licensed under the Apache License, Version 2.0 (the "License");
- you may not use this file except in compliance with the License.
- You may obtain a copy of the License at
-
- http://www.apache.org/licenses/LICENSE-2.0
-
- Unless required by applicable law or agreed to in writing, software
- distributed under the License is distributed on an "AS IS" BASIS,
- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
- See the License for the specific language governing permissions and
- limitations under the License.
-->
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page errorPage="error.jsp" %>
<%@ page import="org.jivesoftware.util.CookieUtils" %>
<%@ page import="org.jivesoftware.util.ParamUtils" %>
<%@ page import="org.jivesoftware.util.StringUtils" %>
<%@ page import="org.igniterealtime.openfire.plugin.heapdump.HeapDumpPlugin" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<jsp:useBean id="webManager" class="org.jivesoftware.util.WebManager"  />
<% webManager.init(request, response, session, application, out ); %>
<%
    String success = request.getParameter("success");
    boolean create = request.getParameter("create") != null;

    String error = null;

    final Cookie csrfCookie = CookieUtils.getCookie( request, "csrf");
    String csrfParam = ParamUtils.getParameter( request, "csrf");

    if (create)
    {
        if ( csrfCookie == null || csrfParam == null || !csrfCookie.getValue().equals( csrfParam ) )
        {
            error = "csrf";
        }
        else
        {
            final String outputFile = "./openfire-heapdump-" + System.currentTimeMillis() + ".hprof";
            final boolean live = true;
            webManager.logEvent( "Heap-dump generation started.", "Location: " + outputFile);
            new Thread(new Runnable() {
                @Override
                public void run() {
                    try {
                        Thread.sleep(500); // Give this page time to render.
                        HeapDumpPlugin.dumpHeap(outputFile, live);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }).start();
            response.sendRedirect( "heapdump.jsp?success=true" );
            return;
        }
    }

    csrfParam = StringUtils.randomString( 15 );
    CookieUtils.setCookie(request, response, "csrf", csrfParam, -1);
    pageContext.setAttribute( "csrf", csrfParam) ;
%>
<html>
<head>
    <title><fmt:message key="heapdump.page.title"/></title>
    <meta name="pageID" content="heapdump"/>
    <style>
        .disabled {
            pointer-events: none;
            background: lightgrey;
        }
    </style>
</head>
<body>

<% if (error != null) { %>

<div class="jive-error">
    <table cellpadding="0" cellspacing="0" border="0">
        <tbody>
        <tr><td class="jive-icon"><img src="/images/error-16x16.gif" width="16" height="16" border="0" alt=""></td>
            <td class="jive-icon-label">
                <% if ( "csrf".equalsIgnoreCase( error )  ) { %>
                <fmt:message key="global.csrf.failed" />
                <% } else { %>
                <fmt:message key="admin.error" />: <c:out value="error"></c:out>
                <% } %>
            </td></tr>
        </tbody>
    </table>
</div><br>

<%  } %>


<%  if (success != null) { %>

<div class="jive-info">
    <table cellpadding="0" cellspacing="0" border="0">
        <tbody>
        <tr><td class="jive-icon"><img src="/images/info-16x16.gif" width="16" height="16" border="0" alt=""></td>
            <td class="jive-info-text">
                <fmt:message key="heapdump.page.started" />
            </td></tr>
        </tbody>
    </table>
</div><br>

<%  } %>

<p>
    <fmt:message key="heapdump.page.description"/>
</p>

<div class="jive-warning">
    <table cellpadding="0" cellspacing="0" border="0">
        <tbody>
        <tr><td class="jive-icon"><img src="/images/warning-16x16.gif" width="16" height="16" border="0" alt=""></td>
            <td class="jive-warning-text">
                <fmt:message key="heapdump.page.warning" />
            </td></tr>
        </tbody>
    </table>
</div><br>
<br>

<div class="jive-contentBoxHeader"><fmt:message key="heapdump.page.heapdump.header" /></div>
<div class="jive-contentBox">

    <p><fmt:message key="heapdump.page.heapdump.description" /></p>

    <form name="heapDumpConfig">
        <input type="hidden" name="csrf" value="${csrf}">

        <table width="80%" cellpadding="3" cellspacing="0" border="0">
            <tr>
                <td width="1%"></td>
                <td width="99%">
                    <input type="submit" name="create" value="<fmt:message key="heapdump.page.heapdump.button" />">
                </td>
            </tr>
        </table>
    </form>

</div>

</body>
</html>
