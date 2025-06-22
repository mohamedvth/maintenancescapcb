-- SCAPCB Database Schema
-- Version 1.0
-- Created: 2025-06-22

CREATE DATABASE IF NOT EXISTS scapcb_db;
USE scapcb_db;

-- Users Table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    matricule VARCHAR(20) NOT NULL UNIQUE,
    role ENUM('admin', 'technician', 'supervisor') NOT NULL DEFAULT 'technician',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Equipment Types Table
CREATE TABLE equipment_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- Equipment Table
CREATE TABLE equipment (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type_id INT NOT NULL,
    serial_number VARCHAR(50) UNIQUE,
    installation_date DATE,
    last_maintenance_date DATE,
    status ENUM('active', 'inactive', 'under_maintenance') DEFAULT 'active',
    FOREIGN KEY (type_id) REFERENCES equipment_types(id)
);

-- Intervention Types Table
CREATE TABLE intervention_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- Maintenance Types Table
CREATE TABLE maintenance_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- Interventions Table
CREATE TABLE interventions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    user_id INT NOT NULL,
    intervention_type_id INT NOT NULL,
    maintenance_type_id INT NOT NULL,
    start_datetime DATETIME NOT NULL,
    end_datetime DATETIME NOT NULL,
    status ENUM('planned', 'in_progress', 'completed', 'cancelled') DEFAULT 'planned',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (intervention_type_id) REFERENCES intervention_types(id),
    FOREIGN KEY (maintenance_type_id) REFERENCES maintenance_types(id)
);

-- Intervention Equipment Table (Many-to-Many Relationship)
CREATE TABLE intervention_equipment (
    intervention_id INT NOT NULL,
    equipment_id INT NOT NULL,
    PRIMARY KEY (intervention_id, equipment_id),
    FOREIGN KEY (intervention_id) REFERENCES interventions(id),
    FOREIGN KEY (equipment_id) REFERENCES equipment(id)
);

-- Statistics Table
CREATE TABLE statistics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    total_interventions INT DEFAULT 0,
    in_progress INT DEFAULT 0,
    completed INT DEFAULT 0,
    cancelled INT DEFAULT 0,
    total_equipment INT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert Sample Data
INSERT INTO users (username, password, full_name, matricule, role) VALUES
('admin5513090807', SHA2('5513090807**Aa', 256), 'Admin User', 'ADM001', 'admin'),
('tech_jdoe', SHA2('P@ssw0rd123', 256), 'John Doe', 'TECH001', 'technician'),
('superv_mjane', SHA2('Secure!789', 256), 'Mary Jane', 'SUPV001', 'supervisor');

INSERT INTO equipment_types (name, description) VALUES
('Electrical', 'Electrical systems and components'),
('Mechanical', 'Mechanical machinery and parts'),
('General', 'General facility equipment');

INSERT INTO equipment (name, type_id, serial_number, installation_date, last_maintenance_date, status) VALUES
('Main Transformer', 1, 'TRF-2023-001', '2023-01-15', '2025-05-20', 'active'),
('Conveyor Belt System', 2, 'CVB-2022-045', '2022-03-10', '2025-06-10', 'active'),
('Cooling Tower', 3, 'CT-2024-012', '2024-02-28', NULL, 'active'),
('Control Panel A', 1, 'CPA-2023-078', '2023-07-22', '2025-04-15', 'under_maintenance');

INSERT INTO intervention_types (name, description) VALUES
('Electrical Maintenance', 'Maintenance of electrical systems'),
('Mechanical Maintenance', 'Maintenance of mechanical systems'),
('General Service', 'General facility maintenance');

INSERT INTO maintenance_types (name, description) VALUES
('Preventive', 'Scheduled maintenance to prevent failures'),
('Corrective', 'Repair of existing problems'),
('Cancelled', 'Intervention that was cancelled');

INSERT INTO interventions (title, description, user_id, intervention_type_id, maintenance_type_id, start_datetime, end_datetime, status) VALUES
('Transformer Checkup', 'Routine inspection of main transformer', 2, 1, 1, '2025-06-25 09:00:00', '2025-06-25 11:30:00', 'planned'),
('Conveyor Belt Repair', 'Repair of damaged conveyor belt section', 2, 2, 2, '2025-06-20 14:00:00', '2025-06-20 16:45:00', 'completed'),
('Cooling System Maintenance', 'Scheduled maintenance of cooling tower', 3, 3, 1, '2025-07-01 10:00:00', '2025-07-01 15:00:00', 'planned');

INSERT INTO intervention_equipment (intervention_id, equipment_id) VALUES
(1, 1),
(2, 2),
(3, 3);

