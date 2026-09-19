<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>${param.title != null ? param.title : "HelpDesk Lite"} — Modern IT Operations</title>
                <!-- Modern Google Typography -->
                <link rel="preconnect" href="https://fonts.googleapis.com">
                <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
                <link
                    href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600&display=swap"
                    rel="stylesheet">
                <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo.png">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
                <!-- Local Lucide Icons -->
                <script src="${pageContext.request.contextPath}/js/lucide.min.js"></script>
                <script>
                    (function() {
                        var theme = localStorage.getItem('helpdesk_theme') || 'dark';
                        document.documentElement.setAttribute('data-theme', theme);
                    })();
                    function toggleTheme() {
                        var current = document.documentElement.getAttribute('data-theme') || 'dark';
                        var target = current === 'light' ? 'dark' : 'light';
                        document.documentElement.setAttribute('data-theme', target);
                        localStorage.setItem('helpdesk_theme', target);
                        if (window.lucide) {
                            lucide.createIcons();
                        }
                    }
                </script>
            </head>

            <body>
                <div class="app-container">
                    <!-- Sidebar Navigation -->
                    <aside class="sidebar">
                        <a href="${pageContext.request.contextPath}/dashboard" class="sidebar-header-link">
                            <div class="sidebar-header">
                                <div class="brand-logo-wrap">
                                    <img src="${pageContext.request.contextPath}/images/logo.png" alt="HelpDesk Lite Logo" class="brand-logo-img">
                                </div>
                                <div class="brand-info">
                                    <div class="brand-title">HelpDesk Lite</div>
                                    <div class="brand-subtitle">IT Service &amp; Assets</div>
                                </div>
                            </div>
                        </a>

                        <nav class="sidebar-nav">
                            <div class="nav-section-title">Support Operations</div>
                            <a href="${pageContext.request.contextPath}/dashboard"
                                class="nav-link ${param.active == 'dashboard' ? 'active' : ''}">
                                <i data-lucide="layout-dashboard" class="nav-icon"></i>
                                <span>Dashboard</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/tickets"
                                class="nav-link ${param.active == 'tickets' ? 'active' : ''}">
                                <i data-lucide="ticket" class="nav-icon"></i>
                                <span>All Tickets</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/tickets?queue=first_line"
                                class="nav-link ${param.active == 'first_line' ? 'active' : ''}">
                                <i data-lucide="inbox" class="nav-icon"></i>
                                <span>First-Line Queue</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/tickets?queue=second_line"
                                class="nav-link ${param.active == 'second_line' ? 'active' : ''}">
                                <i data-lucide="flame" class="nav-icon text-amber"></i>
                                <span>Second-Line (L2)</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/tickets?queue=breached"
                                class="nav-link ${param.active == 'breached' ? 'active' : ''}">
                                <i data-lucide="alert-triangle" class="nav-icon text-danger"></i>
                                <span>SLA Breaches</span>
                            </a>

                            <div class="nav-section-title">Asset &amp; Knowledge</div>
                            <a href="${pageContext.request.contextPath}/assets"
                                class="nav-link ${param.active == 'assets' ? 'active' : ''}">
                                <i data-lucide="laptop" class="nav-icon"></i>
                                <span>Asset Register</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/assets/repeat-issues"
                                class="nav-link ${param.active == 'repeat_issues' ? 'active' : ''}">
                                <i data-lucide="refresh-cw" class="nav-icon text-warning"></i>
                                <span>Repeat-Issue Analysis</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/kb"
                                class="nav-link ${param.active == 'kb' ? 'active' : ''}">
                                <i data-lucide="book-open" class="nav-icon"></i>
                                <span>Knowledge Base</span>
                            </a>
                        </nav>

                        <div class="sidebar-footer">
                            <div class="db-status-badge">
                                <span class="status-pulse-dot"></span>
                                <span class="db-status-text">Engine: <strong>${not empty activeDb ? activeDb : 'MySQL
                                        8.0'}</strong></span>
                            </div>
                            <div class="desk-tier-indicator">
                                <i data-lucide="shield-check" class="icon-xs"></i>
                                <span>Tiers: L1 Triage &amp; L2 Active</span>
                            </div>
                        </div>
                    </aside>

                    <!-- Main Wrapper -->
                    <div class="main-wrapper">
                        <header class="topbar">
                            <div class="page-title-group">
                                <h1>${param.title}</h1>
                                <p>${param.subtitle}</p>
                            </div>
                            <div class="topbar-actions">
                                <button type="button" id="themeToggleBtn" class="theme-toggle-btn" onclick="toggleTheme()" title="Toggle Light / Dark Mode" aria-label="Toggle Light / Dark Mode">
                                    <span class="theme-toggle-track">
                                        <i data-lucide="moon" class="theme-icon moon"></i>
                                        <i data-lucide="sun" class="theme-icon sun"></i>
                                        <span class="theme-toggle-thumb"></span>
                                    </span>
                                </button>
                                <form action="${pageContext.request.contextPath}/escalate/run-rules" method="post"
                                    style="display:inline;">
                                    <button type="submit" class="btn btn-secondary btn-sm"
                                        title="Run automatic SLA check &amp; auto-escalate breached tickets to L2">
                                        <i data-lucide="zap" class="icon-sm text-warning"></i>
                                        <span>Run SLA Rules</span>
                                    </button>
                                </form>
                                <a href="${pageContext.request.contextPath}/tickets/new" class="btn btn-primary btn-sm">
                                    <i data-lucide="plus" class="icon-sm"></i>
                                    <span>New Ticket</span>
                                </a>
                                <a href="${pageContext.request.contextPath}/assets/new"
                                    class="btn btn-secondary btn-sm">
                                    <i data-lucide="plus-circle" class="icon-sm"></i>
                                    <span>New Asset</span>
                                </a>
                            </div>
                        </header>

                        <main class="content-body">
                            <c:if test="${param.msg == 'created'}">
                                <div class="alert-banner success">
                                    <i data-lucide="check-circle" class="alert-icon"></i>
                                    <span>Successfully created new record!</span>
                                </div>
                            </c:if>
                            <c:if test="${param.msg == 'updated'}">
                                <div class="alert-banner success">
                                    <i data-lucide="check-circle" class="alert-icon"></i>
                                    <span>Ticket status and resolution notes updated!</span>
                                </div>
                            </c:if>
                            <c:if test="${param.msg == 'assigned'}">
                                <div class="alert-banner info">
                                    <i data-lucide="info" class="alert-icon"></i>
                                    <span>Ticket re-assigned successfully.</span>
                                </div>
                            </c:if>
                            <c:if test="${param.msg == 'escalated'}">
                                <div class="alert-banner warning">
                                    <i data-lucide="alert-octagon" class="alert-icon"></i>
                                    <span>Ticket successfully escalated to Second-Line Engineering tier!</span>
                                </div>
                            </c:if>
                            <c:if test="${param.msg == 'rules_run'}">
                                <div class="alert-banner info">
                                    <i data-lucide="zap" class="alert-icon"></i>
                                    <span>Escalation rules evaluated: <strong>${param.count}</strong> ticket(s)
                                        automatically escalated to Second-Line tier.</span>
                                </div>
                            </c:if>
                            <c:if test="${param.msg == 'converted'}">
                                <div class="alert-banner success">
                                    <i data-lucide="book-check" class="alert-icon"></i>
                                    <span>Successfully converted resolved ticket into Knowledge Base article!</span>
                                </div>
                            </c:if>
                            <c:if test="${param.msg == 'maintenance_added'}">
                                <div class="alert-banner success">
                                    <i data-lucide="wrench" class="alert-icon"></i>
                                    <span>New installation / maintenance record saved!</span>
                                </div>
                            </c:if>