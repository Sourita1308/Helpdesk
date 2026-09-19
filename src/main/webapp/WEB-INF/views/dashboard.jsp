<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="header.jsp">
    <jsp:param name="title" value="IT Operations Dashboard" />
    <jsp:param name="subtitle" value="Real-time Helpdesk Queue, SLA Timers &amp; Asset Status" />
    <jsp:param name="active" value="dashboard" />
</jsp:include>

<!-- Database Engine Status Notification if Fallback -->
<c:if test="${isFallback}">
    <div class="alert-banner info">
        <i data-lucide="info" class="alert-icon"></i>
        <div>
            <strong>Local Mode Active:</strong> Operating seamlessly with embedded MySQL-compatible engine.
            To connect directly to your local MySQL 8.0 server, update credentials in <code>src/main/resources/db.properties</code>.
        </div>
    </div>
</c:if>

<!-- Metrics Overview -->
<div class="stats-grid">
    <div class="stat-card primary">
        <div class="stat-card-header">
            <span class="stat-card-label">First-Line Queue</span>
            <div class="stat-card-icon-wrap">
                <i data-lucide="inbox" class="icon-md"></i>
            </div>
        </div>
        <div class="stat-card-value">${metrics.firstLineQueue != null ? metrics.firstLineQueue : 0}</div>
        <div class="stat-card-sub">Active triage &amp; intake queue</div>
    </div>

    <div class="stat-card purple">
        <div class="stat-card-header">
            <span class="stat-card-label">Second-Line Escalated</span>
            <div class="stat-card-icon-wrap">
                <i data-lucide="flame" class="icon-md"></i>
            </div>
        </div>
        <div class="stat-card-value">${metrics.escalatedTickets != null ? metrics.escalatedTickets : 0}</div>
        <div class="stat-card-sub">Routing to Tier-2 engineers</div>
    </div>

    <div class="stat-card danger">
        <div class="stat-card-header">
            <span class="stat-card-label">SLA Breached</span>
            <div class="stat-card-icon-wrap">
                <i data-lucide="alert-triangle" class="icon-md"></i>
            </div>
        </div>
        <div class="stat-card-value">${metrics.breachedTickets != null ? metrics.breachedTickets : 0}</div>
        <div class="stat-card-sub">Deadline exceeded — urgent action</div>
    </div>

    <div class="stat-card success">
        <div class="stat-card-header">
            <span class="stat-card-label">Resolved Issues</span>
            <div class="stat-card-icon-wrap">
                <i data-lucide="check-circle" class="icon-md"></i>
            </div>
        </div>
        <div class="stat-card-value">${metrics.resolvedCount != null ? metrics.resolvedCount : 0}</div>
        <div class="stat-card-sub">Ready for KB article conversion</div>
    </div>
</div>

<!-- Repeat-Issue Analysis Alert Banner if any -->
<c:if test="${not empty repeatAssets}">
    <div class="alert-banner warning" style="margin-bottom: 24px; justify-content: space-between;">
        <div style="display: flex; align-items: center; gap: 12px;">
            <i data-lucide="refresh-cw" class="alert-icon text-warning"></i>
            <div>
                <strong>Repeat-Issue Alert:</strong> <strong>${repeatAssets.size()}</strong> asset(s) have logged 2 or more incidents. Suspected hardware degradation or license faults.
            </div>
        </div>
        <a href="${pageContext.request.contextPath}/assets/repeat-issues" class="btn btn-secondary btn-sm">
            <span>Inspect Repeat Issues</span>
            <i data-lucide="arrow-right" class="icon-xs"></i>
        </a>
    </div>
</c:if>

