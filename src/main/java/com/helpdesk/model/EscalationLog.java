package com.helpdesk.model;

import java.sql.Timestamp;

public class EscalationLog {
    private int id;
    private int ticketId;
    private String ticketNumber;
    private String ticketTitle;
    private String fromTier;
    private String toTier;
    private String reason;
    private String escalatedBy;
    private Timestamp escalatedAt;

    public EscalationLog() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getTicketId() { return ticketId; }
    public void setTicketId(int ticketId) { this.ticketId = ticketId; }

    public String getTicketNumber() { return ticketNumber; }
    public void setTicketNumber(String ticketNumber) { this.ticketNumber = ticketNumber; }

    public String getTicketTitle() { return ticketTitle; }
    public void setTicketTitle(String ticketTitle) { this.ticketTitle = ticketTitle; }

    public String getFromTier() { return fromTier; }
    public void setFromTier(String fromTier) { this.fromTier = fromTier; }

    public String getToTier() { return toTier; }
    public void setToTier(String toTier) { this.toTier = toTier; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getEscalatedBy() { return escalatedBy; }
    public void setEscalatedBy(String escalatedBy) { this.escalatedBy = escalatedBy; }

    public Timestamp getEscalatedAt() { return escalatedAt; }
    public void setEscalatedAt(Timestamp escalatedAt) { this.escalatedAt = escalatedAt; }
}
