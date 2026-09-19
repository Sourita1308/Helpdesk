package com.helpdesk.service;

import com.helpdesk.dao.AssetDAO;
import com.helpdesk.dao.TicketDAO;
import com.helpdesk.dao.UserDAO;
import com.helpdesk.model.Asset;
import com.helpdesk.model.Ticket;
import com.helpdesk.model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

public class EscalationService {
    private static final Logger logger = LoggerFactory.getLogger(EscalationService.class);
    private final TicketDAO ticketDAO = new TicketDAO();
    private final UserDAO userDAO = new UserDAO();
    private final AssetDAO assetDAO = new AssetDAO();

    public int runAutoEscalationRules() {
        ticketDAO.checkAndMarkBreaches();
        List<Ticket> openTickets = ticketDAO.getTickets("open", null, null, null);
        List<User> l2Agents = userDAO.getAgents("Second-Line");
        Integer defaultL2AgentId = (l2Agents != null && !l2Agents.isEmpty()) ? l2Agents.get(0).getId() : null;

        int escalatedCount = 0;
        for (Ticket t : openTickets) {
            // Rule 1: First-line tickets that have breached SLA
            if ("First-Line".equalsIgnoreCase(t.getSupportTier()) && t.isSlaBreached()) {
                String reason = "Automated SLA Breach Rule: Resolution deadline exceeded (" + t.getPriority() + " priority).";
                boolean ok = ticketDAO.escalateTicket(t.getId(), "Second-Line", reason, "SLA Rule Engine (Automated)", defaultL2AgentId);
                if (ok) escalatedCount++;
            }
            // Rule 2: Critical priority open tickets remaining unresolved for > 1 hour
            else if ("First-Line".equalsIgnoreCase(t.getSupportTier()) && "Critical".equalsIgnoreCase(t.getPriority()) && t.getSlaRemainingSeconds() < 3600) {
                String reason = "Critical Priority Rule: Less than 1 hour remaining on Critical SLA. Escalated to prevent breach.";
                boolean ok = ticketDAO.escalateTicket(t.getId(), "Second-Line", reason, "SLA Rule Engine (Automated)", defaultL2AgentId);
                if (ok) escalatedCount++;
            }
            // Rule 3: Ticket linked to an asset that has 3+ repeat failure incidents
            else if ("First-Line".equalsIgnoreCase(t.getSupportTier()) && t.getAssetId() != null) {
                Asset asset = assetDAO.getAssetById(t.getAssetId());
                if (asset != null && asset.getTicketCount() >= 3) {
                    String reason = "Asset Repeat-Issue Rule: Asset " + asset.getAssetTag() + " has " + asset.getTicketCount() + " logged incidents (Hardware/Software instability).";
                    boolean ok = ticketDAO.escalateTicket(t.getId(), "Second-Line", reason, "Asset Health Rule Engine", defaultL2AgentId);
                    if (ok) escalatedCount++;
                }
            }
        }
        return escalatedCount;
    }

    public boolean manualEscalate(int ticketId, String reason, String escalatedBy, Integer targetL2AgentId) {
        if (reason == null || reason.trim().isEmpty()) {
            reason = "Manual escalation by First-Line agent: Requires specialized Second-Line technical investigation.";
        }
        return ticketDAO.escalateTicket(ticketId, "Second-Line", reason, escalatedBy, targetL2AgentId);
    }
}
