package com.helpdesk.dao;

import com.helpdesk.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY name ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapUser(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<User> getAgents(String tier) {
        List<User> list = new ArrayList<>();
        String sql;
        if ("First-Line".equalsIgnoreCase(tier) || "L1".equalsIgnoreCase(tier)) {
            sql = "SELECT * FROM users WHERE role IN ('AGENT_L1', 'ADMIN') ORDER BY name ASC";
        } else if ("Second-Line".equalsIgnoreCase(tier) || "L2".equalsIgnoreCase(tier)) {
            sql = "SELECT * FROM users WHERE role IN ('AGENT_L2', 'ADMIN') ORDER BY name ASC";
        } else {
            sql = "SELECT * FROM users WHERE role IN ('AGENT_L1', 'AGENT_L2', 'ADMIN') ORDER BY name ASC";
        }

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapUser(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public User getUserById(int id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setName(rs.getString("name"));
        u.setEmail(rs.getString("email"));
        u.setRole(rs.getString("role"));
        u.setDepartment(rs.getString("department"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        return u;
    }
}
