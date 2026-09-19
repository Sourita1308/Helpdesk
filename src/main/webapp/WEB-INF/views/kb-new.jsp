<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="header.jsp">
    <jsp:param name="title" value="${not empty sourceTicket ? 'Convert Ticket to KB Article' : 'Create Knowledge Base Article'}" />
    <jsp:param name="subtitle" value="Document technical solutions to prevent repeat handling time" />
    <jsp:param name="active" value="kb" />
</jsp:include>

<div class="card" style="max-width: 860px; margin: 0 auto;">
    <div class="card-header">
        <div class="card-title">
            <i data-lucide="book-plus" class="icon-md" style="color: #818cf8;"></i>
            <span>${not empty sourceTicket ? 'Convert Resolved Incident to Standard Guide' : 'Publish New KB Guide'}</span>
        </div>
        <a href="${pageContext.request.contextPath}/kb" class="btn btn-secondary btn-sm">Cancel</a>
    </div>
    <div class="card-body">
        <c:if test="${not empty sourceTicket}">
            <div class="alert-banner info">
                <i data-lucide="sparkles" class="alert-icon"></i>
                <div>
                    <strong>1-Click Conversion Active:</strong> Pre-populated with resolution data from ticket <strong style="font-family: var(--font-mono);">#${sourceTicket.ticketNumber}</strong>: <em>${sourceTicket.title}</em>.
                </div>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}${not empty sourceTicket ? '/kb/convert' : '/kb/new'}" method="post">
            <c:if test="${not empty sourceTicket}">
                <input type="hidden" name="ticketId" value="${sourceTicket.id}" />
            </c:if>

            <c:choose>
                <c:when test="${not empty sourceTicket}">
                    <!-- Conversion Form -->
                    <div class="form-grid">
                        <div class="form-group full-width">
                            <label class="form-label" for="ticketTitleDisplay">Original Ticket Issue</label>
                            <input type="text" id="ticketTitleDisplay" class="input-control" readonly value="${sourceTicket.title}" style="width: 100%; opacity: 0.8;" />
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="categoryDisplay">Category</label>
                            <input type="text" id="categoryDisplay" class="input-control" readonly value="${sourceTicket.category}" style="width: 100%; opacity: 0.8;" />
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="authorName">Author / Publishing Technician *</label>
                            <input type="text" id="authorName" name="authorName" class="input-control" required value="${not empty sourceTicket.assigneeName ? sourceTicket.assigneeName : 'First-Line Support Specialist'}" style="width: 100%;" />
                        </div>
                        <div class="form-group full-width">
                            <label class="form-label" for="rootCause">Root Cause Diagnosis *</label>
                            <input type="text" id="rootCause" name="rootCause" class="input-control" required placeholder="e.g. Stale local routing table entries conflicting with virtual adapter gateway." style="width: 100%;" />
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- Manual Creation Form -->
                    <div class="form-grid">
                        <div class="form-group full-width">
                            <label class="form-label" for="title">Article Title / Problem Summary *</label>
                            <input type="text" id="title" name="title" class="input-control" required placeholder="e.g. How to resolve Cisco AnyConnect certificate expiry on Windows 11" style="width: 100%;" />
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="category">Category *</label>
                            <select id="category" name="category" class="select-control" required style="width: 100%;">
                                <option value="Hardware">Hardware</option>
                                <option value="Software">Software</option>
                                <option value="Network">Network</option>
                                <option value="Access & Security">Access &amp; Security</option>
                                <option value="Infrastructure">Infrastructure</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="authorNameManual">Author / Technician *</label>
                            <input type="text" id="authorNameManual" name="authorName" class="input-control" required value="IT Support Specialist" style="width: 100%;" />
                        </div>
                        <div class="form-group full-width">
                            <label class="form-label" for="symptoms">Reported Symptoms &amp; Behavior *</label>
                            <textarea id="symptoms" name="symptoms" class="input-control form-textarea" required placeholder="What does the user experience? What error codes are shown?" style="width: 100%; min-height: 80px;"></textarea>
                        </div>
                        <div class="form-group full-width">
                            <label class="form-label" for="rootCauseManual">Root Cause *</label>
                            <input type="text" id="rootCauseManual" name="rootCause" class="input-control" required placeholder="Technical explanation of why the failure occurs..." style="width: 100%;" />
                        </div>
                        <div class="form-group full-width">
                            <label class="form-label" for="resolutionSteps">Step-by-Step Resolution Procedures *</label>
                            <textarea id="resolutionSteps" name="resolutionSteps" class="input-control form-textarea" required placeholder="1. Step one...&#10;2. Step two...&#10;3. Verification command..." style="width: 100%; min-height: 140px;"></textarea>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>

            <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 20px;">
                <a href="${pageContext.request.contextPath}/kb" class="btn btn-secondary">Cancel</a>
                <button type="submit" class="btn btn-primary">
                    <i data-lucide="check" class="icon-sm"></i>
                    <span>${not empty sourceTicket ? 'Publish to Knowledge Base' : 'Create Article'}</span>
                </button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="footer.jsp" />
