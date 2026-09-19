package com.helpdesk.servlet;

import com.helpdesk.dao.KbDAO;
import com.helpdesk.dao.TicketDAO;
import com.helpdesk.model.KbArticle;
import com.helpdesk.model.Ticket;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "KbServlet", urlPatterns = {"/kb", "/kb/view", "/kb/new", "/kb/convert"})
public class KbServlet extends HttpServlet {
    private final KbDAO kbDAO = new KbDAO();
    private final TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String servletPath = req.getServletPath();

        if ("/kb/view".equals(servletPath)) {
            showArticle(req, resp);
        } else if ("/kb/new".equals(servletPath)) {
            showNewArticleForm(req, resp);
        } else {
            showArticleList(req, resp);
        }
    }

    private void showArticleList(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword = req.getParameter("q");
        String category = req.getParameter("category");

        List<KbArticle> articles = kbDAO.searchArticles(keyword, category);
        req.setAttribute("articles", articles);
        req.setAttribute("currentCategory", category);
        req.setAttribute("keyword", keyword);

        req.getRequestDispatcher("/WEB-INF/views/kb.jsp").forward(req, resp);
    }

    private void showArticle(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/kb");
            return;
        }

        int id = Integer.parseInt(idStr);
        KbArticle article = kbDAO.getArticleById(id);
        if (article == null) {
            resp.sendRedirect(req.getContextPath() + "/kb");
            return;
        }

        req.setAttribute("article", article);
        req.getRequestDispatcher("/WEB-INF/views/kb-detail.jsp").forward(req, resp);
    }

    private void showNewArticleForm(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String ticketIdStr = req.getParameter("ticketId");
        if (ticketIdStr != null && !ticketIdStr.isEmpty()) {
            Ticket ticket = ticketDAO.getTicketById(Integer.parseInt(ticketIdStr));
            if (ticket != null) {
                req.setAttribute("sourceTicket", ticket);
            }
        }
        req.getRequestDispatcher("/WEB-INF/views/kb-new.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String servletPath = req.getServletPath();

        if ("/kb/convert".equals(servletPath)) {
            handleConvertTicket(req, resp);
        } else if ("/kb/new".equals(servletPath)) {
            handleCreateArticle(req, resp);
        }
    }

    private void handleConvertTicket(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int ticketId = Integer.parseInt(req.getParameter("ticketId"));
        String rootCause = req.getParameter("rootCause");
        String authorName = req.getParameter("authorName");

        Ticket ticket = ticketDAO.getTicketById(ticketId);
        if (ticket != null) {
            int kbId = kbDAO.createFromTicket(ticket, rootCause, authorName);
            resp.sendRedirect(req.getContextPath() + "/kb/view?id=" + kbId + "&msg=converted");
        } else {
            resp.sendRedirect(req.getContextPath() + "/kb");
        }
    }

    private void handleCreateArticle(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String title = req.getParameter("title");
        String category = req.getParameter("category");
        String symptoms = req.getParameter("symptoms");
        String rootCause = req.getParameter("rootCause");
        String resolutionSteps = req.getParameter("resolutionSteps");
        String authorName = req.getParameter("authorName");

        KbArticle a = new KbArticle();
        a.setTitle(title);
        a.setCategory(category);
        a.setSymptoms(symptoms);
        a.setRootCause(rootCause);
        a.setResolutionSteps(resolutionSteps);
        a.setAuthorName(authorName != null && !authorName.isEmpty() ? authorName : "Support Engineer");

        int kbId = kbDAO.createArticle(a);
        resp.sendRedirect(req.getContextPath() + "/kb/view?id=" + kbId + "&msg=created");
    }
}
