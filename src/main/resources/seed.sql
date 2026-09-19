-- Seed Data for HelpDesk Lite

-- Users (IT Staff & Employees)
INSERT INTO users (id, name, email, role, department) VALUES
(1, 'Alex Rivera', 'alex.rivera@internal.corp', 'AGENT_L1', 'IT Service Desk'),
(2, 'Sarah Jenkins', 'sarah.jenkins@internal.corp', 'AGENT_L1', 'IT Service Desk'),
(3, 'Marcus Vance', 'marcus.vance@internal.corp', 'AGENT_L2', 'IT Escalations & SysOps'),
(4, 'Elena Rostova', 'elena.rostova@internal.corp', 'AGENT_L2', 'Network & Security Eng'),
(5, 'David Kim', 'david.kim@internal.corp', 'EMPLOYEE', 'Engineering'),
(6, 'Jessica Taylor', 'jessica.taylor@internal.corp', 'EMPLOYEE', 'Product Design'),
(7, 'Robert Chen', 'robert.chen@internal.corp', 'EMPLOYEE', 'Finance'),
(8, 'Amara Okafor', 'amara.okafor@internal.corp', 'EMPLOYEE', 'Human Resources');

-- Assets (Hardware & Software)
INSERT INTO assets (id, asset_tag, name, type, category, serial_number, purchase_date, warranty_expiry, status, assigned_user_id, specs_or_license) VALUES
(1, 'HW-LAP-101', 'Dell XPS 15 9520', 'Hardware', 'Laptop', 'SN-DELL-99281A', '2023-04-12', '2026-04-12', 'Allocated', 5, 'Intel i7-12700H, 32GB RAM, 1TB NVMe SSD, RTX 3050Ti'),
(2, 'HW-LAP-102', 'MacBook Pro 16 M2 Max', 'Hardware', 'Laptop', 'SN-APPL-77412M', '2023-06-01', '2026-06-01', 'Allocated', 6, 'Apple M2 Max, 32GB Unified Memory, 1TB SSD'),
(3, 'HW-LAP-103', 'Lenovo ThinkPad X1 Carbon Gen 10', 'Hardware', 'Laptop', 'SN-THNK-48192X', '2023-01-15', '2025-01-15', 'Allocated', 7, 'Intel i5-1240P, 16GB RAM, 512GB SSD'),
(4, 'HW-MON-201', 'Dell UltraSharp 27 4K U2723QE', 'Hardware', 'Monitor', 'SN-DELM-33219P', '2023-05-10', '2026-05-10', 'Allocated', 5, '27-inch 4K IPS Black, USB-C Hub, 90W Power Delivery'),
(5, 'SW-LIC-301', 'Microsoft 365 E5 Enterprise', 'Software', 'License', 'MS365-E5-99201', '2024-01-01', '2025-01-01', 'Allocated', 5, 'Annual Enterprise Subscription w/ Defender & Teams'),
(6, 'SW-LIC-302', 'JetBrains All Products Pack', 'Software', 'License', 'JB-ALL-448210', '2024-02-15', '2025-02-15', 'Allocated', 5, 'Commercial License for IntelliJ IDEA, PyCharm, WebStorm'),
(7, 'HW-LAP-104', 'HP EliteBook 840 G9', 'Hardware', 'Laptop', 'SN-HPEL-55198B', '2022-11-20', '2025-11-20', 'Under Repair', NULL, 'Intel i7-1260P, 16GB RAM, 512GB SSD (Frequent thermal throttling)');

-- Maintenance Logs (Installation & Service history for Repeat-Issue Analysis)
INSERT INTO maintenance_logs (id, asset_id, service_type, technician_name, service_date, cost, notes) VALUES
(1, 1, 'Installation', 'Alex Rivera', '2023-04-13', 0.00, 'Initial imaging with Corporate Win11 Enterprise image, bitlocker activated, enrolled in InTune.'),
(2, 1, 'Driver Fix', 'Sarah Jenkins', '2023-11-10', 0.00, 'User reported audio crackling; updated Realtek sound driver and Waves MaxxAudio.'),
(3, 1, 'Battery Replacement', 'Marcus Vance', '2024-03-18', 120.00, 'Replaced swollen 86Wh battery under warranty. Cleaned heatsink thermal paste.'),
(4, 7, 'OS Reinstall', 'Alex Rivera', '2024-01-20', 0.00, 'Re-flashed OS due to repeated bluescreens (SYSTEM_SERVICE_EXCEPTION).'),
(5, 7, 'Hardware Inspection', 'Marcus Vance', '2024-02-05', 75.00, 'Tested fan assembly; thermal sensors tripping at 98C. Ordered replacement cooling module.');

-- Tickets (Intake, Priorities, SLAs, Tier Assignment, Asset Linkage)
-- SLA Rules: Critical: 2h, High: 4h, Medium: 8h, Low: 24h
INSERT INTO tickets (id, ticket_number, title, description, category, priority, status, requester_id, assignee_id, support_tier, asset_id, sla_deadline, sla_breached, resolution_notes, resolved_at, created_at) VALUES
(1, 'TCK-2026-001', 'Dell XPS 15 thermal throttling & fan screeching during compile', 'During IntelliJ builds, laptop heats up excessively, fans make a loud grinding screech, and system throttles CPU clock down to 0.4 GHz.', 'Hardware', 'High', 'Open', 5, 1, 'First-Line', 1, DATEADD('HOUR', 3, CURRENT_TIMESTAMP), FALSE, NULL, NULL, CURRENT_TIMESTAMP),

