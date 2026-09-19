package com.helpdesk.servlet;

import com.helpdesk.dao.AssetDAO;
import com.helpdesk.dao.KbDAO;
import com.helpdesk.dao.TicketDAO;
import com.helpdesk.dao.UserDAO;
import com.helpdesk.model.Asset;
import com.helpdesk.model.EscalationLog;
import com.helpdesk.model.KbArticle;
import com.helpdesk.model.Ticket;
import com.helpdesk.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "TicketServlet", urlPatterns = {"/tickets", "/tickets/new", "/tickets/view", "/tickets/update", "/tickets/assign"})
public class TicketServlet extends HttpServlet {
    private final TicketDAO ticketDAO = new TicketDAO();
    private final UserDAO userDAO = new UserDAO();
    private final AssetDAO assetDAO = new AssetDAO();
    private final KbDAO kbDAO = new KbDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String servletPath = req.getServletPath();

        if ("/tickets/new".equals(servletPath)) {
            showNewTicketForm(req, resp);
        } else if ("/tickets/view".equals(servletPath)) {
            showTicketDetail(req, resp);
        } else {
            showTicketList(req, resp);
        }
    }

    private void showTicketList(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String queue = req.getParameter("queue");
        String priority = req.getParameter("priority");
        String category = req.getParameter("category");
        String search = req.getParameter("search");

        List<Ticket> tickets = ticketDAO.getTickets(queue, priority, category, search);
        req.setAttribute("tickets", tickets);
        req.setAttribute("currentQueue", queue != null ? queue : "all");
        req.setAttribute("currentPriority", priority);
        req.setAttribute("currentCategory", category);
        req.setAttribute("currentSearch", search);

        req.getRequestDispatcher("/WEB-INF/views/tickets.jsp").forward(req, resp);
    }

    private void showNewTicketForm(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<User> users = userDAO.getAllUsers();
        List<User> agents = userDAO.getAgents(null);
        List<Asset> assets = assetDAO.getAllAssets(null, null, null);

        req.setAttribute("users", users);
        req.setAttribute("agents", agents);
        req.setAttribute("assets", assets);

        String preselectedAsset = req.getParameter("assetId");
        if (preselectedAsset != null && !preselectedAsset.isEmpty()) {
            req.setAttribute("preselectedAssetId", preselectedAsset);
        }

        req.getRequestDispatcher("/WEB-INF/views/ticket-new.jsp").forward(req, resp);
    }

    private void showTicketDetail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/tickets");
            return;
        }

        int ticketId = Integer.parseInt(idStr);
        Ticket ticket = ticketDAO.getTicketById(ticketId);
        if (ticket == null) {
            resp.sendRedirect(req.getContextPath() + "/tickets");
            return;
        }

        List<User> l1Agents = userDAO.getAgents("First-Line");
        List<User> l2Agents = userDAO.getAgents("Second-Line");
        List<EscalationLog> escalationLogs = ticketDAO.getEscalationLogs(ticketId);

        // Fetch suggested KB articles based on ticket title/category
        List<KbArticle> suggestedKb = kbDAO.searchArticles(ticket.getTitle().split(" ")[0], ticket.getCategory());

        // Asset details if linked
        if (ticket.getAssetId() != null) {
            Asset asset = assetDAO.getAssetById(ticket.getAssetId());
            req.setAttribute("asset", asset);
            List<Ticket> repeatTickets = ticketDAO.getTicketsByAsset(ticket.getAssetId());
            req.setAttribute("assetTickets", repeatTickets);
        }

        req.setAttribute("ticket", ticket);
        req.setAttribute("l1Agents", l1Agents);
        req.setAttribute("l2Agents", l2Agents);
        req.setAttribute("escalationLogs", escalationLogs);
        req.setAttribute("suggestedKb", suggestedKb);

        req.getRequestDispatcher("/WEB-INF/views/ticket-detail.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String servletPath = req.getServletPath();

        if ("/tickets/new".equals(servletPath)) {
            handleCreateTicket(req, resp);
        } else if ("/tickets/update".equals(servletPath)) {
            handleUpdateStatus(req, resp);
        } else if ("/tickets/assign".equals(servletPath)) {
            handleAssignTicket(req, resp);
        }
    }

    private void handleCreateTicket(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String title = req.getParameter("title");
        String description = req.getParameter("description");
        String category = req.getParameter("category");
        String priority = req.getParameter("priority");
        int requesterId = Integer.parseInt(req.getParameter("requesterId"));

        String assigneeStr = req.getParameter("assigneeId");
        Integer assigneeId = (assigneeStr != null && !assigneeStr.isEmpty()) ? Integer.parseInt(assigneeStr) : null;

        String assetStr = req.getParameter("assetId");
        Integer assetId = (assetStr != null && !assetStr.isEmpty()) ? Integer.parseInt(assetStr) : null;

        Ticket t = new Ticket();
        t.setTitle(title);
        t.setDescription(description);
        t.setCategory(category);
        t.setPriority(priority);
        t.setRequesterId(requesterId);
        t.setAssigneeId(assigneeId);
        t.setAssetId(assetId);
        t.setSupportTier("First-Line");

        int id = ticketDAO.createTicket(t);
        resp.sendRedirect(req.getContextPath() + "/tickets/view?id=" + id + "&msg=created");
    }

    private void handleUpdateStatus(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int ticketId = Integer.parseInt(req.getParameter("ticketId"));
        String status = req.getParameter("status");
        String resolutionNotes = req.getParameter("resolutionNotes");

        ticketDAO.updateStatus(ticketId, status, resolutionNotes);
        resp.sendRedirect(req.getContextPath() + "/tickets/view?id=" + ticketId + "&msg=updated");
    }

    private void handleAssignTicket(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int ticketId = Integer.parseInt(req.getParameter("ticketId"));
        String assigneeStr = req.getParameter("assigneeId");
        Integer assigneeId = (assigneeStr != null && !assigneeStr.isEmpty()) ? Integer.parseInt(assigneeStr) : null;
        String tier = req.getParameter("supportTier");

        ticketDAO.assignTicket(ticketId, assigneeId, tier);
        resp.sendRedirect(req.getContextPath() + "/tickets/view?id=" + ticketId + "&msg=assigned");
    }
}
