<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="header.jsp">
    <jsp:param name="title" value="Support Ticket Queue" />
    <jsp:param name="subtitle" value="First-line intake, prioritization, L2 escalation, and live SLA monitoring" />
    <jsp:param name="active" value="${currentQueue == 'first_line' ? 'first_line' : (currentQueue == 'second_line' ? 'second_line' : (currentQueue == 'breached' ? 'breached' : 'tickets'))}" />
</jsp:include>

<!-- Queue Filter Tabs -->
<div class="queue-tabs">
    <a href="${pageContext.request.contextPath}/tickets?queue=all" class="queue-tab ${currentQueue == 'all' || empty currentQueue ? 'active' : ''}">
        <i data-lucide="layers" class="icon-xs"></i>
        <span>All Tickets</span>
    </a>
    <a href="${pageContext.request.contextPath}/tickets?queue=first_line" class="queue-tab ${currentQueue == 'first_line' ? 'active' : ''}">
        <i data-lucide="inbox" class="icon-xs"></i>
        <span>First-Line Queue</span>
    </a>
    <a href="${pageContext.request.contextPath}/tickets?queue=second_line" class="queue-tab ${currentQueue == 'second_line' ? 'active' : ''}">
        <i data-lucide="flame" class="icon-xs text-amber"></i>
        <span>Second-Line (L2)</span>
    </a>
    <a href="${pageContext.request.contextPath}/tickets?queue=breached" class="queue-tab ${currentQueue == 'breached' ? 'active' : ''}">
        <i data-lucide="alert-triangle" class="icon-xs text-danger"></i>
        <span>SLA Breached</span>
    </a>
    <a href="${pageContext.request.contextPath}/tickets?queue=open" class="queue-tab ${currentQueue == 'open' ? 'active' : ''}">
        <i data-lucide="clock" class="icon-xs"></i>
        <span>Active &amp; In-Progress</span>
    </a>
    <a href="${pageContext.request.contextPath}/tickets?queue=unassigned" class="queue-tab ${currentQueue == 'unassigned' ? 'active' : ''}">
        <i data-lucide="user-x" class="icon-xs"></i>
        <span>Unassigned</span>
    </a>
    <a href="${pageContext.request.contextPath}/tickets?queue=resolved" class="queue-tab ${currentQueue == 'resolved' ? 'active' : ''}">
        <i data-lucide="check-circle" class="icon-xs text-success"></i>
        <span>Resolved</span>
    </a>
</div>

<!-- Secondary Filter Bar -->
<form action="${pageContext.request.contextPath}/tickets" method="get" class="filter-bar">
    <input type="hidden" name="queue" value="${currentQueue}" />
    
    <div class="search-input-wrapper">
        <i data-lucide="search" class="search-icon-embedded"></i>
        <input type="text" name="search" class="input-control with-icon input-search" placeholder="Search ticket #, title, user, asset..." value="${currentSearch}" style="min-width: 320px;" />
    </div>

    <div class="filter-group">
        <select name="priority" class="select-control">
            <option value="">All Priorities</option>
            <option value="Critical" ${currentPriority == 'Critical' ? 'selected' : ''}>Critical (2h)</option>
            <option value="High" ${currentPriority == 'High' ? 'selected' : ''}>High (4h)</option>
            <option value="Medium" ${currentPriority == 'Medium' ? 'selected' : ''}>Medium (8h)</option>
            <option value="Low" ${currentPriority == 'Low' ? 'selected' : ''}>Low (24h)</option>
        </select>
    </div>

    <div class="filter-group">
        <select name="category" class="select-control">
            <option value="">All Categories</option>
            <option value="Hardware" ${currentCategory == 'Hardware' ? 'selected' : ''}>Hardware</option>
            <option value="Software" ${currentCategory == 'Software' ? 'selected' : ''}>Software</option>
            <option value="Network" ${currentCategory == 'Network' ? 'selected' : ''}>Network</option>
            <option value="Access & Security" ${currentCategory == 'Access & Security' ? 'selected' : ''}>Access &amp; Security</option>
            <option value="Infrastructure" ${currentCategory == 'Infrastructure' ? 'selected' : ''}>Infrastructure</option>
        </select>
    </div>

    <button type="submit" class="btn btn-secondary btn-sm">
        <i data-lucide="filter" class="icon-sm"></i>
        <span>Filter</span>
    </button>
    <c:if test="${not empty currentSearch || not empty currentPriority || not empty currentCategory}">
        <a href="${pageContext.request.contextPath}/tickets?queue=${currentQueue}" class="btn btn-sm" style="color: var(--text-muted);">Reset</a>
    </c:if>
</form>

<!-- Ticket List Table -->
<div class="card">
    <div class="table-responsive">
        <table class="data-table">
            <thead>
                <tr>
                    <th class="nowrap">Ticket #</th>
                    <th>Title &amp; Requester</th>
                    <th class="nowrap">Category</th>
                    <th class="nowrap">Priority</th>
                    <th class="nowrap">Tier / Assignee</th>
                    <th class="nowrap">Status</th>
                    <th class="nowrap">Live SLA Timer</th>
                    <th class="nowrap">Asset Tag</th>
                    <th class="nowrap">Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty tickets}">
                        <tr>
                            <td colspan="9" style="text-align: center; padding: 48px; color: var(--text-muted);">
                                No tickets found matching this queue or filter.
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="t" items="${tickets}">
                            <tr>
                                <td class="nowrap ticket-col">
                                    <strong class="ticket-number">${t.ticketNumber}</strong>
                                </td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/tickets/view?id=${t.id}" class="ticket-title-link" style="text-decoration: none; font-weight: 600;">
                                        ${t.title}
                                    </a>
                                    <div style="font-size: 0.78rem; color: var(--text-muted); margin-top: 2px;">
                                        By ${t.requesterName} &bull; ${t.requesterEmail}
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
                                        <c:when test="${t.priority == 'Critical'}"><span class="badge-priority-critical">Critical</span></c:when>
                                        <c:when test="${t.priority == 'High'}"><span class="badge-priority-high">High</span></c:when>
                                        <c:when test="${t.priority == 'Medium'}"><span class="badge-priority-medium">Medium</span></c:when>
                                        <c:otherwise><span class="badge-priority-low">Low</span></c:otherwise>
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
                                    <c:choose>
                                        <c:when test="${t.status == 'Open'}"><span class="badge-status-open">Open</span></c:when>
                                        <c:when test="${t.status == 'In Progress'}"><span class="badge-status-in-progress">In Progress</span></c:when>
                                        <c:when test="${t.status == 'Escalated'}"><span class="badge-status-escalated">Escalated</span></c:when>
                                        <c:when test="${t.status == 'Resolved'}"><span class="badge-status-resolved">Resolved</span></c:when>
                                        <c:otherwise><span class="badge-priority-low">${t.status}</span></c:otherwise>
                                    </c:choose>
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
                                        <c:otherwise><span style="color: var(--text-muted);">—</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="nowrap">
                                    <a href="${pageContext.request.contextPath}/tickets/view?id=${t.id}" class="btn btn-action">
                                        <span>Open</span>
                                        <i data-lucide="chevron-right" class="icon-xs action-arrow"></i>
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="footer.jsp" />
