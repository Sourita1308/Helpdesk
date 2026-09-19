package com.helpdesk.model;

import java.sql.Timestamp;

public class KbArticle {
    private int id;
    private String title;
    private String category; // Hardware, Software, Network, Access & Security, Infrastructure
    private String symptoms;
    private String rootCause;
    private String resolutionSteps;
    private Integer sourceTicketId;
    private String authorName;
    private int viewCount;
    private Timestamp createdAt;

    public KbArticle() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getSymptoms() { return symptoms; }
    public void setSymptoms(String symptoms) { this.symptoms = symptoms; }

    public String getRootCause() { return rootCause; }
    public void setRootCause(String rootCause) { this.rootCause = rootCause; }

    public String getResolutionSteps() { return resolutionSteps; }
    public void setResolutionSteps(String resolutionSteps) { this.resolutionSteps = resolutionSteps; }

    public Integer getSourceTicketId() { return sourceTicketId; }
    public void setSourceTicketId(Integer sourceTicketId) { this.sourceTicketId = sourceTicketId; }

    public String getAuthorName() { return authorName; }
    public void setAuthorName(String authorName) { this.authorName = authorName; }

    public int getViewCount() { return viewCount; }
    public void setViewCount(int viewCount) { this.viewCount = viewCount; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
