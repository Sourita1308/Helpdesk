<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="header.jsp">
    <jsp:param name="title" value="Ticket #${ticket.ticketNumber}" />
    <jsp:param name="subtitle" value="${ticket.title}" />
    <jsp:param name="active" value="tickets" />
</jsp:include>

<div class="detail-grid">
    <!-- Left Column: Ticket Details, Resolution & Escalations -->
    <div>
        <!-- Main Ticket Card -->
        <div class="card">
            <div class="card-header">
                <div style="display: flex; align-items: center; gap: 8px;">
                    <c:choose>
                        <c:when test="${ticket.category == 'Hardware'}"><span class="badge-cat badge-cat-hardware"><i data-lucide="cpu" class="icon-xs"></i> Hardware</span></c:when>
                        <c:when test="${ticket.category == 'Software'}"><span class="badge-cat badge-cat-software"><i data-lucide="code" class="icon-xs"></i> Software</span></c:when>
                        <c:when test="${ticket.category == 'Network'}"><span class="badge-cat badge-cat-network"><i data-lucide="wifi" class="icon-xs"></i> Network</span></c:when>
                        <c:when test="${ticket.category == 'Access & Security'}"><span class="badge-cat badge-cat-access"><i data-lucide="shield" class="icon-xs"></i> Security</span></c:when>
                        <c:otherwise><span class="badge-cat badge-cat-infra">${ticket.category}</span></c:otherwise>
                    </c:choose>

                    <c:choose>
                        <c:when test="${ticket.priority == 'Critical'}"><span class="badge-priority-critical">Critical Priority</span></c:when>
                        <c:when test="${ticket.priority == 'High'}"><span class="badge-priority-high">High Priority</span></c:when>
                        <c:when test="${ticket.priority == 'Medium'}"><span class="badge-priority-medium">Medium Priority</span></c:when>
                        <c:otherwise><span class="badge-priority-low">Low Priority</span></c:otherwise>
                    </c:choose>

                    <c:choose>
                        <c:when test="${ticket.status == 'Open'}"><span class="badge-status-open">Open</span></c:when>
                        <c:when test="${ticket.status == 'In Progress'}"><span class="badge-status-in-progress">In Progress</span></c:when>
                        <c:when test="${ticket.status == 'Escalated'}"><span class="badge-status-escalated">Escalated to Second-Line</span></c:when>
                        <c:when test="${ticket.status == 'Resolved'}"><span class="badge-status-resolved">Resolved</span></c:when>
                        <c:otherwise><span class="badge-priority-low">${ticket.status}</span></c:otherwise>
                    </c:choose>
                </div>
                <div style="font-size: 0.8rem; color: var(--text-muted); font-family: var(--font-mono);">
                    Logged: ${ticket.createdAt}
                </div>
            </div>
            <div class="card-body">
                <h2 style="font-size: 1.3rem; margin-bottom: 16px; font-weight: 700; color: #fff;">
                    ${ticket.title}
                </h2>
                <div style="background: var(--bg-surface-elevated); padding: 18px; border-radius: var(--radius-sm); border: 1px solid var(--border-subtle); white-space: pre-wrap; font-size: 0.94rem; line-height: 1.6; color: #e2e8f0;">${ticket.description}</div>
            </div>
        </div>

        <!-- Resolution Notes Section -->
        <div class="card">
            <div class="card-header">
                <div class="card-title">
                    <i data-lucide="check-square" class="icon-md" style="color: #34d399;"></i>
                    <span>Resolution &amp; Handling Notes</span>
                </div>
                <c:if test="${ticket.status == 'Resolved'}">
                    <a href="${pageContext.request.contextPath}/kb/new?ticketId=${ticket.id}" class="btn btn-primary btn-sm">
                        <i data-lucide="book-plus" class="icon-sm"></i>
                        <span>Convert to KB Guide</span>
                    </a>
                </c:if>
            </div>
            <div class="card-body">
                <c:if test="${not empty ticket.resolutionNotes}">
                    <div style="background: rgba(16, 185, 129, 0.08); border: 1px solid rgba(16, 185, 129, 0.3); border-radius: var(--radius-sm); padding: 18px; margin-bottom: 20px;">
                        <div style="font-size: 0.78rem; font-weight: 700; color: #34d399; text-transform: uppercase; margin-bottom: 6px; display: flex; align-items: center; gap: 6px;">
                            <i data-lucide="check-circle" class="icon-xs"></i>
                            <span>Official Technical Resolution:</span>
                        </div>
                        <div style="white-space: pre-wrap; font-size: 0.92rem; color: #e2e8f0; line-height: 1.6;">${ticket.resolutionNotes}</div>
                        <div style="font-size: 0.78rem; color: var(--text-muted); margin-top: 8px; font-family: var(--font-mono);">
                            Resolved At: ${ticket.resolvedAt}
                        </div>
                    </div>
                </c:if>

                <!-- Update Status & Notes Form -->
                <form action="${pageContext.request.contextPath}/tickets/update" method="post">
                    <input type="hidden" name="ticketId" value="${ticket.id}" />
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label" for="status">Update Status</label>
                            <select id="status" name="status" class="select-control" style="width: 100%;">
                                <option value="In Progress" ${ticket.status == 'In Progress' ? 'selected' : ''}>In Progress (First-Line Investigation)</option>
                                <option value="Resolved" ${ticket.status == 'Resolved' ? 'selected' : ''}>Resolved (Issue Fixed)</option>
                                <option value="Closed" ${ticket.status == 'Closed' ? 'selected' : ''}>Closed</option>
                                <option value="Open" ${ticket.status == 'Open' ? 'selected' : ''}>Open</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-group full-width">
                        <label class="form-label" for="resolutionNotes">Add / Update Resolution Notes</label>
                        <textarea id="resolutionNotes" name="resolutionNotes" class="input-control form-textarea" placeholder="Detail root cause and step-by-step resolution so other technicians can reference this runbook...">${ticket.resolutionNotes}</textarea>
                    </div>
                    <div style="display: flex; justify-content: flex-end;">
                        <button type="submit" class="btn btn-secondary">
                            <i data-lucide="save" class="icon-sm"></i>
                            <span>Save Notes &amp; Status</span>
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Escalation to Second-Line Tier -->
        <div class="card" style="border-color: rgba(168, 85, 247, 0.3);">
            <div class="card-header" style="background: rgba(168, 85, 247, 0.06);">
                <div class="card-title" style="color: #c084fc;">
                    <i data-lucide="flame" class="icon-md" style="color: #c084fc;"></i>
                    <span>Escalation Management (First-Line &rarr; Second-Line)</span>
                </div>
                <span class="badge ${ticket.supportTier == 'Second-Line' ? 'badge-status-escalated' : 'badge-priority-low'}">
                    Current Tier: ${ticket.supportTier}
                </span>
            </div>
            <div class="card-body">
                <c:if test="${not empty escalationLogs}">
                    <div style="margin-bottom: 20px;">
                        <div style="font-size: 0.75rem; font-weight: 700; text-transform: uppercase; color: var(--text-muted); margin-bottom: 10px;">
                            Escalation Audit Trail:
                        </div>
                        <c:forEach var="log" items="${escalationLogs}">
                            <div style="background: var(--bg-surface-elevated); padding: 12px 16px; border-radius: var(--radius-sm); border-left: 3px solid var(--purple); margin-bottom: 8px; font-size: 0.85rem;">
                                <div style="display: flex; justify-content: space-between;">
                                    <strong>${log.fromTier} &rarr; ${log.toTier}</strong>
                                    <span style="font-size: 0.75rem; color: var(--text-muted); font-family: var(--font-mono);">${log.escalatedAt}</span>
                                </div>
                                <div style="color: var(--text-secondary); font-size: 0.8rem; margin-top: 2px;">
                                    Escalated by: <em>${log.escalatedBy}</em>
                                </div>
                                <div style="color: #cbd5e1; margin-top: 6px;">Reason: ${log.reason}</div>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/escalate" method="post">
                    <input type="hidden" name="ticketId" value="${ticket.id}" />
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label" for="targetAgentId">Assign to Tier-2 / L2 Specialist</label>
                            <select id="targetAgentId" name="targetAgentId" class="select-control" style="width: 100%;">
                                <option value="">-- Auto-assign to Tier-2 Queue --</option>
                                <c:forEach var="l2" items="${l2Agents}">
                                    <option value="${l2.id}">${l2.name} (${l2.department})</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="escalatedBy">Your Name / Agent ID</label>
                            <input type="text" id="escalatedBy" name="escalatedBy" class="input-control" value="First-Line Triage Agent" style="width: 100%;" />
                        </div>
                    </div>
                    <div class="form-group full-width">
                        <label class="form-label" for="reason">Escalation Justification *</label>
                        <input type="text" id="reason" name="reason" class="input-control" required placeholder="e.g. Hardware sensor diagnostic failed, requires Tier-2 RMA or L2 network routing privileges" style="width: 100%;" />
                    </div>
                    <div style="display: flex; justify-content: flex-end;">
                        <button type="submit" class="btn btn-purple">
                            <i data-lucide="flame" class="icon-sm"></i>
                            <span>Route Ticket to Second-Line</span>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Right Column: SLA Timers, Requester Info, Asset Linkage & KB Suggestions -->
    <div>
        <!-- Live SLA Card -->
        <div class="card">
            <div class="card-header">
                <div class="card-title">
                    <i data-lucide="clock" class="icon-md" style="color: #fbbf24;"></i>
                    <span>SLA Status &amp; Policy</span>
                </div>
            </div>
            <div class="card-body">
                <div style="display: flex; flex-direction: column; gap: 12px;">
                    <div>
                        <div style="font-size: 0.75rem; color: var(--text-muted); text-transform: uppercase; font-weight: 700;">Time Remaining:</div>
                        <div style="margin-top: 6px;">
                            <span class="sla-pill ${ticket.slaStatusLevel}" 
                                  style="font-size: 0.95rem; padding: 6px 14px;"
                                  data-sla-deadline="${ticket.slaDeadline}" 
                                  data-sla-resolved="${ticket.closedOrResolved}">
                                ${ticket.slaRemainingFormatted}
                            </span>
                        </div>
                    </div>
                    <div style="font-size: 0.82rem; color: var(--text-secondary); margin-top: 4px; display: flex; flex-direction: column; gap: 4px;">
                        <div>Target Deadline: <strong style="font-family: var(--font-mono); font-size: 0.8rem; color: #fff;">${ticket.slaDeadline}</strong></div>
                        <div>Priority Policy: <strong>${ticket.priority} SLA</strong></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Assignment & Requester Card -->
        <div class="card">
            <div class="card-header">
                <div class="card-title">
                    <i data-lucide="user-check" class="icon-md" style="color: #818cf8;"></i>
                    <span>Triage &amp; Assignment</span>
                </div>
            </div>
            <div class="card-body">
                <div style="margin-bottom: 16px;">
                    <div style="font-size: 0.72rem; text-transform: uppercase; color: var(--text-muted); font-weight: 700;">Requester:</div>
                    <div style="font-weight: 700; color: #fff; font-size: 0.95rem; margin-top: 2px;">${ticket.requesterName}</div>
                    <div style="font-size: 0.82rem; color: var(--text-secondary);">${ticket.requesterEmail}</div>
                </div>

                <form action="${pageContext.request.contextPath}/tickets/assign" method="post" style="border-top: 1px solid var(--border-subtle); padding-top: 14px;">
                    <input type="hidden" name="ticketId" value="${ticket.id}" />
                    <div class="form-group">
                        <label class="form-label" for="assigneeIdSidebar">Re-assign Agent</label>
                        <select id="assigneeIdSidebar" name="assigneeId" class="select-control" style="width: 100%;">
                            <option value="">-- Unassigned --</option>
                            <optgroup label="First-Line (L1)">
                                <c:forEach var="a" items="${l1Agents}">
                                    <option value="${a.id}" ${ticket.assigneeId == a.id ? 'selected' : ''}>${a.name}</option>
                                </c:forEach>
                            </optgroup>
                            <optgroup label="Second-Line (L2)">
                                <c:forEach var="a" items="${l2Agents}">
                                    <option value="${a.id}" ${ticket.assigneeId == a.id ? 'selected' : ''}>${a.name}</option>
                                </c:forEach>
                            </optgroup>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="supportTier">Support Tier</label>
                        <select id="supportTier" name="supportTier" class="select-control" style="width: 100%;">
                            <option value="First-Line" ${ticket.supportTier == 'First-Line' ? 'selected' : ''}>First-Line Support</option>
                            <option value="Second-Line" ${ticket.supportTier == 'Second-Line' ? 'selected' : ''}>Second-Line (Escalation)</option>
                        </select>
                    </div>
                    <button type="submit" class="btn btn-secondary btn-sm" style="width: 100%;">
                        <i data-lucide="user-plus" class="icon-xs"></i>
                        <span>Update Assignment</span>
                    </button>
                </form>
            </div>
        </div>

        <!-- Linked Asset & Repeat-Issue History -->
        <c:if test="${not empty asset}">
            <div class="card" style="${asset.repeatIssueRisk ? 'border-color: rgba(239, 68, 68, 0.4);' : ''}">
                <div class="card-header">
                    <div class="card-title">
                        <i data-lucide="laptop" class="icon-md" style="color: #38bdf8;"></i>
                        <span>Associated Asset</span>
                    </div>
                    <c:if test="${asset.repeatIssueRisk}">
                        <span class="repeat-risk-tag"><i data-lucide="alert-triangle" class="icon-xs"></i> ${asset.ticketCount} Incidents</span>
                    </c:if>
                </div>
                <div class="card-body">
                    <div style="font-weight: 700; color: #fff;">${asset.name}</div>
                    <div style="font-size: 0.8rem; color: #38bdf8; font-family: var(--font-mono);">Tag: ${asset.assetTag} &bull; S/N: ${asset.serialNumber}</div>
                    <div style="font-size: 0.8rem; color: var(--text-muted); margin-top: 6px;">
                        Allocated to: <strong>${asset.assignedUserName}</strong>
                    </div>

                    <div style="margin-top: 14px; padding-top: 12px; border-top: 1px solid var(--border-subtle);">
                        <div style="font-size: 0.74rem; font-weight: 700; color: var(--text-muted); text-transform: uppercase;">
                            Incident History on this Asset (${assetTickets.size()}):
                        </div>
                        <div style="display: flex; flex-direction: column; gap: 6px; margin-top: 8px;">
                            <c:forEach var="at" items="${assetTickets}">
                                <a href="${pageContext.request.contextPath}/tickets/view?id=${at.id}" style="font-size: 0.8rem; color: ${at.id == ticket.id ? '#818cf8' : '#94a3b8'}; text-decoration: none; display: flex; justify-content: space-between; align-items: center; padding: 4px 6px; border-radius: 4px; background: var(--bg-surface-elevated);">
                                    <span style="font-family: var(--font-mono); font-size: 0.78rem;">${at.ticketNumber}</span>
                                    <span class="badge ${at.status == 'Resolved' ? 'badge-status-resolved' : 'badge-status-open'}" style="font-size: 0.65rem;">${at.status}</span>
                                </a>
                            </c:forEach>
                        </div>
                        <div style="margin-top: 12px;">
                            <a href="${pageContext.request.contextPath}/assets/view?id=${asset.id}" class="btn btn-secondary btn-sm" style="width: 100%;">
                                <span>View Asset Service History</span>
                                <i data-lucide="arrow-right" class="icon-xs"></i>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </c:if>

        <!-- Suggested KB Articles to cut repeat handling time -->
        <div class="card">
            <div class="card-header">
                <div class="card-title">
                    <i data-lucide="book-marked" class="icon-md" style="color: #818cf8;"></i>
                    <span>Suggested Knowledge Base</span>
                </div>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${empty suggestedKb}">
                        <div style="font-size: 0.82rem; color: var(--text-muted); line-height: 1.5;">
                            No direct KB match found. If you resolve this issue, convert your resolution notes into an article to speed up future incidents!
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div style="display: flex; flex-direction: column; gap: 10px;">
                            <c:forEach var="kb" items="${suggestedKb}">
                                <div style="background: var(--bg-surface-elevated); padding: 12px; border-radius: var(--radius-sm); border: 1px solid var(--border-subtle);">
                                    <a href="${pageContext.request.contextPath}/kb/view?id=${kb.id}" style="font-weight: 700; font-size: 0.86rem; color: #818cf8; text-decoration: none; display: flex; align-items: center; justify-content: space-between;">
                                        <span>${kb.title}</span>
                                        <i data-lucide="external-link" class="icon-xs"></i>
                                    </a>
                                    <div style="font-size: 0.74rem; color: var(--text-muted); margin-top: 4px;">
                                        Category: ${kb.category} &bull; ${kb.viewCount} views
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
