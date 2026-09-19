package com.helpdesk.model;

import java.sql.Timestamp;

public class User {
    private int id;
    private String name;
    private String email;
    private String role; // AGENT_L1, AGENT_L2, ADMIN, EMPLOYEE
    private String department;
    private Timestamp createdAt;

    public User() {}

    public User(int id, String name, String email, String role, String department) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.role = role;
        this.department = department;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public boolean isL1Agent() {
        return "AGENT_L1".equalsIgnoreCase(role);
    }

    public boolean isL2Agent() {
        return "AGENT_L2".equalsIgnoreCase(role);
    }

    public boolean isAgent() {
        return isL1Agent() || isL2Agent() || "ADMIN".equalsIgnoreCase(role);
    }
}
