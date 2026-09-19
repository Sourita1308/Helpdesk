package com.helpdesk.model;

import java.sql.Timestamp;
import java.time.Duration;
import java.time.Instant;

public class Ticket {
    private int id;
    private String ticketNumber;
    private String title;
    private String description;
    private String category; // Hardware, Software, Network, Access & Security, Infrastructure
    private String priority; // Low, Medium, High, Critical
    private String status;   // Open, In Progress, Escalated, Resolved, Closed
    private int requesterId;
    private String requesterName;
    private String requesterEmail;
    private Integer assigneeId;
    private String assigneeName;
    private String supportTier; // First-Line, Second-Line
    private Integer assetId;
    private String assetTag;
    private String assetName;
    private Timestamp slaDeadline;
    private boolean slaBreached;
    private String resolutionNotes;
    private Timestamp resolvedAt;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Ticket() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTicketNumber() { return ticketNumber; }
    public void setTicketNumber(String ticketNumber) { this.ticketNumber = ticketNumber; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getRequesterId() { return requesterId; }
    public void setRequesterId(int requesterId) { this.requesterId = requesterId; }

    public String getRequesterName() { return requesterName; }
    public void setRequesterName(String requesterName) { this.requesterName = requesterName; }

    public String getRequesterEmail() { return requesterEmail; }
    public void setRequesterEmail(String requesterEmail) { this.requesterEmail = requesterEmail; }

    public Integer getAssigneeId() { return assigneeId; }
    public void setAssigneeId(Integer assigneeId) { this.assigneeId = assigneeId; }

    public String getAssigneeName() { return assigneeName; }
    public void setAssigneeName(String assigneeName) { this.assigneeName = assigneeName; }

    public String getSupportTier() { return supportTier; }
    public void setSupportTier(String supportTier) { this.supportTier = supportTier; }

    public Integer getAssetId() { return assetId; }
    public void setAssetId(Integer assetId) { this.assetId = assetId; }

    public String getAssetTag() { return assetTag; }
    public void setAssetTag(String assetTag) { this.assetTag = assetTag; }

    public String getAssetName() { return assetName; }
    public void setAssetName(String assetName) { this.assetName = assetName; }

    public Timestamp getSlaDeadline() { return slaDeadline; }
    public void setSlaDeadline(Timestamp slaDeadline) { this.slaDeadline = slaDeadline; }

    public boolean isSlaBreached() { return slaBreached; }
    public void setSlaBreached(boolean slaBreached) { this.slaBreached = slaBreached; }

    public String getResolutionNotes() { return resolutionNotes; }
    public void setResolutionNotes(String resolutionNotes) { this.resolutionNotes = resolutionNotes; }

    public Timestamp getResolvedAt() { return resolvedAt; }
    public void setResolvedAt(Timestamp resolvedAt) { this.resolvedAt = resolvedAt; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    // Business & SLA Helpers
    public boolean isClosedOrResolved() {
        return "Resolved".equalsIgnoreCase(status) || "Closed".equalsIgnoreCase(status);
    }

    public long getSlaRemainingSeconds() {
        if (slaDeadline == null) return 0;
        Instant now = Instant.now();
        Instant deadline = slaDeadline.toInstant();
        return Duration.between(now, deadline).getSeconds();
    }

    public String getSlaRemainingFormatted() {
        if (isClosedOrResolved()) {
            return "Met SLA";
        }
        long sec = getSlaRemainingSeconds();
        if (sec <= 0 || slaBreached) {
            long absSec = Math.abs(sec);
            long hours = absSec / 3600;
            long mins = (absSec % 3600) / 60;
            return "Breached by " + hours + "h " + mins + "m";
        }
        long hours = sec / 3600;
        long mins = (sec % 3600) / 60;
        return hours + "h " + mins + "m left";
    }

    public String getSlaStatusLevel() {
        if (isClosedOrResolved()) return "resolved";
        if (slaBreached || getSlaRemainingSeconds() <= 0) return "breached";
        if (getSlaRemainingSeconds() < 3600) return "urgent";
        if (getSlaRemainingSeconds() < 7200) return "warning";
        return "normal";
    }
}
