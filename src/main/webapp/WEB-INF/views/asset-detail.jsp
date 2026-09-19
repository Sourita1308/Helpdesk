<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="header.jsp">
    <jsp:param name="title" value="Asset [${asset.assetTag}]" />
    <jsp:param name="subtitle" value="${asset.name} — Hardware &amp; Maintenance Record" />
    <jsp:param name="active" value="assets" />
</jsp:include>

<div class="detail-grid">
    <!-- Left Column: Specs, Repeat-Issue Tickets, Maintenance Timeline -->
    <div>
        <!-- Asset Overview Card -->
        <div class="card">
            <div class="card-header">
                <div class="card-title">
                    <i data-lucide="laptop" class="icon-md" style="color: #38bdf8;"></i>
                    <span>${asset.name}</span>
                </div>
                <c:choose>
                    <c:when test="${asset.status == 'Allocated'}"><span class="badge-status-resolved">Allocated</span></c:when>
                    <c:when test="${asset.status == 'Under Repair'}"><span class="badge-priority-critical">Under Repair</span></c:when>
                    <c:otherwise><span class="badge-priority-low">${asset.status}</span></c:otherwise>
                </c:choose>
            </div>
            <div class="card-body">
                <div class="form-grid">
                    <div>
                        <div style="font-size: 0.75rem; color: var(--text-muted); text-transform: uppercase; font-weight: 700;">Asset Tag:</div>
                        <div style="font-weight: 700; color: #38bdf8; font-family: var(--font-mono); font-size: 1.05rem; margin-top: 2px;">${asset.assetTag}</div>
                    </div>
                    <div>
                        <div style="font-size: 0.75rem; color: var(--text-muted); text-transform: uppercase; font-weight: 700;">Serial Number:</div>
                        <div style="font-family: var(--font-mono); font-size: 0.92rem; color: #fff; margin-top: 2px;">${asset.serialNumber}</div>
                    </div>
                    <div>
                        <div style="font-size: 0.75rem; color: var(--text-muted); text-transform: uppercase; font-weight: 700;">Type / Category:</div>
                        <div style="font-weight: 600; color: #cbd5e1; margin-top: 2px;">${asset.type} &bull; ${asset.category}</div>
                    </div>
                    <div>
                        <div style="font-size: 0.75rem; color: var(--text-muted); text-transform: uppercase; font-weight: 700;">Warranty Expiry:</div>
                        <div style="font-weight: 600; color: #cbd5e1; font-family: var(--font-mono); margin-top: 2px;">${asset.warrantyExpiry}</div>
                    </div>
                </div>

                <div style="margin-top: 18px; padding-top: 14px; border-top: 1px solid var(--border-subtle);">
                    <div style="font-size: 0.76rem; font-weight: 700; color: var(--text-muted); text-transform: uppercase; margin-bottom: 6px;">
                        Hardware Specifications / License Details:
                    </div>
                    <div style="background: var(--bg-surface-elevated); padding: 12px 16px; border-radius: var(--radius-sm); font-size: 0.9rem; color: #e2e8f0; line-height: 1.5; border: 1px solid var(--border-subtle);">
                        ${asset.specsOrLicense}
                    </div>
                </div>
            </div>
        </div>

        <!-- Installation & Maintenance History -->
        <div class="card">
            <div class="card-header">
                <div class="card-title">
                    <i data-lucide="wrench" class="icon-md" style="color: #818cf8;"></i>
                    <span>Installation &amp; Maintenance Logs (${maintenanceLogs.size()})</span>
                </div>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${empty maintenanceLogs}">
                        <div style="color: var(--text-muted); font-size: 0.88rem; padding: 12px 0;">
                            No maintenance records registered for this asset yet.
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div style="display: flex; flex-direction: column; gap: 12px; margin-bottom: 24px;">
                            <c:forEach var="m" items="${maintenanceLogs}">
                                <div style="background: var(--bg-surface-elevated); padding: 14px 18px; border-radius: var(--radius-sm); border-left: 3px solid #38bdf8; border-top: 1px solid var(--border-subtle); border-right: 1px solid var(--border-subtle); border-bottom: 1px solid var(--border-subtle);">
                                    <div style="display: flex; justify-content: space-between; align-items: center;">
                                        <strong style="color: #fff; font-size: 0.92rem;">${m.serviceType}</strong>
                                        <span style="font-size: 0.78rem; color: var(--text-muted); font-family: var(--font-mono);">${m.serviceDate}</span>
                                    </div>
                                    <div style="font-size: 0.8rem; color: #94a3b8; margin-top: 2px;">
                                        Technician: <strong>${m.technicianName}</strong> &bull; Cost: <strong>$${m.cost}</strong>
                                    </div>
                                    <div style="font-size: 0.86rem; color: #cbd5e1; margin-top: 8px; line-height: 1.5;">
                                        ${m.notes}
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>

                <!-- Add Maintenance Form -->
                <div style="border-top: 1px solid var(--border-subtle); padding-top: 20px;">
                    <div style="font-size: 0.85rem; font-weight: 700; color: #fff; margin-bottom: 14px; display: flex; align-items: center; gap: 6px;">
                        <i data-lucide="plus-circle" class="icon-sm" style="color: #818cf8;"></i>
                        <span>Record Service or Maintenance Event</span>
                    </div>
                    <form action="${pageContext.request.contextPath}/assets/maintenance" method="post">
                        <input type="hidden" name="assetId" value="${asset.id}" />
                        <div class="form-grid">
                            <div class="form-group">
                                <label class="form-label" for="serviceType">Service Type</label>
                                <select id="serviceType" name="serviceType" class="select-control" required style="width: 100%;">
                                    <option value="Installation">Initial Installation &amp; Imaging</option>
                                    <option value="Driver Fix">Driver &amp; Firmware Patch</option>
                                    <option value="OS Reinstall">OS Reinstall &amp; Recovery</option>
                                    <option value="Battery Replacement">Battery / Thermal Replacement</option>
                                    <option value="RAM Upgrade">Hardware Upgrade (RAM/SSD)</option>
                                    <option value="License Renewal">License Renewal &amp; Provisioning</option>
                                    <option value="Hardware Inspection">Diagnostic &amp; Repair Inspection</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="technicianName">Technician Name</label>
                                <input type="text" id="technicianName" name="technicianName" class="input-control" required value="Alex Rivera" style="width: 100%;" />
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="serviceDate">Service Date</label>
                                <input type="date" id="serviceDate" name="serviceDate" class="input-control" required style="width: 100%;" />
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="cost">Cost ($ USD)</label>
                                <input type="number" step="0.01" id="cost" name="cost" class="input-control" value="0.00" style="width: 100%;" />
                            </div>
                        </div>
                        <div class="form-group full-width">
                            <label class="form-label" for="notes">Service Notes &amp; Actions Performed</label>
                            <textarea id="notes" name="notes" class="input-control form-textarea" required placeholder="Describe what components were tested or replaced..." style="width: 100%; min-height: 80px;"></textarea>
                        </div>
                        <div style="display: flex; justify-content: flex-end;">
                            <button type="submit" class="btn btn-secondary btn-sm">
                                <i data-lucide="plus" class="icon-xs"></i>
                                <span>Add Maintenance Record</span>
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Right Column: Repeat-Issue Analysis & Allocation -->
    <div>
        <!-- Allocation Card -->
        <div class="card">
            <div class="card-header">
                <div class="card-title">
                    <i data-lucide="user" class="icon-md" style="color: #818cf8;"></i>
                    <span>Allocation Status</span>
                </div>
            </div>
            <div class="card-body">
                <div style="font-size: 0.75rem; color: var(--text-muted); text-transform: uppercase; font-weight: 700;">Assigned Employee:</div>
                <div style="font-size: 1.1rem; font-weight: 700; color: #fff; margin-top: 4px;">
                    ${not empty asset.assignedUserName ? asset.assignedUserName : 'Unallocated (In Stock)'}
                </div>
                <div style="margin-top: 16px;">
                    <a href="${pageContext.request.contextPath}/tickets/new?assetId=${asset.id}" class="btn btn-primary btn-sm" style="width: 100%;">
                        <i data-lucide="ticket" class="icon-sm"></i>
                        <span>Log Ticket for This Asset</span>
                    </a>
                </div>
            </div>
        </div>

        <!-- Repeat-Issue Analysis Box -->
        <div class="card" style="${asset.repeatIssueRisk ? 'border-color: rgba(239, 68, 68, 0.4);' : ''}">
            <div class="card-header">
                <div class="card-title" style="${asset.repeatIssueRisk ? 'color: #f87171;' : ''}">
                    <i data-lucide="alert-triangle" class="icon-md" style="color: ${asset.repeatIssueRisk ? '#f87171' : '#fbbf24'};"></i>
                    <span>Repeat-Issue Telemetry</span>
                </div>
                <c:if test="${asset.repeatIssueRisk}">
                    <span class="repeat-risk-tag"><i data-lucide="flame" class="icon-xs"></i> ${asset.ticketCount} Incidents</span>
                </c:if>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${empty linkedTickets}">
                        <div style="font-size: 0.85rem; color: var(--text-muted);">
                            No incident tickets have been filed against this asset.
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div style="font-size: 0.78rem; color: var(--text-muted); margin-bottom: 12px;">
                            Total tickets filed for this unit: <strong>${linkedTickets.size()}</strong>
                        </div>
                        <div style="display: flex; flex-direction: column; gap: 8px;">
                            <c:forEach var="t" items="${linkedTickets}">
                                <div style="background: var(--bg-surface-elevated); padding: 10px 12px; border-radius: var(--radius-sm); border: 1px solid var(--border-subtle);">
                                    <div style="display: flex; justify-content: space-between; align-items: center;">
                                        <a href="${pageContext.request.contextPath}/tickets/view?id=${t.id}" style="color: #818cf8; text-decoration: none; font-weight: 700; font-size: 0.84rem; font-family: var(--font-mono);">
                                            ${t.ticketNumber}
                                        </a>
                                        <span class="badge ${t.status == 'Resolved' ? 'badge-status-resolved' : 'badge-status-open'}" style="font-size: 0.65rem;">${t.status}</span>
                                    </div>
                                    <div style="font-size: 0.82rem; color: #cbd5e1; margin-top: 4px;">
                                        ${t.title}
                                    </div>
                                    <div style="font-size: 0.74rem; color: var(--text-muted); margin-top: 4px; font-family: var(--font-mono);">
                                        ${t.createdAt} &bull; ${t.priority} Priority
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
