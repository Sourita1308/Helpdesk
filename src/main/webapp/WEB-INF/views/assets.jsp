<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="header.jsp">
    <jsp:param name="title" value="Asset Register &amp; Inventory" />
    <jsp:param name="subtitle" value="Track hardware and software allocation per user, warranties, and repeat-issue trends" />
    <jsp:param name="active" value="assets" />
</jsp:include>

<!-- Filter & Search Bar -->
<form action="${pageContext.request.contextPath}/assets" method="get" class="filter-bar">
    <div class="search-input-wrapper">
        <i data-lucide="search" class="search-icon-embedded"></i>
        <input type="text" name="search" class="input-control with-icon input-search" placeholder="Search Asset Tag, Serial #, User, Model..." value="${currentSearch}" style="min-width: 340px;" />
    </div>

    <div class="filter-group">
        <select name="category" class="select-control">
            <option value="">All Categories</option>
            <option value="Laptop" ${currentCategory == 'Laptop' ? 'selected' : ''}>Laptops</option>
            <option value="Desktop" ${currentCategory == 'Desktop' ? 'selected' : ''}>Desktops</option>
            <option value="Monitor" ${currentCategory == 'Monitor' ? 'selected' : ''}>Monitors</option>
            <option value="License" ${currentCategory == 'License' ? 'selected' : ''}>Software Licenses</option>
        </select>
    </div>

    <div class="filter-group">
        <select name="status" class="select-control">
            <option value="">All Statuses</option>
            <option value="Allocated" ${currentStatus == 'Allocated' ? 'selected' : ''}>Allocated</option>
            <option value="In Stock" ${currentStatus == 'In Stock' ? 'selected' : ''}>In Stock</option>
            <option value="Under Repair" ${currentStatus == 'Under Repair' ? 'selected' : ''}>Under Repair</option>
            <option value="Retired" ${currentStatus == 'Retired' ? 'selected' : ''}>Retired</option>
        </select>
    </div>

    <button type="submit" class="btn btn-secondary btn-sm">
        <i data-lucide="filter" class="icon-sm"></i>
        <span>Filter</span>
    </button>
    <c:if test="${not empty currentSearch || not empty currentCategory || not empty currentStatus}">
        <a href="${pageContext.request.contextPath}/assets" class="btn btn-sm" style="color: var(--text-muted);">Reset</a>
    </c:if>
</form>

<!-- Asset Register Table -->
<div class="card">
    <div class="card-header">
        <div class="card-title">
            <i data-lucide="laptop" class="icon-md" style="color: #818cf8;"></i>
            <span>IT Asset Inventory</span>
        </div>
        <div style="display: flex; gap: 8px;">
            <a href="${pageContext.request.contextPath}/assets/repeat-issues" class="btn btn-secondary btn-sm" style="border-color: rgba(239, 68, 68, 0.35); color: #fca5a5;">
                <i data-lucide="alert-triangle" class="icon-sm text-danger"></i>
                <span>Repeat-Issue Analysis (${repeatRiskCount})</span>
            </a>
            <a href="${pageContext.request.contextPath}/assets/new" class="btn btn-primary btn-sm">
                <i data-lucide="plus" class="icon-sm"></i>
                <span>Register Asset</span>
            </a>
        </div>
    </div>
    <div class="table-responsive">
        <table class="data-table">
            <thead>
                <tr>
                    <th class="nowrap">Asset Tag</th>
                    <th>Asset Name / Model</th>
                    <th class="nowrap">Type / Category</th>
                    <th class="nowrap">Serial Number</th>
                    <th class="nowrap">Status</th>
                    <th>Allocated User</th>
                    <th class="nowrap">Warranty Expiry</th>
                    <th class="nowrap">Issue History</th>
                    <th class="nowrap">Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty assets}">
                        <tr>
                            <td colspan="9" style="text-align: center; padding: 48px; color: var(--text-muted);">
                                No assets found matching your criteria.
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="a" items="${assets}">
                            <tr>
                                <td class="nowrap">
                                    <strong class="asset-tag-link" style="color: #38bdf8; font-size: 0.85rem;">${a.assetTag}</strong>
                                </td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/assets/view?id=${a.id}" style="color: #fff; font-weight: 700; text-decoration: none;">
                                        ${a.name}
                                    </a>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${a.category == 'Laptop'}"><span class="badge-cat badge-cat-hardware"><i data-lucide="laptop" class="icon-xs"></i> Laptop</span></c:when>
                                        <c:when test="${a.category == 'Monitor'}"><span class="badge-cat badge-cat-hardware"><i data-lucide="monitor" class="icon-xs"></i> Monitor</span></c:when>
                                        <c:when test="${a.category == 'License'}"><span class="badge-cat badge-cat-software"><i data-lucide="key" class="icon-xs"></i> License</span></c:when>
                                        <c:otherwise><span class="badge-cat badge-cat-infra">${a.category}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <span style="font-family: var(--font-mono); font-size: 0.8rem; color: #94a3b8;">${a.serialNumber}</span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${a.status == 'Allocated'}"><span class="badge-status-resolved">Allocated</span></c:when>
                                        <c:when test="${a.status == 'In Stock'}"><span class="badge-status-open">In Stock</span></c:when>
                                        <c:when test="${a.status == 'Under Repair'}"><span class="badge-priority-critical">Under Repair</span></c:when>
                                        <c:otherwise><span class="badge-priority-low">${a.status}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty a.assignedUserName}">
                                            <span style="font-weight: 600; color: #f8fafc;">${a.assignedUserName}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <em style="color: var(--text-muted); font-size: 0.82rem;">Unallocated</em>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <span style="font-size: 0.82rem; color: var(--text-secondary); font-family: var(--font-mono);">${a.warrantyExpiry}</span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${a.repeatIssueRisk}">
                                            <span class="repeat-risk-tag" title="Repeat issue analysis: High incident recurrence">
                                                <i data-lucide="alert-triangle" class="icon-xs"></i> ${a.ticketCount} Incidents
                                            </span>
                                        </c:when>
                                        <c:when test="${a.ticketCount > 0}">
                                            <span style="font-size: 0.8rem; color: #94a3b8;">${a.ticketCount} Ticket</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="font-size: 0.8rem; color: var(--text-muted);">None</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/assets/view?id=${a.id}" class="btn btn-action">
                                        <span>Details</span>
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
