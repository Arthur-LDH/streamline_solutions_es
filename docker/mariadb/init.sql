-- init.sql
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Création de la base de données
CREATE DATABASE IF NOT EXISTS streamline;
USE streamline;

-- Table des Utilisateurs Kibana
CREATE TABLE kibana_users (
    id_user INT AUTO_INCREMENT,
    id_client VARCHAR(10) NOT NULL,
    password_hash VARCHAR(256) NOT NULL,
    email VARCHAR(100) NOT NULL,
    lastname VARCHAR(50) NOT NULL,
    firstname VARCHAR(50) NOT NULL,
    role VARCHAR(20) NOT NULL COMMENT 'admin, user, readonly',
    status VARCHAR(20) NOT NULL DEFAULT 'active' COMMENT 'active, inactive, blocked',
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_user),
    FOREIGN KEY (id_client) REFERENCES clients (id_client) ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE KEY unique_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des Clients
CREATE TABLE clients
(
    id_client         VARCHAR(10)  NOT NULL,
    raison_sociale    VARCHAR(100) NOT NULL,
    adresse           VARCHAR(200) NOT NULL,
    ville             VARCHAR(50)  NOT NULL,
    pays              VARCHAR(50)  NOT NULL,
    code_postal       VARCHAR(20)  NOT NULL,
    email             VARCHAR(100) NOT NULL,
    telephone         VARCHAR(20)  NOT NULL,
    type_client       VARCHAR(50)  NOT NULL COMMENT 'B2B, B2C, etc.',
    statut            VARCHAR(20)  NOT NULL DEFAULT 'actif' COMMENT 'actif, inactif, prospect',
    date_creation     TIMESTAMP             DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP             DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_client)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des Produits
CREATE TABLE produits
(
    id_produit            VARCHAR(10)    NOT NULL,
    nom_produit           VARCHAR(100)   NOT NULL,
    categorie             VARCHAR(50)    NOT NULL,
    prix_unitaire         DECIMAL(10, 2) NOT NULL,
    poids_kg              DECIMAL(5, 2)  NOT NULL,
    stock_minimum         INT            NOT NULL,
    stock_actuel          INT            NOT NULL,
    delai_reappro_jours   INT            NOT NULL,
    fournisseur_principal VARCHAR(10)    NOT NULL,
    statut                VARCHAR(20)    NOT NULL DEFAULT 'actif' COMMENT 'actif, inactif, en rupture',
    date_creation         TIMESTAMP               DEFAULT CURRENT_TIMESTAMP,
    date_modification     TIMESTAMP               DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_produit)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des Entrepôts
CREATE TABLE entrepots
(
    id_entrepot           VARCHAR(10)   NOT NULL,
    nom_entrepot          VARCHAR(100)  NOT NULL,
    ville                 VARCHAR(50)   NOT NULL,
    pays                  VARCHAR(50)   NOT NULL,
    capacite_max_palettes INT           NOT NULL,
    taux_remplissage      DECIMAL(5, 2) NOT NULL,
    temperature_moyenne   DECIMAL(4, 1),
    type_stockage         VARCHAR(50)   NOT NULL COMMENT 'frais, sec, congelé',
    niveau_securite       INT           NOT NULL,
    statut                VARCHAR(20)   NOT NULL DEFAULT 'actif' COMMENT 'actif, maintenance, fermé',
    date_creation         TIMESTAMP              DEFAULT CURRENT_TIMESTAMP,
    date_modification     TIMESTAMP              DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_entrepot)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des Expéditions
CREATE TABLE expeditions
(
    id_expedition         VARCHAR(10)    NOT NULL,
    id_client             VARCHAR(10)    NOT NULL,
    date_commande         DATE           NOT NULL,
    date_expedition       DATE,
    date_livraison_prevue DATE           NOT NULL,
    id_entrepot_depart    VARCHAR(10)    NOT NULL,
    id_entrepot_arrivee   VARCHAR(10)    NOT NULL,
    statut_expedition     VARCHAR(20)    NOT NULL DEFAULT 'en préparation' COMMENT 'en préparation, expédiée, livrée',
    mode_transport        VARCHAR(50)    NOT NULL COMMENT 'routier, maritime, aérien',
    cout_transport        DECIMAL(10, 2) NOT NULL,
    priorite              INT            NOT NULL COMMENT '1: urgent, 2: normal, 3: économique',
    date_creation         TIMESTAMP               DEFAULT CURRENT_TIMESTAMP,
    date_modification     TIMESTAMP               DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_expedition),
    FOREIGN KEY (id_client) REFERENCES clients (id_client) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_entrepot_depart) REFERENCES entrepots (id_entrepot) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_entrepot_arrivee) REFERENCES entrepots (id_entrepot) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX                 idx_client (id_client),
    INDEX                 idx_date_expedition (date_expedition),
    INDEX                 idx_statut (statut_expedition)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insertion de données de test pour les clients