<!-- Active Helpdesk Queue Table -->
<div class="card">
    <div class="card-header">
        <div class="card-title">
            <i data-lucide="activity" class="icon-md" style="color: #818cf8;"></i>
            <span>Live Helpdesk Queue &amp; SLA Monitor</span>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/tickets" class="btn btn-secondary btn-sm">
                <span>View All Tickets (${metrics.totalTickets})</span>
                <i data-lucide="chevron-right" class="icon-xs"></i>
            </a>
        </div>
    </div>
    <div class="table-responsive">
        <table class="data-table">
            <thead>
                <tr>
                    <th class="nowrap">Ticket #</th>
                    <th>Issue Summary</th>
                    <th class="nowrap">Category</th>
                    <th class="nowrap">Priority</th>
                    <th class="nowrap">Status</th>
                    <th class="nowrap">Tier / Assignee</th>
                    <th class="nowrap">Live SLA Timer</th>
                    <th class="nowrap">Asset Link</th>
                    <th class="nowrap">Action</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="t" items="${recentTickets}">
                    <tr>
                        <td class="nowrap ticket-col">
                            <strong class="ticket-number">${t.ticketNumber}</strong>
                        </td>
                        <td>
                            <a href="${pageContext.request.contextPath}/tickets/view?id=${t.id}" class="ticket-title-link" style="text-decoration: none; font-weight: 600;">
                                ${t.title}
                            </a>
                            <div style="font-size: 0.76rem; color: var(--text-muted); margin-top: 2px;">
                                Req: ${t.requesterName}
                            </div>
                        </td>
                        <td class="nowrap">
                            <c:choose>
                                <c:when test="${t.category == 'Hardware'}"><span class="badge-cat badge-cat-hardware"><i data-lucide="cpu" class="icon-xs"></i> Hardware</span></c:when>
                                <c:when test="${t.category == 'Software'}"><span class="badge-cat badge-cat-software"><i data-lucide="code" class="icon-xs"></i> Software</span></c:when>
                                <c:when test="${t.category == 'Network'}"><span class="badge-cat badge-cat-network"><i data-lucide="wifi" class="icon-xs"></i> Network</span></c:when>
                                <c:when test="${t.category == 'Access & Security'}"><span class="badge-cat badge-cat-access"><i data-lucide="shield" class="icon-xs"></i> Security</span></c:when>
                                <c:otherwise><span class="badge-cat badge-cat-infra">${t.category}</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td class="nowrap">
                            <c:choose>
                                <c:when test="${t.priority == 'Critical'}"><span class="badge-priority-critical">Critical (2h)</span></c:when>
                                <c:when test="${t.priority == 'High'}"><span class="badge-priority-high">High (4h)</span></c:when>
                                <c:when test="${t.priority == 'Medium'}"><span class="badge-priority-medium">Medium (8h)</span></c:when>
                                <c:otherwise><span class="badge-priority-low">Low (24h)</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td class="nowrap">
                            <c:choose>
                                <c:when test="${t.status == 'Open'}"><span class="badge-status-open">Open</span></c:when>
                                <c:when test="${t.status == 'In Progress'}"><span class="badge-status-in-progress">In Progress</span></c:when>
                                <c:when test="${t.status == 'Escalated'}"><span class="badge-status-escalated">Escalated</span></c:when>
                                <c:when test="${t.status == 'Resolved'}"><span class="badge-status-resolved">Resolved</span></c:when>
                                <c:otherwise><span class="badge-priority-low">${t.status}</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td class="nowrap">
                            <div class="${t.supportTier == 'Second-Line' ? 'tier-label-second' : 'tier-label-first'}" style="font-size: 0.72rem; text-transform: uppercase; font-weight: 700;">
                                [${t.supportTier}]
                            </div>
                            <div class="assignee-name" style="font-size: 0.84rem; margin-top: 1px;">
                                ${not empty t.assigneeName ? t.assigneeName : '<em style="color:var(--text-muted);">Unassigned</em>'}
                            </div>
                        </td>
                        <td class="nowrap">
                            <span class="sla-pill ${t.slaStatusLevel}" 
                                  data-sla-deadline="${t.slaDeadline}" 
                                  data-sla-resolved="${t.closedOrResolved}">
                                ${t.slaRemainingFormatted}
                            </span>
                        </td>
                        <td class="nowrap asset-col">
                            <c:choose>
                                <c:when test="${not empty t.assetTag}">
                                    <a href="${pageContext.request.contextPath}/assets/view?id=${t.assetId}" class="asset-tag-link">
                                        <i data-lucide="box" class="icon-xs"></i>
                                        <span>${t.assetTag}</span>
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <span style="color: var(--text-muted); font-size: 0.8rem;">—</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="nowrap">
                            <a href="${pageContext.request.contextPath}/tickets/view?id=${t.id}" class="btn btn-action">
                                <span>View</span>
                                <i data-lucide="chevron-right" class="icon-xs action-arrow"></i>
                            </a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="footer.jsp" />
