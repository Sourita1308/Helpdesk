<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="header.jsp">
    <jsp:param name="title" value="KB Article: ${article.title}" />
    <jsp:param name="subtitle" value="Verified Technical Runbook — Category: ${article.category}" />
    <jsp:param name="active" value="kb" />
</jsp:include>

<div class="card" style="max-width: 920px; margin: 0 auto;">
    <div class="card-header">
        <div style="display: flex; align-items: center; gap: 10px;">
            <c:choose>
                <c:when test="${article.category == 'Hardware'}"><span class="badge-cat badge-cat-hardware"><i data-lucide="cpu" class="icon-xs"></i> Hardware</span></c:when>
                <c:when test="${article.category == 'Software'}"><span class="badge-cat badge-cat-software"><i data-lucide="code" class="icon-xs"></i> Software</span></c:when>
                <c:when test="${article.category == 'Network'}"><span class="badge-cat badge-cat-network"><i data-lucide="wifi" class="icon-xs"></i> Network</span></c:when>
                <c:when test="${article.category == 'Access & Security'}"><span class="badge-cat badge-cat-access"><i data-lucide="shield" class="icon-xs"></i> Security</span></c:when>
                <c:otherwise><span class="badge-cat badge-cat-infra">${article.category}</span></c:otherwise>
            </c:choose>
            <span style="font-size: 0.8rem; color: var(--text-muted); display: inline-flex; align-items: center; gap: 8px;">
                <span>By <strong>${article.authorName}</strong></span> &bull; 
                <span style="font-family: var(--font-mono);">${article.createdAt}</span> &bull; 
                <span style="display: inline-flex; align-items: center; gap: 4px; color: #818cf8;"><i data-lucide="eye" class="icon-xs"></i> ${article.viewCount} views</span>
            </span>
        </div>
        <a href="${pageContext.request.contextPath}/kb" class="btn btn-secondary btn-sm">
            <i data-lucide="arrow-left" class="icon-xs"></i>
            <span>Back to KB</span>
        </a>
    </div>
    <div class="card-body">
        <h2 style="font-size: 1.45rem; color: #fff; margin-bottom: 24px; font-weight: 800; letter-spacing: -0.02em;">
            ${article.title}
        </h2>

        <!-- Symptoms Box -->
        <div style="margin-bottom: 24px;">
            <div style="font-size: 0.78rem; font-weight: 700; color: #fbbf24; text-transform: uppercase; margin-bottom: 8px; display: flex; align-items: center; gap: 6px;">
                <i data-lucide="alert-circle" class="icon-sm text-warning"></i>
                <span>Reported Symptoms &amp; Error Behavior:</span>
            </div>
            <div style="background: var(--bg-surface-elevated); padding: 16px 20px; border-radius: var(--radius-sm); border-left: 3px solid #fbbf24; border-top: 1px solid var(--border-subtle); border-right: 1px solid var(--border-subtle); border-bottom: 1px solid var(--border-subtle); white-space: pre-wrap; font-size: 0.94rem; line-height: 1.6; color: #e2e8f0;">${article.symptoms}</div>
        </div>

        <!-- Root Cause Box -->
        <div style="margin-bottom: 24px;">
            <div style="font-size: 0.78rem; font-weight: 700; color: #f87171; text-transform: uppercase; margin-bottom: 8px; display: flex; align-items: center; gap: 6px;">
                <i data-lucide="search" class="icon-sm text-danger"></i>
                <span>Root Cause Diagnostic:</span>
            </div>
            <div style="background: var(--bg-surface-elevated); padding: 16px 20px; border-radius: var(--radius-sm); border-left: 3px solid #f87171; border-top: 1px solid var(--border-subtle); border-right: 1px solid var(--border-subtle); border-bottom: 1px solid var(--border-subtle); white-space: pre-wrap; font-size: 0.94rem; line-height: 1.6; color: #e2e8f0;">${article.rootCause}</div>
        </div>

        <!-- Step-by-Step Resolution Box -->
        <div style="margin-bottom: 24px;">
            <div style="font-size: 0.78rem; font-weight: 700; color: #34d399; text-transform: uppercase; margin-bottom: 8px; display: flex; align-items: center; gap: 6px;">
                <i data-lucide="check-circle-2" class="icon-sm text-success"></i>
                <span>Step-by-Step Runbook Procedures:</span>
            </div>
            <div style="background: rgba(16,185,129,0.06); border: 1px solid rgba(16,185,129,0.25); border-left: 3px solid #10b981; padding: 20px 24px; border-radius: var(--radius-sm); white-space: pre-wrap; font-size: 0.96rem; line-height: 1.7; color: #f8fafc; font-family: inherit;">${article.resolutionSteps}</div>
        </div>

        <c:if test="${not empty article.sourceTicketId}">
            <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-subtle); font-size: 0.82rem; color: var(--text-muted); display: flex; align-items: center; gap: 6px;">
                <i data-lucide="link" class="icon-xs"></i>
                <span>Derived from resolved incident ticket:</span>
                <a href="${pageContext.request.contextPath}/tickets/view?id=${article.sourceTicketId}" style="color: #818cf8; text-decoration: none; font-weight: 700; font-family: var(--font-mono);">
                    #${article.sourceTicketId} →
                </a>
            </div>
        </c:if>
    </div>
</div>

<jsp:include page="footer.jsp" />
