-- HelpDesk Lite Database Schema
-- Compatible with MySQL 8.0+ and H2 in MySQL Mode

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    role VARCHAR(50) NOT NULL,
    department VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS assets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    asset_tag VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    category VARCHAR(50) NOT NULL,
    serial_number VARCHAR(100),
    purchase_date DATE,
    warranty_expiry DATE,
    status VARCHAR(50) NOT NULL,
    assigned_user_id INT NULL,
    specs_or_license TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS maintenance_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    asset_id INT NOT NULL,
    service_type VARCHAR(100) NOT NULL,
    technician_name VARCHAR(100) NOT NULL,
    service_date DATE NOT NULL,
    cost DECIMAL(10, 2) DEFAULT 0.00,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tickets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_number VARCHAR(50) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    priority VARCHAR(20) NOT NULL,
    status VARCHAR(50) NOT NULL,
    requester_id INT NOT NULL,
    assignee_id INT NULL,
    support_tier VARCHAR(20) DEFAULT 'First-Line',
    asset_id INT NULL,
    sla_deadline TIMESTAMP NOT NULL,
    sla_breached BOOLEAN DEFAULT FALSE,
    resolution_notes TEXT NULL,
    resolved_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS escalation_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    from_tier VARCHAR(20) NOT NULL,
    to_tier VARCHAR(20) NOT NULL,
    reason VARCHAR(255) NOT NULL,
    escalated_by VARCHAR(100) NOT NULL,
    escalated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS kb_articles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL,
    symptoms TEXT NOT NULL,
    root_cause TEXT NOT NULL,
    resolution_steps TEXT NOT NULL,
    source_ticket_id INT NULL,
    author_name VARCHAR(100) NOT NULL,
    view_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
