package com.helpdesk.servlet;

import com.helpdesk.dao.AssetDAO;
import com.helpdesk.dao.DBUtil;
import com.helpdesk.dao.TicketDAO;
import com.helpdesk.model.Asset;
import com.helpdesk.model.Ticket;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "DashboardServlet", urlPatterns = {"", "/dashboard"})
public class DashboardServlet extends HttpServlet {
    private final TicketDAO ticketDAO = new TicketDAO();
    private final AssetDAO assetDAO = new AssetDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Map<String, Object> metrics = ticketDAO.getDashboardMetrics();
        List<Ticket> recentTickets = ticketDAO.getTickets("all", null, null, null);
        List<Asset> repeatAssets = assetDAO.getRepeatIssueAssets();

        req.setAttribute("metrics", metrics);
        req.setAttribute("recentTickets", recentTickets.stream().limit(8).toList());
        req.setAttribute("repeatAssets", repeatAssets);
        req.setAttribute("activeDb", DBUtil.getActiveDatabase());
        req.setAttribute("isFallback", DBUtil.isFallbackMode());

        req.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(req, resp);
    }
}
