package com.helpdesk.servlet;

import com.helpdesk.dao.AssetDAO;
import com.helpdesk.dao.MaintenanceDAO;
import com.helpdesk.dao.TicketDAO;
import com.helpdesk.dao.UserDAO;
import com.helpdesk.model.Asset;
import com.helpdesk.model.MaintenanceLog;
import com.helpdesk.model.Ticket;
import com.helpdesk.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;

@WebServlet(name = "AssetServlet", urlPatterns = {"/assets", "/assets/view", "/assets/new", "/assets/maintenance", "/assets/repeat-issues"})
public class AssetServlet extends HttpServlet {
    private final AssetDAO assetDAO = new AssetDAO();
    private final MaintenanceDAO maintenanceDAO = new MaintenanceDAO();
    private final TicketDAO ticketDAO = new TicketDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String servletPath = req.getServletPath();

        if ("/assets/view".equals(servletPath)) {
            showAssetDetail(req, resp);
        } else if ("/assets/new".equals(servletPath)) {
            showNewAssetForm(req, resp);
        } else if ("/assets/repeat-issues".equals(servletPath)) {
            showRepeatIssues(req, resp);
        } else {
            showAssetList(req, resp);
        }
    }

    private void showAssetList(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String category = req.getParameter("category");
        String status = req.getParameter("status");
        String search = req.getParameter("search");

        List<Asset> assets = assetDAO.getAllAssets(category, status, search);
        List<Asset> repeatRisks = assetDAO.getRepeatIssueAssets();

        req.setAttribute("assets", assets);
        req.setAttribute("repeatRiskCount", repeatRisks.size());
        req.setAttribute("currentCategory", category);
        req.setAttribute("currentStatus", status);
        req.setAttribute("currentSearch", search);

        req.getRequestDispatcher("/WEB-INF/views/assets.jsp").forward(req, resp);
    }

    private void showRepeatIssues(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Asset> repeatAssets = assetDAO.getRepeatIssueAssets();
        req.setAttribute("repeatAssets", repeatAssets);
        req.getRequestDispatcher("/WEB-INF/views/repeat-issues.jsp").forward(req, resp);
    }

    private void showAssetDetail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/assets");
            return;
        }

        int assetId = Integer.parseInt(idStr);
        Asset asset = assetDAO.getAssetById(assetId);
        if (asset == null) {
            resp.sendRedirect(req.getContextPath() + "/assets");
            return;
        }

        List<MaintenanceLog> maintenanceLogs = maintenanceDAO.getLogsByAsset(assetId);
        List<Ticket> linkedTickets = ticketDAO.getTicketsByAsset(assetId);
        List<User> users = userDAO.getAllUsers();

        req.setAttribute("asset", asset);
        req.setAttribute("maintenanceLogs", maintenanceLogs);
        req.setAttribute("linkedTickets", linkedTickets);
        req.setAttribute("users", users);

        req.getRequestDispatcher("/WEB-INF/views/asset-detail.jsp").forward(req, resp);
    }

    private void showNewAssetForm(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<User> users = userDAO.getAllUsers();
        req.setAttribute("users", users);
        req.getRequestDispatcher("/WEB-INF/views/asset-new.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String servletPath = req.getServletPath();

        if ("/assets/new".equals(servletPath)) {
            handleCreateAsset(req, resp);
        } else if ("/assets/maintenance".equals(servletPath)) {
            handleAddMaintenance(req, resp);
        }
    }

    private void handleCreateAsset(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String assetTag = req.getParameter("assetTag");
        String name = req.getParameter("name");
        String type = req.getParameter("type");
        String category = req.getParameter("category");
        String serialNumber = req.getParameter("serialNumber");
        String purchaseDateStr = req.getParameter("purchaseDate");
        String warrantyExpiryStr = req.getParameter("warrantyExpiry");
        String status = req.getParameter("status");
        String assignedUserStr = req.getParameter("assignedUserId");
        String specs = req.getParameter("specsOrLicense");

        Asset a = new Asset();
        a.setAssetTag(assetTag);
        a.setName(name);
        a.setType(type);
        a.setCategory(category);
        a.setSerialNumber(serialNumber);
        if (purchaseDateStr != null && !purchaseDateStr.isEmpty()) {
            a.setPurchaseDate(Date.valueOf(purchaseDateStr));
        }
        if (warrantyExpiryStr != null && !warrantyExpiryStr.isEmpty()) {
            a.setWarrantyExpiry(Date.valueOf(warrantyExpiryStr));
        }
        a.setStatus(status != null ? status : "Allocated");
        if (assignedUserStr != null && !assignedUserStr.isEmpty()) {
            a.setAssignedUserId(Integer.parseInt(assignedUserStr));
        }
        a.setSpecsOrLicense(specs);

        int id = assetDAO.createAsset(a);
        resp.sendRedirect(req.getContextPath() + "/assets/view?id=" + id + "&msg=created");
    }

    private void handleAddMaintenance(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int assetId = Integer.parseInt(req.getParameter("assetId"));
        String serviceType = req.getParameter("serviceType");
        String technicianName = req.getParameter("technicianName");
        String serviceDateStr = req.getParameter("serviceDate");
        String costStr = req.getParameter("cost");
        String notes = req.getParameter("notes");

        MaintenanceLog log = new MaintenanceLog();
        log.setAssetId(assetId);
        log.setServiceType(serviceType);
        log.setTechnicianName(technicianName);
        log.setServiceDate(serviceDateStr != null && !serviceDateStr.isEmpty() ? Date.valueOf(serviceDateStr) : new Date(System.currentTimeMillis()));
        log.setCost(costStr != null && !costStr.isEmpty() ? new BigDecimal(costStr) : BigDecimal.ZERO);
        log.setNotes(notes);

        maintenanceDAO.addLog(log);
        resp.sendRedirect(req.getContextPath() + "/assets/view?id=" + assetId + "&msg=maintenance_added");
    }
}
