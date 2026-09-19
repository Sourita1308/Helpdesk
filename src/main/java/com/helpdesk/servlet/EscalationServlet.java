package com.helpdesk.servlet;

import com.helpdesk.service.EscalationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(name = "EscalationServlet", urlPatterns = {"/escalate", "/escalate/run-rules"})
public class EscalationServlet extends HttpServlet {
    private final EscalationService escalationService = new EscalationService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String servletPath = req.getServletPath();

        if ("/escalate/run-rules".equals(servletPath)) {
            int escalatedCount = escalationService.runAutoEscalationRules();
            resp.sendRedirect(req.getContextPath() + "/tickets?queue=second_line&msg=rules_run&count=" + escalatedCount);
            return;
        }

        // Manual Escalation
        int ticketId = Integer.parseInt(req.getParameter("ticketId"));
        String reason = req.getParameter("reason");
        String escalatedBy = req.getParameter("escalatedBy");
        String targetAgentStr = req.getParameter("targetAgentId");
        Integer targetAgentId = (targetAgentStr != null && !targetAgentStr.isEmpty()) ? Integer.parseInt(targetAgentStr) : null;

        if (escalatedBy == null || escalatedBy.trim().isEmpty()) {
            escalatedBy = "First-Line Agent";
        }

        escalationService.manualEscalate(ticketId, reason, escalatedBy, targetAgentId);
        resp.sendRedirect(req.getContextPath() + "/tickets/view?id=" + ticketId + "&msg=escalated");
    }
}
