package com.helpdesk.dao;

import com.helpdesk.model.Asset;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class AssetDAO {

    public List<Asset> getAllAssets(String categoryFilter, String statusFilter, String search) {
        List<Asset> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT a.*, u.name AS assigned_user_name, ")
           .append("(SELECT COUNT(*) FROM tickets t WHERE t.asset_id = a.id) AS ticket_count, ")
           .append("(SELECT COUNT(*) FROM tickets t WHERE t.asset_id = a.id AND t.status NOT IN ('Resolved', 'Closed')) AS open_ticket_count, ")
           .append("(SELECT COUNT(*) FROM maintenance_logs m WHERE m.asset_id = a.id) AS maintenance_count ")
           .append("FROM assets a ")
           .append("LEFT JOIN users u ON a.assigned_user_id = u.id ")
           .append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();
        if (categoryFilter != null && !categoryFilter.isEmpty() && !"all".equalsIgnoreCase(categoryFilter)) {
            sql.append("AND a.category = ? ");
            params.add(categoryFilter);
        }
        if (statusFilter != null && !statusFilter.isEmpty() && !"all".equalsIgnoreCase(statusFilter)) {
            sql.append("AND a.status = ? ");
            params.add(statusFilter);
        }
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (a.asset_tag LIKE ? OR a.name LIKE ? OR a.serial_number LIKE ? OR u.name LIKE ?) ");
            String term = "%" + search.trim() + "%";
            params.add(term);
            params.add(term);
            params.add(term);
            params.add(term);
        }
        sql.append("ORDER BY a.asset_tag ASC");

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapAsset(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Asset getAssetById(int id) {
        String sql = "SELECT a.*, u.name AS assigned_user_name, " +
                     "(SELECT COUNT(*) FROM tickets t WHERE t.asset_id = a.id) AS ticket_count, " +
                     "(SELECT COUNT(*) FROM tickets t WHERE t.asset_id = a.id AND t.status NOT IN ('Resolved', 'Closed')) AS open_ticket_count, " +
                     "(SELECT COUNT(*) FROM maintenance_logs m WHERE m.asset_id = a.id) AS maintenance_count " +
                     "FROM assets a " +
                     "LEFT JOIN users u ON a.assigned_user_id = u.id " +
                     "WHERE a.id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapAsset(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Asset> getRepeatIssueAssets() {
        List<Asset> list = new ArrayList<>();
        String sql = "SELECT a.*, u.name AS assigned_user_name, " +
                     "(SELECT COUNT(*) FROM tickets t WHERE t.asset_id = a.id) AS ticket_count, " +
                     "(SELECT COUNT(*) FROM tickets t WHERE t.asset_id = a.id AND t.status NOT IN ('Resolved', 'Closed')) AS open_ticket_count, " +
                     "(SELECT COUNT(*) FROM maintenance_logs m WHERE m.asset_id = a.id) AS maintenance_count " +
                     "FROM assets a " +
                     "LEFT JOIN users u ON a.assigned_user_id = u.id " +
                     "WHERE (SELECT COUNT(*) FROM tickets t WHERE t.asset_id = a.id) >= 2 " +
                     "ORDER BY ticket_count DESC, a.id ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapAsset(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int createAsset(Asset asset) {
        String sql = "INSERT INTO assets (asset_tag, name, type, category, serial_number, purchase_date, warranty_expiry, status, assigned_user_id, specs_or_license) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, asset.getAssetTag());
            ps.setString(2, asset.getName());
            ps.setString(3, asset.getType());
            ps.setString(4, asset.getCategory());
            ps.setString(5, asset.getSerialNumber());
            ps.setDate(6, asset.getPurchaseDate());
            ps.setDate(7, asset.getWarrantyExpiry());
            ps.setString(8, asset.getStatus() != null ? asset.getStatus() : "Allocated");
            if (asset.getAssignedUserId() != null && asset.getAssignedUserId() > 0) {
                ps.setInt(9, asset.getAssignedUserId());
            } else {
                ps.setNull(9, java.sql.Types.INTEGER);
            }
            ps.setString(10, asset.getSpecsOrLicense());

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

    public boolean updateAsset(Asset asset) {
        String sql = "UPDATE assets SET name=?, type=?, category=?, serial_number=?, purchase_date=?, warranty_expiry=?, status=?, assigned_user_id=?, specs_or_license=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, asset.getName());
            ps.setString(2, asset.getType());
            ps.setString(3, asset.getCategory());
            ps.setString(4, asset.getSerialNumber());
            ps.setDate(5, asset.getPurchaseDate());
            ps.setDate(6, asset.getWarrantyExpiry());
            ps.setString(7, asset.getStatus());
            if (asset.getAssignedUserId() != null && asset.getAssignedUserId() > 0) {
                ps.setInt(8, asset.getAssignedUserId());
            } else {
                ps.setNull(8, java.sql.Types.INTEGER);
            }
            ps.setString(9, asset.getSpecsOrLicense());
            ps.setInt(10, asset.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Asset mapAsset(ResultSet rs) throws SQLException {
        Asset a = new Asset();
        a.setId(rs.getInt("id"));
        a.setAssetTag(rs.getString("asset_tag"));
        a.setName(rs.getString("name"));
        a.setType(rs.getString("type"));
        a.setCategory(rs.getString("category"));
        a.setSerialNumber(rs.getString("serial_number"));
        a.setPurchaseDate(rs.getDate("purchase_date"));
        a.setWarrantyExpiry(rs.getDate("warranty_expiry"));
        a.setStatus(rs.getString("status"));
        int assignedId = rs.getInt("assigned_user_id");
        if (!rs.wasNull()) {
            a.setAssignedUserId(assignedId);
        }
        a.setAssignedUserName(rs.getString("assigned_user_name"));
        a.setSpecsOrLicense(rs.getString("specs_or_license"));
        a.setCreatedAt(rs.getTimestamp("created_at"));

        a.setTicketCount(rs.getInt("ticket_count"));
        a.setOpenTicketCount(rs.getInt("open_ticket_count"));
        a.setMaintenanceCount(rs.getInt("maintenance_count"));
        return a;
    }
}
