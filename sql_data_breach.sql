CREATE DATABASE SLA;
USE SLA;

CREATE TABLE customers(
customer_id varchar(10) PRIMARY KEY,
customer_segment varchar(20),
industry VARCHAR(50),
monthly_revenue DECIMAL(10,2),
tenure_months INT,
customer_ltv DECIMAL(12,2)
);

INSERT INTO customers VALUES
('C001', 'SMB', 'Retail', 500, 12, 6000),
('C002', 'SMB', 'Education', 800, 18, 14400),
('C003', 'Mid-Market', 'Logistics', 5000, 24, 120000),
('C004', 'Mid-Market', 'Healthcare', 7000, 36, 252000),
('C005', 'Enterprise', 'FinTech', 30000, 48, 1440000);

CREATE TABLE support_tickets (
    ticket_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10),
    created_at TIMESTAMP,
    resolved_at TIMESTAMP,
    priority VARCHAR(20),
    category VARCHAR(50),
    status VARCHAR(20),
    ticket_text TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO support_tickets VALUES
('T101', 'C001', '2026-01-07 08:30:00', NULL, 'Medium', 'Billing', 'Open',
 'Invoice mismatch for last month'),

('T102', 'C002', '2026-01-07 07:10:00', NULL, 'High', 'Login', 'Open',
 'Users unable to log in before exams'),

('T103', 'C003', '2026-01-06 22:00:00', NULL, 'High', 'API', 'Open',
 'Shipment tracking API failing intermittently'),

('T104', 'C004', '2026-01-07 06:45:00', NULL, 'Critical', 'Data', 'Open',
 'Patient records not syncing'),

('T105', 'C005', '2026-01-06 23:30:00', NULL, 'Critical', 'Payments', 'Open',
 'Payment gateway down, transactions failing');


CREATE TABLE sla_policies (
    priority VARCHAR(20) PRIMARY KEY,
    sla_hours INT,
    penalty_multiplier DECIMAL(3,1)
);


INSERT INTO sla_policies VALUES
('Critical', 4, 2.0),
('High', 8, 1.5),
('Medium', 24, 1.0),
('Low', 48, 0.5);

SELECT * 
FROM customers;

SELECT *
FROM support_tickets;

SELECT *
FROM sla_policies;

SELECT
    t.ticket_id,
    t.customer_id,
    c.customer_segment,
    c.customer_ltv,
    t.priority,
    t.created_at,
    s.sla_hours
FROM support_tickets t
JOIN customers c
    ON t.customer_id = c.customer_id
JOIN sla_policies s
    ON t.priority = s.priority
WHERE t.status = 'Open';

SELECT
    t.ticket_id,
    t.customer_id,
    t.priority,
    c.customer_ltv,
    TIMESTAMPDIFF(MINUTE, t.created_at, '2026-01-07 09:30:00') / 60 AS ticket_age_hours,
    s.sla_hours
FROM support_tickets t
JOIN customers c ON t.customer_id = c.customer_id
JOIN sla_policies s ON t.priority = s.priority
WHERE t.status = 'Open';



SELECT
    ticket_id,
    customer_id,
    priority,
    customer_ltv,
    ticket_age_hours,
    sla_hours,
    (sla_hours - ticket_age_hours) AS sla_remaining_hours
FROM (
    SELECT
        t.ticket_id,
        t.customer_id,
        t.priority,
        c.customer_ltv,
        TIMESTAMPDIFF(MINUTE, t.created_at, '2026-01-07 09:30:00') / 60 AS ticket_age_hours,
        s.sla_hours
    FROM support_tickets t
    JOIN customers c ON t.customer_id = c.customer_id
    JOIN sla_policies s ON t.priority = s.priority
    WHERE t.status = 'Open'
) base;


SELECT
    ticket_id,
    customer_id,
    priority,
    customer_ltv,
    ticket_age_hours,
    sla_remaining_hours,
    CASE
        WHEN sla_remaining_hours < 0 THEN 'BREACHED'
        WHEN sla_remaining_hours BETWEEN 0 AND 2 THEN 'NEAR_BREACH'
        ELSE 'SAFE'
    END AS sla_status,
    ROW_NUMBER() OVER (
        ORDER BY sla_remaining_hours ASC
    ) AS sla_urgency_rank
FROM (
    SELECT
        t.ticket_id,
        t.customer_id,
        t.priority,
        c.customer_ltv,
        TIMESTAMPDIFF(MINUTE, t.created_at, '2026-01-07 09:30:00') / 60 AS ticket_age_hours,
        s.sla_hours -
        TIMESTAMPDIFF(MINUTE, t.created_at, '2026-01-07 09:30:00') / 60 AS sla_remaining_hours
    FROM support_tickets t
    JOIN customers c ON t.customer_id = c.customer_id
    JOIN sla_policies s ON t.priority = s.priority
    WHERE t.status = 'Open'
) final;






