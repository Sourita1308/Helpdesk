package com.helpdesk.dao;

import com.helpdesk.model.EscalationLog;
import com.helpdesk.model.Ticket;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TicketDAO {

    public List<Ticket> getTickets(String queueFilter, String priorityFilter, String categoryFilter, String search) {
        checkAndMarkBreaches();
        List<Ticket> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT t.*, req.name AS requester_name, req.email AS requester_email, ")
           .append("ass.name AS assignee_name, a.asset_tag, a.name AS asset_name ")
           .append("FROM tickets t ")
           .append("JOIN users req ON t.requester_id = req.id ")
           .append("LEFT JOIN users ass ON t.assignee_id = ass.id ")
           .append("LEFT JOIN assets a ON t.asset_id = a.id ")
           .append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (queueFilter != null && !queueFilter.isEmpty() && !"all".equalsIgnoreCase(queueFilter)) {
            switch (queueFilter.toLowerCase()) {
                case "first_line":
                    sql.append("AND t.support_tier = 'First-Line' AND t.status NOT IN ('Resolved', 'Closed') ");
                    break;
                case "second_line":
                case "escalated":
                    sql.append("AND (t.support_tier = 'Second-Line' OR t.status = 'Escalated') AND t.status NOT IN ('Resolved', 'Closed') ");
                    break;
                case "open":
                    sql.append("AND t.status IN ('Open', 'In Progress') ");
                    break;
                case "breached":
                    sql.append("AND t.sla_breached = TRUE AND t.status NOT IN ('Resolved', 'Closed') ");
                    break;
                case "unassigned":
                    sql.append("AND t.assignee_id IS NULL AND t.status NOT IN ('Resolved', 'Closed') ");
                    break;
                case "resolved":
                    sql.append("AND t.status IN ('Resolved', 'Closed') ");
                    break;
            }
        }

        if (priorityFilter != null && !priorityFilter.isEmpty() && !"all".equalsIgnoreCase(priorityFilter)) {
            sql.append("AND t.priority = ? ");
            params.add(priorityFilter);
        }

        if (categoryFilter != null && !categoryFilter.isEmpty() && !"all".equalsIgnoreCase(categoryFilter)) {
            sql.append("AND t.category = ? ");
            params.add(categoryFilter);
        }

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (t.ticket_number LIKE ? OR t.title LIKE ? OR t.description LIKE ? OR req.name LIKE ? OR a.asset_tag LIKE ?) ");
            String term = "%" + search.trim() + "%";
            for (int i = 0; i < 5; i++) {
                params.add(term);
            }
        }

        sql.append("ORDER BY t.sla_breached DESC, t.sla_deadline ASC, t.id DESC");

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapTicket(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Ticket getTicketById(int id) {
        checkAndMarkBreaches();
        String sql = "SELECT t.*, req.name AS requester_name, req.email AS requester_email, " +
                     "ass.name AS assignee_name, a.asset_tag, a.name AS asset_name " +
                     "FROM tickets t " +
                     "JOIN users req ON t.requester_id = req.id " +
                     "LEFT JOIN users ass ON t.assignee_id = ass.id " +
                     "LEFT JOIN assets a ON t.asset_id = a.id " +
                     "WHERE t.id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapTicket(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Ticket> getTicketsByAsset(int assetId) {
        List<Ticket> list = new ArrayList<>();
        String sql = "SELECT t.*, req.name AS requester_name, req.email AS requester_email, " +
                     "ass.name AS assignee_name, a.asset_tag, a.name AS asset_name " +
                     "FROM tickets t " +
                     "JOIN users req ON t.requester_id = req.id " +
                     "LEFT JOIN users ass ON t.assignee_id = ass.id " +
                     "LEFT JOIN assets a ON t.asset_id = a.id " +
                     "WHERE t.asset_id = ? " +
                     "ORDER BY t.created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, assetId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapTicket(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int createTicket(Ticket ticket) {
        // Calculate SLA based on priority
        Instant now = Instant.now();
        Instant deadline;
        String priority = ticket.getPriority() != null ? ticket.getPriority() : "Medium";
        switch (priority.toLowerCase()) {
            case "critical":
                deadline = now.plus(2, ChronoUnit.HOURS);
                break;
            case "high":
                deadline = now.plus(4, ChronoUnit.HOURS);
                break;
            case "medium":
                deadline = now.plus(8, ChronoUnit.HOURS);
                break;
            case "low":
            default:
                deadline = now.plus(24, ChronoUnit.HOURS);
                break;
        }

        String ticketNumber = "TCK-" + java.time.Year.now().getValue() + "-" + String.format("%04d", (int)(Math.random() * 9000 + 1000));
        ticket.setTicketNumber(ticketNumber);
        ticket.setSlaDeadline(Timestamp.from(deadline));
        if (ticket.getStatus() == null || ticket.getStatus().isEmpty()) {
            ticket.setStatus("Open");
        }
        if (ticket.getSupportTier() == null || ticket.getSupportTier().isEmpty()) {
            ticket.setSupportTier("First-Line");
        }

        String sql = "INSERT INTO tickets (ticket_number, title, description, category, priority, status, requester_id, assignee_id, support_tier, asset_id, sla_deadline, sla_breached) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, ticket.getTicketNumber());
            ps.setString(2, ticket.getTitle());
            ps.setString(3, ticket.getDescription());
            ps.setString(4, ticket.getCategory());
            ps.setString(5, ticket.getPriority());
            ps.setString(6, ticket.getStatus());
            ps.setInt(7, ticket.getRequesterId());
            if (ticket.getAssigneeId() != null && ticket.getAssigneeId() > 0) {
                ps.setInt(8, ticket.getAssigneeId());
            } else {
                ps.setNull(8, java.sql.Types.INTEGER);
            }
            ps.setString(9, ticket.getSupportTier());
            if (ticket.getAssetId() != null && ticket.getAssetId() > 0) {
                ps.setInt(10, ticket.getAssetId());
            } else {
                ps.setNull(10, java.sql.Types.INTEGER);
            }
            ps.setTimestamp(11, ticket.getSlaDeadline());
            ps.setBoolean(12, false);

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

    public boolean assignTicket(int ticketId, Integer assigneeId, String supportTier) {
        String sql = "UPDATE tickets SET assignee_id = ?, support_tier = ?, status = CASE WHEN status = 'Open' THEN 'In Progress' ELSE status END, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (assigneeId != null && assigneeId > 0) {
                ps.setInt(1, assigneeId);
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
            }
            ps.setString(2, supportTier != null ? supportTier : "First-Line");
            ps.setInt(3, ticketId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateStatus(int ticketId, String status, String resolutionNotes) {
        boolean isResolving = "Resolved".equalsIgnoreCase(status) || "Closed".equalsIgnoreCase(status);
        String sql = "UPDATE tickets SET status = ?, resolution_notes = COALESCE(?, resolution_notes), " +
                     "resolved_at = CASE WHEN ? THEN CURRENT_TIMESTAMP ELSE resolved_at END, " +
                     "updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, resolutionNotes);
            ps.setBoolean(3, isResolving);
            ps.setInt(4, ticketId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean escalateTicket(int ticketId, String toTier, String reason, String escalatedBy, Integer newAssigneeId) {
        String sql = "UPDATE tickets SET support_tier = ?, status = 'Escalated', assignee_id = COALESCE(?, assignee_id), updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // 1. Update ticket
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, toTier);
                    if (newAssigneeId != null && newAssigneeId > 0) {
                        ps.setInt(2, newAssigneeId);
                    } else {
                        ps.setNull(2, java.sql.Types.INTEGER);
                    }
                    ps.setInt(3, ticketId);
                    ps.executeUpdate();
                }

                // 2. Log escalation
                String logSql = "INSERT INTO escalation_logs (ticket_id, from_tier, to_tier, reason, escalated_by) " +
                                "VALUES (?, 'First-Line', ?, ?, ?)";
                try (PreparedStatement psLog = conn.prepareStatement(logSql)) {
                    psLog.setInt(1, ticketId);
                    psLog.setString(2, toTier);
                    psLog.setString(3, reason);
                    psLog.setString(4, escalatedBy);
                    psLog.executeUpdate();
                }

                conn.commit();
                return true;
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<EscalationLog> getEscalationLogs(int ticketId) {
        List<EscalationLog> list = new ArrayList<>();
        String sql = "SELECT e.*, t.ticket_number, t.title AS ticket_title FROM escalation_logs e " +
                     "JOIN tickets t ON e.ticket_id = t.id " +
                     "WHERE e.ticket_id = ? " +
                     "ORDER BY e.escalated_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    EscalationLog log = new EscalationLog();
                    log.setId(rs.getInt("id"));
                    log.setTicketId(rs.getInt("ticket_id"));
                    log.setTicketNumber(rs.getString("ticket_number"));
                    log.setTicketTitle(rs.getString("ticket_title"));
                    log.setFromTier(rs.getString("from_tier"));
                    log.setToTier(rs.getString("to_tier"));
                    log.setReason(rs.getString("reason"));
                    log.setEscalatedBy(rs.getString("escalated_by"));
                    log.setEscalatedAt(rs.getTimestamp("escalated_at"));
                    list.add(log);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public void checkAndMarkBreaches() {
        String sql = "UPDATE tickets SET sla_breached = TRUE " +
                     "WHERE status NOT IN ('Resolved', 'Closed') " +
                     "AND sla_breached = FALSE " +
                     "AND sla_deadline < CURRENT_TIMESTAMP";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public Map<String, Object> getDashboardMetrics() {
        checkAndMarkBreaches();
        Map<String, Object> metrics = new HashMap<>();
        String sql = "SELECT " +
                     "COUNT(*) AS total_tickets, " +
                     "SUM(CASE WHEN status IN ('Open', 'In Progress') THEN 1 ELSE 0 END) AS open_tickets, " +
                     "SUM(CASE WHEN status = 'Escalated' OR support_tier = 'Second-Line' THEN 1 ELSE 0 END) AS escalated_tickets, " +
                     "SUM(CASE WHEN sla_breached = TRUE AND status NOT IN ('Resolved', 'Closed') THEN 1 ELSE 0 END) AS breached_tickets, " +
                     "SUM(CASE WHEN support_tier = 'First-Line' AND status NOT IN ('Resolved', 'Closed') THEN 1 ELSE 0 END) AS first_line_queue, " +
                     "SUM(CASE WHEN status IN ('Resolved', 'Closed') THEN 1 ELSE 0 END) AS resolved_count " +
                     "FROM tickets";
        try (Connection conn = DBUtil.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) {
                metrics.put("totalTickets", rs.getInt("total_tickets"));
                metrics.put("openTickets", rs.getInt("open_tickets"));
                metrics.put("escalatedTickets", rs.getInt("escalated_tickets"));
                metrics.put("breachedTickets", rs.getInt("breached_tickets"));
                metrics.put("firstLineQueue", rs.getInt("first_line_queue"));
                metrics.put("resolvedCount", rs.getInt("resolved_count"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return metrics;
    }

    private Ticket mapTicket(ResultSet rs) throws SQLException {
        Ticket t = new Ticket();
        t.setId(rs.getInt("id"));
        t.setTicketNumber(rs.getString("ticket_number"));
        t.setTitle(rs.getString("title"));
        t.setDescription(rs.getString("description"));
        t.setCategory(rs.getString("category"));
        t.setPriority(rs.getString("priority"));
        t.setStatus(rs.getString("status"));
        t.setRequesterId(rs.getInt("requester_id"));
        t.setRequesterName(rs.getString("requester_name"));
        t.setRequesterEmail(rs.getString("requester_email"));

        int assigneeId = rs.getInt("assignee_id");
        if (!rs.wasNull()) {
            t.setAssigneeId(assigneeId);
        }
        t.setAssigneeName(rs.getString("assignee_name"));
        t.setSupportTier(rs.getString("support_tier"));

        int assetId = rs.getInt("asset_id");
        if (!rs.wasNull()) {
            t.setAssetId(assetId);
        }
        t.setAssetTag(rs.getString("asset_tag"));
        t.setAssetName(rs.getString("asset_name"));

        t.setSlaDeadline(rs.getTimestamp("sla_deadline"));
        t.setSlaBreached(rs.getBoolean("sla_breached"));
        t.setResolutionNotes(rs.getString("resolution_notes"));
        t.setResolvedAt(rs.getTimestamp("resolved_at"));
        t.setCreatedAt(rs.getTimestamp("created_at"));
        t.setUpdatedAt(rs.getTimestamp("updated_at"));
        return t;
    }
}
