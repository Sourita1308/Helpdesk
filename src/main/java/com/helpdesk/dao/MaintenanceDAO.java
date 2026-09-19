package com.helpdesk.dao;

import com.helpdesk.model.MaintenanceLog;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class MaintenanceDAO {

    public List<MaintenanceLog> getLogsByAsset(int assetId) {
        List<MaintenanceLog> list = new ArrayList<>();
        String sql = "SELECT m.*, a.asset_tag, a.name AS asset_name FROM maintenance_logs m " +
                     "JOIN assets a ON m.asset_id = a.id " +
                     "WHERE m.asset_id = ? " +
                     "ORDER BY m.service_date DESC, m.id DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, assetId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapLog(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<MaintenanceLog> getAllRecentLogs(int limit) {
        List<MaintenanceLog> list = new ArrayList<>();
        String sql = "SELECT m.*, a.asset_tag, a.name AS asset_name FROM maintenance_logs m " +
                     "JOIN assets a ON m.asset_id = a.id " +
                     "ORDER BY m.service_date DESC, m.id DESC LIMIT ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapLog(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addLog(MaintenanceLog log) {
        String sql = "INSERT INTO maintenance_logs (asset_id, service_type, technician_name, service_date, cost, notes) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, log.getAssetId());
            ps.setString(2, log.getServiceType());
            ps.setString(3, log.getTechnicianName());
            ps.setDate(4, log.getServiceDate());
            ps.setBigDecimal(5, log.getCost());
            ps.setString(6, log.getNotes());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private MaintenanceLog mapLog(ResultSet rs) throws SQLException {
        MaintenanceLog m = new MaintenanceLog();
        m.setId(rs.getInt("id"));
        m.setAssetId(rs.getInt("asset_id"));
        m.setAssetTag(rs.getString("asset_tag"));
        m.setAssetName(rs.getString("asset_name"));
        m.setServiceType(rs.getString("service_type"));
        m.setTechnicianName(rs.getString("technician_name"));
        m.setServiceDate(rs.getDate("service_date"));
        m.setCost(rs.getBigDecimal("cost"));
        m.setNotes(rs.getString("notes"));
        m.setCreatedAt(rs.getTimestamp("created_at"));
        return m;
    }
}
