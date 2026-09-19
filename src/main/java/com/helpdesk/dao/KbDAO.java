package com.helpdesk.dao;

import com.helpdesk.model.KbArticle;
import com.helpdesk.model.Ticket;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class KbDAO {

    public List<KbArticle> searchArticles(String keyword, String category) {
        List<KbArticle> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM kb_articles WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (category != null && !category.isEmpty() && !"all".equalsIgnoreCase(category)) {
            sql.append("AND category = ? ");
            params.add(category);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (title LIKE ? OR symptoms LIKE ? OR root_cause LIKE ? OR resolution_steps LIKE ?) ");
            String term = "%" + keyword.trim() + "%";
            params.add(term);
            params.add(term);
            params.add(term);
            params.add(term);
        }

        sql.append("ORDER BY view_count DESC, id DESC");

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapArticle(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public KbArticle getArticleById(int id) {
        String sql = "SELECT * FROM kb_articles WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    incrementViewCount(id);
                    return mapArticle(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public int createArticle(KbArticle a) {
        String sql = "INSERT INTO kb_articles (title, category, symptoms, root_cause, resolution_steps, source_ticket_id, author_name, view_count) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, 0)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, a.getTitle());
            ps.setString(2, a.getCategory());
            ps.setString(3, a.getSymptoms());
            ps.setString(4, a.getRootCause());
            ps.setString(5, a.getResolutionSteps());
            if (a.getSourceTicketId() != null && a.getSourceTicketId() > 0) {
                ps.setInt(6, a.getSourceTicketId());
            } else {
                ps.setNull(6, java.sql.Types.INTEGER);
            }
            ps.setString(7, a.getAuthorName());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public void incrementViewCount(int id) {
        String sql = "UPDATE kb_articles SET view_count = view_count + 1 WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public int createFromTicket(Ticket ticket, String rootCause, String authorName) {
        KbArticle a = new KbArticle();
        a.setTitle("Resolution for: " + ticket.getTitle());
        a.setCategory(ticket.getCategory());
        a.setSymptoms(ticket.getDescription());
        a.setRootCause(rootCause != null && !rootCause.isEmpty() ? rootCause : "Identified during ticket investigation.");
        a.setResolutionSteps(ticket.getResolutionNotes() != null ? ticket.getResolutionNotes() : "Issue investigated and resolved by support engineer.");
        a.setSourceTicketId(ticket.getId());
        a.setAuthorName(authorName != null ? authorName : "Support Team");
        return createArticle(a);
    }

    private KbArticle mapArticle(ResultSet rs) throws SQLException {
        KbArticle a = new KbArticle();
        a.setId(rs.getInt("id"));
        a.setTitle(rs.getString("title"));
        a.setCategory(rs.getString("category"));
        a.setSymptoms(rs.getString("symptoms"));
        a.setRootCause(rs.getString("root_cause"));
        a.setResolutionSteps(rs.getString("resolution_steps"));
        int srcId = rs.getInt("source_ticket_id");
        if (!rs.wasNull()) {
            a.setSourceTicketId(srcId);
        }
        a.setAuthorName(rs.getString("author_name"));
        a.setViewCount(rs.getInt("view_count"));
        a.setCreatedAt(rs.getTimestamp("created_at"));
        return a;
    }
}
