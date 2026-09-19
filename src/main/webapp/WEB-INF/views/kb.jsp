<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="header.jsp">
    <jsp:param name="title" value="IT Knowledge Base" />
    <jsp:param name="subtitle" value="Repository of verified technical resolutions to cut repeat handling time" />
    <jsp:param name="active" value="kb" />
</jsp:include>

<!-- Search & Category Filters -->
<form action="${pageContext.request.contextPath}/kb" method="get" class="filter-bar">
    <div class="search-input-wrapper">
        <i data-lucide="search" class="search-icon-embedded"></i>
        <input type="text" name="q" class="input-control with-icon" placeholder="Search by symptom, keyword, error code..." value="${keyword}" style="min-width: 340px;" />
    </div>

    <div class="filter-group">
        <select name="category" class="select-control">
            <option value="">All Categories</option>
            <option value="Hardware" ${currentCategory == 'Hardware' ? 'selected' : ''}>Hardware</option>
            <option value="Software" ${currentCategory == 'Software' ? 'selected' : ''}>Software</option>
            <option value="Network" ${currentCategory == 'Network' ? 'selected' : ''}>Network</option>
            <option value="Access & Security" ${currentCategory == 'Access & Security' ? 'selected' : ''}>Access &amp; Security</option>
        </select>
    </div>

    <button type="submit" class="btn btn-secondary btn-sm">
        <i data-lucide="filter" class="icon-sm"></i>
        <span>Search</span>
    </button>
    <c:if test="${not empty keyword || not empty currentCategory}">
        <a href="${pageContext.request.contextPath}/kb" class="btn btn-sm" style="color: var(--text-muted);">Reset</a>
    </c:if>
</form>

<div class="card">
    <div class="card-header">
        <div class="card-title">
            <i data-lucide="book-open" class="icon-md" style="color: #818cf8;"></i>
            <span>Verified Solutions &amp; Runbooks (${articles.size()})</span>
        </div>
        <a href="${pageContext.request.contextPath}/kb/new" class="btn btn-primary btn-sm">
            <i data-lucide="plus" class="icon-sm"></i>
            <span>New KB Article</span>
        </a>
    </div>
    <div class="table-responsive">
        <table class="data-table">
            <thead>
                <tr>
                    <th>Article Title</th>
                    <th>Category</th>
                    <th>Symptoms Overview</th>
                    <th>Author</th>
                    <th>Popularity</th>
                    <th>Created</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty articles}">
                        <tr>
                            <td colspan="7" style="text-align: center; padding: 48px; color: var(--text-muted);">
                                No Knowledge Base articles found matching your query.
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="art" items="${articles}">
                            <tr>
                                <td>
                                    <a href="${pageContext.request.contextPath}/kb/view?id=${art.id}" style="color: #fff; font-weight: 700; text-decoration: none; font-size: 0.95rem;">
                                        ${art.title}
                                    </a>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${art.category == 'Network'}">
                                            <span class="badge-cat badge-cat-network"><i data-lucide="wifi" class="icon-xs"></i> Network</span>
                                        </c:when>
                                        <c:when test="${art.category == 'Hardware'}">
                                            <span class="badge-cat badge-cat-hardware"><i data-lucide="cpu" class="icon-xs"></i> Hardware</span>
                                        </c:when>
                                        <c:when test="${art.category == 'Software'}">
                                            <span class="badge-cat badge-cat-software"><i data-lucide="code" class="icon-xs"></i> Software</span>
                                        </c:when>
                                        <c:when test="${art.category == 'Access & Security'}">
                                            <span class="badge-cat badge-cat-access"><i data-lucide="shield" class="icon-xs"></i> Security</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-cat badge-cat-infra">${art.category}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div style="max-width: 380px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; color: var(--text-secondary); font-size: 0.84rem;">
                                        ${art.symptoms}
                                    </div>
                                </td>
                                <td>
                                    <span style="font-size: 0.84rem; color: #e2e8f0;">${art.authorName}</span>
                                </td>
                                <td>
                                    <span style="font-size: 0.82rem; color: #818cf8; font-weight: 600; display: inline-flex; align-items: center; gap: 5px;">
                                        <i data-lucide="eye" class="icon-xs"></i> ${art.viewCount} views
                                    </span>
                                </td>
                                <td>
                                    <span style="font-size: 0.78rem; color: var(--text-muted); font-family: var(--font-mono);">${art.createdAt}</span>
                                </td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/kb/view?id=${art.id}" class="btn btn-action">
                                        <span>Read Guide</span>
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
