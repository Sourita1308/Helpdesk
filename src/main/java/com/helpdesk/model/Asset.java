package com.helpdesk.model;

import java.sql.Date;
import java.sql.Timestamp;

public class Asset {
    private int id;
    private String assetTag;
    private String name;
    private String type; // Hardware, Software
    private String category; // Laptop, Desktop, Monitor, License, etc.
    private String serialNumber;
    private Date purchaseDate;
    private Date warrantyExpiry;
    private String status; // Allocated, In Stock, Under Repair, Retired
    private Integer assignedUserId;
    private String assignedUserName;
    private String specsOrLicense;
    private Timestamp createdAt;

    // Derived / Analytics fields
    private int ticketCount;
    private int openTicketCount;
    private int maintenanceCount;

    public Asset() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getAssetTag() { return assetTag; }
    public void setAssetTag(String assetTag) { this.assetTag = assetTag; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getSerialNumber() { return serialNumber; }
    public void setSerialNumber(String serialNumber) { this.serialNumber = serialNumber; }

    public Date getPurchaseDate() { return purchaseDate; }
    public void setPurchaseDate(Date purchaseDate) { this.purchaseDate = purchaseDate; }

    public Date getWarrantyExpiry() { return warrantyExpiry; }
    public void setWarrantyExpiry(Date warrantyExpiry) { this.warrantyExpiry = warrantyExpiry; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Integer getAssignedUserId() { return assignedUserId; }
    public void setAssignedUserId(Integer assignedUserId) { this.assignedUserId = assignedUserId; }

    public String getAssignedUserName() { return assignedUserName; }
    public void setAssignedUserName(String assignedUserName) { this.assignedUserName = assignedUserName; }

    public String getSpecsOrLicense() { return specsOrLicense; }
    public void setSpecsOrLicense(String specsOrLicense) { this.specsOrLicense = specsOrLicense; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public int getTicketCount() { return ticketCount; }
    public void setTicketCount(int ticketCount) { this.ticketCount = ticketCount; }

    public int getOpenTicketCount() { return openTicketCount; }
    public void setOpenTicketCount(int openTicketCount) { this.openTicketCount = openTicketCount; }

    public int getMaintenanceCount() { return maintenanceCount; }
    public void setMaintenanceCount(int maintenanceCount) { this.maintenanceCount = maintenanceCount; }

    public boolean isRepeatIssueRisk() {
        return ticketCount >= 2;
    }
}