INSERT INTO clients (id_client, raison_sociale, adresse, ville, pays, code_postal, email, telephone, type_client)
VALUES ('CLI001', 'Enterprise SA', '123 rue Business', 'Paris', 'France', '75001', 'contact@enterprise.fr',
        '0123456789', 'B2B'),
       ('CLI002', 'Retail Plus', '456 avenue Commerce', 'Lyon', 'France', '69001', 'info@retailplus.fr', '0987654321',
        'B2B'),
       ('CLI003', 'Consumer One', '789 boulevard Client', 'Marseille', 'France', '13001', 'service@consumer.fr',
        '0654789321', 'B2C');

-- Insertion de données de test pour les produits
INSERT INTO produits (id_produit, nom_produit, categorie, prix_unitaire, poids_kg, stock_minimum, stock_actuel,
                      delai_reappro_jours, fournisseur_principal)
VALUES ('PRD001', 'Ordinateur portable', 'Électronique', 799.99, 2.5, 50, 75, 15, 'FRN001'),
       ('PRD002', 'Smartphone', 'Électronique', 499.99, 0.3, 100, 150, 10, 'FRN001'),
       ('PRD003', 'Tablette', 'Électronique', 299.99, 0.5, 75, 100, 12, 'FRN002');

-- Insertion de données de test pour les entrepôts
INSERT INTO entrepots (id_entrepot, nom_entrepot, ville, pays, capacite_max_palettes, taux_remplissage,
                       temperature_moyenne, type_stockage, niveau_securite)
VALUES ('ENT001', 'Entrepôt Paris Nord', 'Paris', 'France', 1000, 75.5, 20.0, 'sec', 2),
       ('ENT002', 'Entrepôt Lyon Sud', 'Lyon', 'France', 800, 60.0, 18.5, 'sec', 2),
       ('ENT003', 'Entrepôt Marseille Port', 'Marseille', 'France', 1200, 80.0, 19.0, 'sec', 3);

-- Insertion de données de test pour les expéditions
INSERT INTO expeditions (id_expedition, id_client, date_commande, date_expedition, date_livraison_prevue,
                         id_entrepot_depart, id_entrepot_arrivee, mode_transport, cout_transport, priorite)
VALUES ('EXP001', 'CLI001', '2024-01-15', '2024-01-16', '2024-01-18', 'ENT001', 'ENT002', 'routier', 250.00, 2),
       ('EXP002', 'CLI002', '2024-01-16', '2024-01-17', '2024-01-19', 'ENT002', 'ENT003', 'routier', 300.00, 1),
       ('EXP003', 'CLI003', '2024-01-17', NULL, '2024-01-20', 'ENT001', 'ENT003', 'routier', 350.00, 3);


INSERT INTO kibana_users (id_client, password_hash, email, lastname, firstname, role, status)
VALUES
-- Users pour Enterprise SA (CLI001)
('CLI001', SHA2('admin123', 256), 'admin@enterprise.fr', 'Dubois', 'Jean', 'admin', 'active'),
('CLI001', SHA2('user123', 256), 'user@enterprise.fr', 'Martin', 'Sophie', 'user', 'active'),
('CLI001', SHA2('read123', 256), 'read@enterprise.fr', 'Petit', 'Marie', 'readonly', 'active'),

-- Users pour Retail Plus (CLI002)
('CLI002', SHA2('admin456', 256), 'admin@retailplus.fr', 'Bernard', 'Pierre', 'admin', 'active'),
('CLI002', SHA2('user456', 256), 'user@retailplus.fr', 'Durand', 'Lucas', 'user', 'active'),

-- User pour Consumer One (CLI003)
('CLI003', SHA2('admin789', 256), 'admin@consumer.fr', 'Robert', 'Alice', 'admin', 'active');