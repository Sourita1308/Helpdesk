<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="header.jsp">
    <jsp:param name="title" value="Repeat-Issue Analysis" />
    <jsp:param name="subtitle" value="Identify chronic device failures, recurring software crashes, and maintenance hot-spots" />
    <jsp:param name="active" value="repeat_issues" />
</jsp:include>

<div class="alert-banner warning">
    <i data-lucide="refresh-cw" class="alert-icon text-warning"></i>
    <div>
        <strong>Repeat-Issue Diagnostic Engine:</strong> Assets with 2 or more logged support incidents are flagged below.
        Use this telemetry to identify chronic hardware component degradation, driver incompatibility, or user training needs.
    </div>
</div>

<div class="card">
    <div class="card-header">
        <div class="card-title" style="color: #f87171;">
            <i data-lucide="alert-octagon" class="icon-md" style="color: #f87171;"></i>
            <span>High-Incidence IT Equipment (${repeatAssets.size()} Flagged)</span>
        </div>
    </div>
    <div class="table-responsive">
        <table class="data-table">
            <thead>
                <tr>
                    <th class="nowrap">Asset Tag</th>
                    <th>Model / Name</th>
                    <th class="nowrap">Assigned User</th>
                    <th class="nowrap">Total Tickets</th>
                    <th class="nowrap">Open / Breached</th>
                    <th class="nowrap">Service Logs</th>
                    <th>Risk Assessment &amp; Recommendation</th>
                    <th class="nowrap">Action</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty repeatAssets}">
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 48px; color: var(--text-muted);">
                                No repeat-issue assets detected! All equipment operating within expected reliability baselines.
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="a" items="${repeatAssets}">
                            <tr>
                                <td class="nowrap">
                                    <strong class="asset-tag-link" style="color: #38bdf8; font-size: 0.85rem;">${a.assetTag}</strong>
                                </td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/assets/view?id=${a.id}" style="color: #fff; font-weight: 700; text-decoration: none;">
                                        ${a.name}
                                    </a>
                                    <div style="font-size: 0.76rem; color: var(--text-muted);">${a.category} &bull; S/N: ${a.serialNumber}</div>
                                </td>
                                <td>
                                    <span style="font-weight: 600;">${not empty a.assignedUserName ? a.assignedUserName : 'Unallocated'}</span>
                                </td>
                                <td>
                                    <span class="repeat-risk-tag">
                                        <i data-lucide="alert-triangle" class="icon-xs"></i> ${a.ticketCount} Incidents
                                    </span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${a.openTicketCount > 0}">
                                            <span class="badge-priority-critical">${a.openTicketCount} Active</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-status-resolved">0 Active</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <span style="font-size: 0.85rem; color: #cbd5e1; font-family: var(--font-mono);">${a.maintenanceCount} logs</span>
                                </td>
                                <td>
                                    <div style="font-size: 0.82rem; color: #fca5a5; line-height: 1.4;">
                                        <c:choose>
                                            <c:when test="${a.ticketCount >= 3}">
                                                <strong>Critical Recurrence:</strong> Suspect hardware component degradation. Initiate RMA exchange or escalate to Tier-2 hardware diagnostics.
                                            </c:when>
                                            <c:otherwise>
                                                <strong>Moderate Recurrence:</strong> Verify OS image &amp; driver firmware patch levels before re-allocating.
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </td>
                                <td>
                                    <div style="display: flex; gap: 6px;">
                                        <a href="${pageContext.request.contextPath}/assets/view?id=${a.id}" class="btn btn-action">
                                            <span>Inspect</span>
                                            <i data-lucide="chevron-right" class="icon-xs action-arrow"></i>
                                        </a>
                                        <a href="${pageContext.request.contextPath}/tickets/new?assetId=${a.id}" class="btn btn-secondary btn-sm" style="padding: 4px 8px;" title="Create new incident ticket for this asset">
                                            <i data-lucide="plus" class="icon-xs"></i>
                                        </a>
                                    </div>
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