(2, 'TCK-2026-002', 'Cannot access AWS Production VPC via Corporate VPN', 'GlobalProtect reports Authentication OK but routes to production subnets (10.200.x.x) fail with timeout. Blocks customer deployment.', 'Network', 'Critical', 'In Progress', 5, 2, 'First-Line', NULL, DATEADD('MINUTE', 45, CURRENT_TIMESTAMP), FALSE, NULL, NULL, CURRENT_TIMESTAMP),

(3, 'TCK-2026-003', 'Figma desktop app crashes on launch with GPU error', 'After latest macOS update, Figma shuts down immediately with "Metal Device Creation Failed". Web version works but is slow.', 'Software', 'Medium', 'Open', 6, 1, 'First-Line', 2, DATEADD('HOUR', 7, CURRENT_TIMESTAMP), FALSE, NULL, NULL, CURRENT_TIMESTAMP),

(4, 'TCK-2026-004', 'Corporate Wi-Fi Certificate Expired on Finance Laptops', 'Robert cannot connect to "Corp-Secure-802.1x". Radius error indicates expired client certificate.', 'Access & Security', 'Critical', 'Escalated', 7, 4, 'Second-Line', 3, DATEADD('HOUR', -1, CURRENT_TIMESTAMP), TRUE, NULL, NULL, DATEADD('HOUR', -3, CURRENT_TIMESTAMP)),

(5, 'TCK-2026-005', 'Outlook search returns zero results for emails older than 1 week', 'Searching inbox or archive returns nothing. Indexing status says 12,000 items remaining.', 'Software', 'Low', 'Resolved', 8, 2, 'First-Line', NULL, DATEADD('HOUR', -5, CURRENT_TIMESTAMP), FALSE, 'Rebuilt Windows Search index via Control Panel -> Indexing Options -> Advanced -> Rebuild. Verified Outlook indexed all items successfully.', CURRENT_TIMESTAMP, DATEADD('DAY', -1, CURRENT_TIMESTAMP)),

(6, 'TCK-2026-006', 'Repeated Blue Screen crashes on HP EliteBook 840', 'Third time this week the laptop bluescreens with DRIVER_IRQL_NOT_LESS_OR_EQUAL. Cannot complete quarterly financial report.', 'Hardware', 'High', 'Escalated', 7, 3, 'Second-Line', 7, DATEADD('HOUR', -2, CURRENT_TIMESTAMP), TRUE, NULL, NULL, DATEADD('HOUR', -6, CURRENT_TIMESTAMP));

-- Escalation Logs (Audit trail of routing to Second-Line)
INSERT INTO escalation_logs (id, ticket_id, from_tier, to_tier, reason, escalated_by, escalated_at) VALUES
(1, 4, 'First-Line', 'Second-Line', 'SLA breached. Radius PKI certificate renewal requires Tier-2 Network Security admin access.', 'Alex Rivera (SLA Auto-Escalation)', CURRENT_TIMESTAMP),
(2, 6, 'First-Line', 'Second-Line', 'Repeat hardware crash issue on asset HW-LAP-104. Motherboard diagnostics needed.', 'Sarah Jenkins', CURRENT_TIMESTAMP);

-- Knowledge Base Articles (Resolved issues repository)
INSERT INTO kb_articles (id, title, category, symptoms, root_cause, resolution_steps, source_ticket_id, author_name, view_count, created_at) VALUES
(1, 'Fixing Outlook 365 Indexing and Blank Search Results', 'Software', 'Searching in Outlook returns 0 results or shows "Search results may be incomplete because items are still being indexed".', 'Windows Search Index corrupted after cumulative OS update.', '1. Close Outlook.\n2. Open Control Panel -> Indexing Options.\n3. Click Advanced -> Rebuild under Troubleshooting.\n4. Wait 15-30 minutes for rebuild.\n5. Re-open Outlook and verify instant search.', 5, 'Sarah Jenkins', 42, CURRENT_TIMESTAMP),

(2, 'GlobalProtect VPN Gateway Timeout & Route Flush', 'Network', 'VPN connects successfully but internal staging and production subnets cannot be pinged or reached in browser.', 'Stale local routing table entries conflicting with virtual adapter gateway.', '1. Open PowerShell as Administrator.\n2. Run: route -f (or restart Palo Alto GlobalProtect Service).\n3. Reconnect to VPN gateway.\n4. Verify route using tracert 10.200.1.1', NULL, 'Elena Rostova', 89, CURRENT_TIMESTAMP),

(3, 'Dell XPS Fan Noise and Severe Thermal Throttling (BD PROCHOT)', 'Hardware', 'System becomes sluggish (clock stuck at 0.79GHz), fan runs at 100% or fails to spin.', 'Dust accumulation in vapor chamber fins or failing fan bearing triggering CPU safety throttling.', '1. Run Dell ePSA Diagnostics (F12 on boot).\n2. Update BIOS to latest revision via Dell Command Update.\n3. If fan grinding noise persists, log RMA for fan and heatsink assembly replacement.', NULL, 'Marcus Vance', 65, CURRENT_TIMESTAMP);
