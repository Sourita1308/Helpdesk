<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="header.jsp">
    <jsp:param name="title" value="Create IT Support Ticket" />
    <jsp:param name="subtitle" value="First-line ticket intake, category tagging, SLA assignment" />
    <jsp:param name="active" value="tickets" />
</jsp:include>

<div class="card" style="max-width: 860px; margin: 0 auto;">
    <div class="card-header">
        <div class="card-title">
            <i data-lucide="plus-circle" class="icon-md" style="color: #818cf8;"></i>
            <span>New Ticket Intake Form</span>
        </div>
        <a href="${pageContext.request.contextPath}/tickets" class="btn btn-secondary btn-sm">Cancel</a>
    </div>
    <div class="card-body">
        <form action="${pageContext.request.contextPath}/tickets/new" method="post">
            <div class="form-group full-width">
                <label class="form-label" for="title">Issue Summary / Title *</label>
                <input type="text" id="title" name="title" class="input-control" required placeholder="e.g. Dell XPS laptop overheating during Gradle build" style="width: 100%; font-size: 1rem;" />
            </div>

            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label" for="category">Category Tag *</label>
                    <select id="category" name="category" class="select-control" required style="width: 100%;">
                        <option value="Hardware">Hardware (Laptops, Monitors, Peripherals)</option>
                        <option value="Software">Software (OS, IDEs, Applications)</option>
                        <option value="Network">Network (VPN, Wi-Fi, DNS, Gateway)</option>
                        <option value="Access & Security">Access &amp; Security (Certificates, SSO, MFA)</option>
                        <option value="Infrastructure">Infrastructure (Cloud, Servers, CI/CD)</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label" for="priority">Priority &amp; SLA Policy *</label>
                    <select id="priority" name="priority" class="select-control" required style="width: 100%;">
                        <option value="Medium">Medium — 8-Hour SLA (Default)</option>
                        <option value="Low">Low — 24-Hour SLA</option>
                        <option value="High">High — 4-Hour SLA</option>
                        <option value="Critical">Critical — 2-Hour SLA (Urgent Escalation)</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label" for="requesterId">Requester / Employee *</label>
                    <select id="requesterId" name="requesterId" class="select-control" required style="width: 100%;">
                        <c:forEach var="u" items="${users}">
                            <option value="${u.id}">${u.name} (${u.department}) - ${u.email}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label" for="assigneeId">First-Line Support Assignee</label>
                    <select id="assigneeId" name="assigneeId" class="select-control" style="width: 100%;">
                        <option value="">-- Unassigned (Send to First-Line Queue) --</option>
                        <c:forEach var="ag" items="${agents}">
                            <option value="${ag.id}">${ag.name} [${ag.role}]</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group full-width">
                    <label class="form-label" for="assetId">Link Associated Asset (Hardware / License)</label>
                    <select id="assetId" name="assetId" class="select-control" style="width: 100%;">
                        <option value="">-- No Specific Asset Associated --</option>
                        <c:forEach var="ast" items="${assets}">
                            <option value="${ast.id}" ${preselectedAssetId == ast.id ? 'selected' : ''}>
                                [${ast.assetTag}] ${ast.name} (${ast.category}) - Assigned to: ${not empty ast.assignedUserName ? ast.assignedUserName : 'Unassigned'}
                            </option>
                        </c:forEach>
                    </select>
                    <small style="color: var(--text-muted); margin-top: 4px; display: block;">
                        Linking an asset enables repeat-issue analysis and historical hardware diagnostics.
                    </small>
                </div>

                <div class="form-group full-width">
                    <label class="form-label" for="description">Detailed Description &amp; Symptoms *</label>
                    <textarea id="description" name="description" class="input-control form-textarea" required placeholder="Describe what went wrong, error codes, steps taken, and operational impact..." style="width: 100%;"></textarea>
                </div>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 16px;">
                <a href="${pageContext.request.contextPath}/tickets" class="btn btn-secondary">Cancel</a>
                <button type="submit" class="btn btn-primary">
                    <i data-lucide="clock" class="icon-sm"></i>
                    <span>Submit &amp; Start SLA Timer</span>
                </button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="footer.jsp" />