INSERT INTO statistics (total_interventions, in_progress, completed, cancelled, total_equipment) VALUES
(3, 2, 1, 0, 4);

-- Create Views for Reporting
CREATE VIEW intervention_details AS
SELECT 
    i.id,
    i.title,
    i.description,
    i.start_datetime,
    i.end_datetime,
    i.status AS intervention_status,
    u.full_name AS technician,
    u.matricule,
    it.name AS intervention_type,
    mt.name AS maintenance_type,
    GROUP_CONCAT(e.name SEPARATOR ', ') AS equipment_list
FROM interventions i
JOIN users u ON i.user_id = u.id
JOIN intervention_types it ON i.intervention_type_id = it.id
JOIN maintenance_types mt ON i.maintenance_type_id = mt.id
JOIN intervention_equipment ie ON i.id = ie.intervention_id
JOIN equipment e ON ie.equipment_id = e.id
GROUP BY i.id;

-- Create Stored Procedures
DELIMITER //

-- Procedure to add new intervention
CREATE PROCEDURE AddIntervention(
    IN p_title VARCHAR(100),
    IN p_description TEXT,
    IN p_user_id INT,
    IN p_intervention_type_id INT,
    IN p_maintenance_type_id INT,
    IN p_start_datetime DATETIME,
    IN p_end_datetime DATETIME,
    IN p_equipment_ids TEXT
)
BEGIN
    DECLARE new_intervention_id INT;
    
    -- Insert new intervention
    INSERT INTO interventions (title, description, user_id, intervention_type_id, maintenance_type_id, start_datetime, end_datetime)
    VALUES (p_title, p_description, p_user_id, p_intervention_type_id, p_maintenance_type_id, p_start_datetime, p_end_datetime);
    
    SET new_intervention_id = LAST_INSERT_ID();
    
    -- Add equipment relationships
    SET @sql = CONCAT(
        'INSERT INTO intervention_equipment (intervention_id, equipment_id) ',
        'SELECT ', new_intervention_id, ', id FROM equipment ',
        'WHERE id IN (', p_equipment_ids, ')'
    );
    
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Update statistics
    UPDATE statistics 
    SET total_interventions = total_interventions + 1,
        in_progress = in_progress + 1,
        last_updated = CURRENT_TIMESTAMP;
END //

-- Procedure to complete an intervention
CREATE PROCEDURE CompleteIntervention(IN p_intervention_id INT)
BEGIN
    UPDATE interventions
    SET status = 'completed'
    WHERE id = p_intervention_id;
    
    UPDATE statistics 
    SET in_progress = in_progress - 1,
        completed = completed + 1,
        last_updated = CURRENT_TIMESTAMP;
END //

-- Procedure to cancel an intervention
CREATE PROCEDURE CancelIntervention(IN p_intervention_id INT)
BEGIN
    UPDATE interventions
    SET status = 'cancelled'
    WHERE id = p_intervention_id;
    
    UPDATE statistics 
    SET in_progress = in_progress - 1,
        cancelled = cancelled + 1,
        last_updated = CURRENT_TIMESTAMP;
END //

DELIMITER ;

-- Create Triggers for Data Integrity
-- Trigger to update statistics when equipment status changes
DELIMITER //
CREATE TRIGGER after_equipment_status_update
AFTER UPDATE ON equipment
FOR EACH ROW
BEGIN
    IF NEW.status = 'under_maintenance' AND OLD.status != 'under_maintenance' THEN
        UPDATE statistics 
        SET total_equipment = total_equipment - 1,
            last_updated = CURRENT_TIMESTAMP;
    ELSEIF NEW.status != 'under_maintenance' AND OLD.status = 'under_maintenance' THEN
        UPDATE statistics 
        SET total_equipment = total_equipment + 1,
            last_updated = CURRENT_TIMESTAMP;
    END IF;
END //
DELIMITER ;

-- Trigger to update statistics when new equipment is added
DELIMITER //
CREATE TRIGGER after_equipment_insert
AFTER INSERT ON equipment
FOR EACH ROW
BEGIN
    UPDATE statistics 
    SET total_equipment = total_equipment + 1,
        last_updated = CURRENT_TIMESTAMP;
END //
DELIMITER ;

-- Create Indexes for Performance
CREATE INDEX idx_interventions_user ON interventions(user_id);
CREATE INDEX idx_interventions_type ON interventions(intervention_type_id);
CREATE INDEX idx_interventions_status ON interventions(status);
CREATE INDEX idx_equipment_type ON equipment(type_id);
CREATE INDEX idx_equipment_status ON equipment(status);