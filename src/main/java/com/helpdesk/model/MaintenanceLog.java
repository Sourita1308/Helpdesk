package com.helpdesk.model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

public class MaintenanceLog {
    private int id;
    private int assetId;
    private String assetTag;
    private String assetName;
    private String serviceType; // Installation, OS Reinstall, Battery Replacement, etc.
    private String technicianName;
    private Date serviceDate;
    private BigDecimal cost;
    private String notes;
    private Timestamp createdAt;

    public MaintenanceLog() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getAssetId() { return assetId; }
    public void setAssetId(int assetId) { this.assetId = assetId; }

    public String getAssetTag() { return assetTag; }
    public void setAssetTag(String assetTag) { this.assetTag = assetTag; }

    public String getAssetName() { return assetName; }
    public void setAssetName(String assetName) { this.assetName = assetName; }

    public String getServiceType() { return serviceType; }
    public void setServiceType(String serviceType) { this.serviceType = serviceType; }

    public String getTechnicianName() { return technicianName; }
    public void setTechnicianName(String technicianName) { this.technicianName = technicianName; }

    public Date getServiceDate() { return serviceDate; }
    public void setServiceDate(Date serviceDate) { this.serviceDate = serviceDate; }

    public BigDecimal getCost() { return cost; }
    public void setCost(BigDecimal cost) { this.cost = cost; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
