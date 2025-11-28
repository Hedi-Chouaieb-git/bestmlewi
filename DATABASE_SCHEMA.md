# Database Schema Documentation

This document describes all the database tables required for the application, along with their structure and sample data.

## Tables Overview

1. **Collaborateurs** - Stores all collaborators (employees) including livreurs, coordinateurs, cuisiniers, etc.
2. **Client** - Stores client/customer information
3. **Commande** - Stores orders/commands placed by clients
4. **Produit** or **products** - Stores product/menu items
5. **PointDeVente** or **sales_points** - Stores sales points/locations
6. **EquipeCuisine** or **kitchen_team** - Stores kitchen team members
7. **alerts** - Stores system alerts for the dashboard
8. **orders** - Alternative orders table (may be used by Gerant dashboard)

---

## Table: Collaborateurs

**Purpose**: Stores all collaborators (employees) with their roles and availability.

### Schema

```sql
CREATE TABLE "Collaborateurs" (
  "idCollab" TEXT PRIMARY KEY,
  "nom" TEXT NOT NULL,
  "prenom" TEXT NOT NULL,
  "email" TEXT UNIQUE NOT NULL,
  "password" TEXT NOT NULL,  -- Note: Should be hashed in production
  "role" TEXT NOT NULL,  -- Values: 'livreur', 'coordinateur', 'cuisinier', 'chef', 'gerant'
  "idPointAffecte" TEXT REFERENCES "PointDeVente"("idPoint"),  -- Currently assigned point
  "disponible" BOOLEAN DEFAULT true,
  "telephone" TEXT,
  "created_at" TIMESTAMP DEFAULT NOW(),
  "updated_at" TIMESTAMP DEFAULT NOW()
);
```

### Sample Data

```sql
INSERT INTO "Collaborateurs" ("idCollab", "nom", "prenom", "email", "password", "role", "disponible", "telephone") VALUES
('COLL001', 'Dupont', 'Jean', 'jean.dupont@example.com', 'password123', 'coordinateur', true, '+21612345678'),
('COLL002', 'Martin', 'Sophie', 'sophie.martin@example.com', 'password123', 'livreur', true, '+21612345679'),
('COLL003', 'Bernard', 'Pierre', 'pierre.bernard@example.com', 'password123', 'livreur', true, '+21612345680'),
('COLL004', 'Dubois', 'Marie', 'marie.dubois@example.com', 'password123', 'cuisinier', true, '+21612345681'),
('COLL005', 'Laurent', 'Paul', 'paul.laurent@example.com', 'password123', 'chef', true, '+21612345682'),
('COLL006', 'Moreau', 'Julie', 'julie.moreau@example.com', 'password123', 'livreur', false, '+21612345683');
```

---

## Table: Client

**Purpose**: Stores client/customer information.

### Schema

```sql
CREATE TABLE "Client" (
  "idClient" TEXT PRIMARY KEY,
  "nom" TEXT NOT NULL,
  "prenom" TEXT,
  "email" TEXT UNIQUE,
  "phone" TEXT UNIQUE NOT NULL,
  "password" TEXT NOT NULL,  -- Note: Should be hashed in production
  "adresse" TEXT,
  "ville" TEXT,
  "codePostal" TEXT,
  "favorite" BOOLEAN DEFAULT false,
  "created_at" TIMESTAMP DEFAULT NOW(),
  "updated_at" TIMESTAMP DEFAULT NOW()
);
```

### Sample Data

```sql
INSERT INTO "Client" ("idClient", "nom", "prenom", "email", "phone", "password", "adresse", "ville", "codePostal", "favorite") VALUES
('CLI001', 'Ben Ali', 'Ahmed', 'ahmed.benali@example.com', '+21698765432', 'client123', '123 Rue Habib Bourguiba', 'Tunis', '1000', true),
('CLI002', 'Trabelsi', 'Fatma', 'fatma.trabelsi@example.com', '+21698765433', 'client123', '45 Avenue de la République', 'Sfax', '3000', false),
('CLI003', 'Jemai', 'Mohamed', 'mohamed.jemai@example.com', '+21698765434', 'client123', '78 Rue de la Liberté', 'Sousse', '4000', true);
```

---

## Table: Commande

**Purpose**: Stores orders/commands placed by clients.

### Schema

```sql
CREATE TABLE "Commande" (
  "idCommande" TEXT PRIMARY KEY,
  "idClient" TEXT NOT NULL REFERENCES "Client"("idClient"),
  "idPointVente" TEXT REFERENCES "PointDeVente"("idPoint"),  -- Assigned TopMlawi point
  "idCollab" TEXT REFERENCES "Collaborateurs"("idCollab"),  -- Assigned livreur
  "idCuisinier" TEXT REFERENCES "Collaborateurs"("idCollab"),  -- Assigned cook
  "statut" TEXT NOT NULL DEFAULT 'en_attente',  -- Values: 'en_attente', 'en_preparation', 'en_cours', 'livree', 'annulee'
  "dateCommande" TIMESTAMP DEFAULT NOW(),
  "dateLivraison" TIMESTAMP,
  "montantTotal" DECIMAL(10, 2) NOT NULL,
  "adresseLivraison" TEXT NOT NULL,
  "notes" TEXT,
  "latitude" DECIMAL(10, 8),  -- Client location latitude
  "longitude" DECIMAL(11, 8),  -- Client location longitude
  "tempsPreparationDebut" TIMESTAMP,  -- Preparation start time
  "tempsPreparationFin" TIMESTAMP,  -- Preparation end time
  "tempsRemiseLivreur" TIMESTAMP,  -- Handover to delivery time
  "tempsRecuperationLivreur" TIMESTAMP,  -- Pickup by delivery time
  "tempsLivraison" TIMESTAMP,  -- Delivery completion time
  "created_at" TIMESTAMP DEFAULT NOW(),
  "updated_at" TIMESTAMP DEFAULT NOW()
);
```

### Sample Data

```sql
INSERT INTO "Commande" ("idCommande", "idClient", "idCollab", "statut", "dateCommande", "montantTotal", "adresseLivraison", "notes") VALUES
('CMD001', 'CLI001', 'COLL002', 'en_cours', NOW(), 45.50, '123 Rue Habib Bourguiba, Tunis', 'Livrer rapidement'),
('CMD002', 'CLI002', NULL, 'en_attente', NOW(), 32.00, '45 Avenue de la République, Sfax', NULL),
('CMD003', 'CLI003', 'COLL003', 'en_preparation', NOW(), 67.75, '78 Rue de la Liberté, Sousse', 'Sans oignons'),
('CMD004', 'CLI001', NULL, 'en_attente', NOW(), 28.50, '123 Rue Habib Bourguiba, Tunis', NULL),
('CMD005', 'CLI002', 'COLL002', 'livree', NOW() - INTERVAL '1 day', 55.00, '45 Avenue de la République, Sfax', NULL);
```

---

## Table: Produit (or products)

**Purpose**: Stores product/menu items.

### Schema

```sql
CREATE TABLE "Produit" (
  -- OR use "products" if that's what your code expects
  "idProduit" TEXT PRIMARY KEY,  -- OR "id" if using "products"
  "nom" TEXT NOT NULL,  -- OR "name"
  "description" TEXT,
  "prix" DECIMAL(10, 2) NOT NULL,  -- OR "price"
  "categorie" TEXT,  -- OR "category"
  "image" TEXT,  -- URL or path to image
  "disponible" BOOLEAN DEFAULT true,
  "created_at" TIMESTAMP DEFAULT NOW(),
  "updated_at" TIMESTAMP DEFAULT NOW()
);
```

**Alternative schema if using "products" table:**

```sql
CREATE TABLE "products" (
  "id" TEXT PRIMARY KEY,
  "name" TEXT NOT NULL,
  "description" TEXT,
  "price" DECIMAL(10, 2) NOT NULL,
  "category" TEXT,
  "image" TEXT,
  "available" BOOLEAN DEFAULT true,
  "created_at" TIMESTAMP DEFAULT NOW(),
  "updated_at" TIMESTAMP DEFAULT NOW()
);
```

### Sample Data

```sql
-- For "Produit" table
INSERT INTO "Produit" ("idProduit", "nom", "description", "prix", "categorie", "image", "disponible") VALUES
('PROD001', 'Shawarma Poulet', 'Délicieux shawarma au poulet avec légumes frais', 12.50, 'Plat Principal', 'assets/images/shwarma.jpeg', true),
('PROD002', 'Jus d''Orange', 'Jus d''orange frais pressé', 5.00, 'Boisson', 'assets/images/jus.jpeg', true),
('PROD003', 'Mlawi Traditionnel', 'Mlawi avec viande hachée et œuf', 8.50, 'Plat Principal', 'assets/images/mlawi.jpeg', true),
('PROD004', 'Shawarma Agneau', 'Shawarma à l''agneau avec sauce spéciale', 15.00, 'Plat Principal', 'assets/images/shwarma.jpeg', true);

-- For "products" table (if using English naming)
INSERT INTO "products" ("id", "name", "description", "price", "category", "image", "available") VALUES
('PROD001', 'Chicken Shawarma', 'Delicious chicken shawarma with fresh vegetables', 12.50, 'Main Course', 'assets/images/shwarma.jpeg', true),
('PROD002', 'Orange Juice', 'Freshly squeezed orange juice', 5.00, 'Drink', 'assets/images/jus.jpeg', true),
('PROD003', 'Traditional Mlawi', 'Mlawi with minced meat and egg', 8.50, 'Main Course', 'assets/images/mlawi.jpeg', true);
```

---

## Table: PointDeVente (or sales_points)

**Purpose**: Stores sales points/locations.

### Schema

```sql
CREATE TABLE "PointDeVente" (
  "idPoint" TEXT PRIMARY KEY,
  "nom" TEXT NOT NULL,
  "adresse" TEXT NOT NULL,
  "ville" TEXT,
  "telephone" TEXT,
  "ouvert" BOOLEAN DEFAULT true,
  "heureOuverture" TIME,
  "heureFermeture" TIME,
  "created_at" TIMESTAMP DEFAULT NOW()
);
```

**Alternative schema if using "sales_points" table:**

```sql
CREATE TABLE "sales_points" (
  "id" TEXT PRIMARY KEY,
  "title" TEXT NOT NULL,  -- OR "name"
  "status" TEXT DEFAULT 'OPEN',  -- OR "is_open" BOOLEAN
  "address" TEXT,
  "collaborators" TEXT,  -- JSON or comma-separated IDs
  "created_at" TIMESTAMP DEFAULT NOW()
);
```

### Sample Data

```sql
-- For "PointDeVente" table
INSERT INTO "PointDeVente" ("idPoint", "nom", "adresse", "ville", "telephone", "ouvert", "heureOuverture", "heureFermeture") VALUES
('PV001', 'Point de Vente Centre-Ville', '100 Avenue Habib Bourguiba', 'Tunis', '+21671234567', true, '09:00', '22:00'),
('PV002', 'Point de Vente Sfax', '200 Rue de la République', 'Sfax', '+21674234567', true, '10:00', '23:00'),
('PV003', 'Point de Vente Sousse', '150 Avenue de la Liberté', 'Sousse', '+21673234567', false, '09:00', '22:00');

-- For "sales_points" table
INSERT INTO "sales_points" ("id", "title", "status", "address", "collaborators") VALUES
('PV001', 'Downtown Sales Point', 'OPEN', '100 Avenue Habib Bourguiba, Tunis', 'COLL001,COLL002'),
('PV002', 'Sfax Sales Point', 'OPEN', '200 Rue de la République, Sfax', 'COLL003,COLL004');
```

---

## Table: EquipeCuisine (or kitchen_team)

**Purpose**: Stores kitchen team members.

### Schema

```sql
CREATE TABLE "EquipeCuisine" (
  "idMembre" TEXT PRIMARY KEY,
  "idCollab" TEXT NOT NULL REFERENCES "Collaborateurs"("idCollab"),
  "specialite" TEXT,
  "experience" INTEGER,  -- Years of experience
  "disponible" BOOLEAN DEFAULT true,
  "created_at" TIMESTAMP DEFAULT NOW()
);
```

### Sample Data

```sql
INSERT INTO "EquipeCuisine" ("idMembre", "idCollab", "specialite", "experience", "disponible") VALUES
('EC001', 'COLL004', 'Cuisine Tunisienne', 5, true),
('EC002', 'COLL005', 'Cuisine Internationale', 10, true);
```

---

## Table: alerts

**Purpose**: Stores system alerts for the dashboard.

### Schema

```sql
CREATE TABLE "alerts" (
  "id" SERIAL PRIMARY KEY,
  "message" TEXT NOT NULL,
  "severity" TEXT NOT NULL DEFAULT 'info',  -- Values: 'info', 'warning', 'error'
  "created_at" TIMESTAMP DEFAULT NOW(),
  "resolved" BOOLEAN DEFAULT false
);
```

### Sample Data

```sql
INSERT INTO "alerts" ("message", "severity", "created_at", "resolved") VALUES
('Nouvelle commande reçue', 'info', NOW(), false),
('Livreur indisponible', 'warning', NOW() - INTERVAL '1 hour', false),
('Point de vente fermé', 'warning', NOW() - INTERVAL '2 hours', true);
```

---

## Table: orders (Alternative)

**Purpose**: Alternative orders table used by Gerant dashboard (if different from Commande).

### Schema

```sql
CREATE TABLE "orders" (
  "id" TEXT PRIMARY KEY,
  "status" TEXT NOT NULL DEFAULT 'pending',  -- Values: 'pending', 'preparing', 'in_transit', 'delivered', 'cancelled'
  "total_amount" DECIMAL(10, 2) NOT NULL,
  "created_at" TIMESTAMP DEFAULT NOW(),
  "updated_at" TIMESTAMP DEFAULT NOW()
);
```

### Sample Data

```sql
INSERT INTO "orders" ("id", "status", "total_amount", "created_at") VALUES
('ORD001', 'delivered', 45.50, NOW() - INTERVAL '2 hours'),
('ORD002', 'in_transit', 32.00, NOW() - INTERVAL '1 hour'),
('ORD003', 'preparing', 67.75, NOW() - INTERVAL '30 minutes'),
('ORD004', 'pending', 28.50, NOW());
```

---

## Junction Table: sales_point_collaborators (Optional)

**Purpose**: Many-to-many relationship between sales points and collaborators.

### Schema

```sql
CREATE TABLE "sales_point_collaborators" (
  "id" SERIAL PRIMARY KEY,
  "sales_point_id" TEXT NOT NULL,
  "collaborator_id" TEXT NOT NULL REFERENCES "Collaborateurs"("idCollab"),
  "created_at" TIMESTAMP DEFAULT NOW(),
  UNIQUE("sales_point_id", "collaborator_id")
);
```

---

## Table: roles (Optional)

**Purpose**: Stores available roles (if you want to manage them dynamically).

### Schema

```sql
CREATE TABLE "roles" (
  "id" SERIAL PRIMARY KEY,
  "name" TEXT UNIQUE NOT NULL,
  "description" TEXT,
  "permissions" JSONB,
  "created_at" TIMESTAMP DEFAULT NOW()
);
```

### Sample Data

```sql
INSERT INTO "roles" ("name", "description") VALUES
('livreur', 'Responsable de la livraison des commandes'),
('coordinateur', 'Coordonne les commandes et les livraisons'),
('cuisinier', 'Prépare les plats en cuisine'),
('chef', 'Chef de cuisine, supervise la préparation'),
('gerant', 'Gérant du restaurant, accès complet');
```

---

## Table: Notifications

**Purpose**: Stores notifications for delivery persons and coordinators.

### Schema

```sql
CREATE TABLE "Notifications" (
  "idNotification" TEXT PRIMARY KEY,
  "idDestinataire" TEXT NOT NULL REFERENCES "Collaborateurs"("idCollab"),  -- Recipient
  "idCommande" TEXT REFERENCES "Commande"("idCommande"),  -- Related order
  "type" TEXT NOT NULL,  -- Values: 'nouvelle_commande', 'commande_assignee', 'statut_modifie', 'urgence'
  "titre" TEXT NOT NULL,
  "message" TEXT NOT NULL,
  "lue" BOOLEAN DEFAULT false,
  "created_at" TIMESTAMP DEFAULT NOW()
);
```

### Sample Data

```sql
INSERT INTO "Notifications" ("idNotification", "idDestinataire", "idCommande", "type", "titre", "message", "lue") VALUES
('NOT001', 'COLL002', 'CMD001', 'nouvelle_commande', 'Nouvelle livraison', 'Vous avez une nouvelle commande à livrer', false),
('NOT002', 'COLL001', 'CMD002', 'commande_assignee', 'Commande assignée', 'Nouvelle commande à coordonner', false);
```

---

## Table: Locations

**Purpose**: Stores real-time location updates from delivery persons.

### Schema

```sql
CREATE TABLE "Locations" (
  "idLocation" TEXT PRIMARY KEY,
  "idCollab" TEXT NOT NULL REFERENCES "Collaborateurs"("idCollab"),  -- Delivery person
  "latitude" DECIMAL(10, 8) NOT NULL,
  "longitude" DECIMAL(11, 8) NOT NULL,
  "timestamp" TIMESTAMP DEFAULT NOW(),
  "vitesse" DECIMAL(5, 2),  -- Speed in km/h (optional)
  "precision" DECIMAL(5, 2)  -- Location accuracy in meters (optional)
);
```

### Sample Data

```sql
INSERT INTO "Locations" ("idLocation", "idCollab", "latitude", "longitude", "timestamp", "vitesse", "precision") VALUES
('LOC001', 'COLL002', 36.8065, 10.1815, NOW(), 25.5, 5.2),
('LOC002', 'COLL003', 36.8188, 10.1658, NOW() - INTERVAL '5 minutes', 0.0, 3.1);
```

---

## Table: RefundRequests

**Purpose**: Stores refund requests from clients.

### Schema

```sql
CREATE TABLE "RefundRequests" (
  "idRefund" TEXT PRIMARY KEY,
  "idCommande" TEXT NOT NULL REFERENCES "Commande"("idCommande"),
  "idClient" TEXT NOT NULL REFERENCES "Client"("idClient"),
  "motif" TEXT NOT NULL,  -- Reason for refund
  "statut" TEXT NOT NULL DEFAULT 'en_attente',  -- Values: 'en_attente', 'approuvee', 'refusee'
  "montantRembourse" DECIMAL(10, 2),
  "traiteePar" TEXT REFERENCES "Collaborateurs"("idCollab"),  -- Manager who processed it
  "dateTraitement" TIMESTAMP,
  "notes" TEXT,
  "created_at" TIMESTAMP DEFAULT NOW(),
  "updated_at" TIMESTAMP DEFAULT NOW()
);
```

### Sample Data

```sql
INSERT INTO "RefundRequests" ("idRefund", "idCommande", "idClient", "motif", "statut", "montantRembourse", "traiteePar") VALUES
('REF001', 'CMD001', 'CLI001', 'Livraison en retard pour plat chaud', 'en_attente', NULL, NULL);
```

---

## Important Notes

1. **Password Security**: The `password` fields in both `Client` and `Collaborateurs` tables should be hashed using a secure hashing algorithm (e.g., bcrypt) in production. Never store plain text passwords.

2. **Table Naming**: The application uses both French (`Collaborateurs`, `Commande`, `Client`) and English (`products`, `sales_points`, `orders`) table names. Make sure to use the correct table names based on what your code expects.

3. **Foreign Keys**: Ensure foreign key relationships are properly set up:
   - `Commande.idClient` → `Client.idClient`
   - `Commande.idCollab` → `Collaborateurs.idCollab`
   - `EquipeCuisine.idCollab` → `Collaborateurs.idCollab`

4. **Indexes**: Consider adding indexes on frequently queried columns:
   - `Collaborateurs.role`
   - `Collaborateurs.email`
   - `Commande.statut`
   - `Commande.dateCommande`
   - `Client.phone`

5. **Timestamps**: All tables should have `created_at` and `updated_at` timestamps for audit purposes.

---

## Quick Setup Script

Here's a quick SQL script to create all tables (adjust table names based on your preference):

```sql
-- Create Collaborateurs table
CREATE TABLE IF NOT EXISTS "Collaborateurs" (
  "idCollab" TEXT PRIMARY KEY,
  "nom" TEXT NOT NULL,
  "prenom" TEXT NOT NULL,
  "email" TEXT UNIQUE NOT NULL,
  "password" TEXT NOT NULL,
  "role" TEXT NOT NULL,
  "disponible" BOOLEAN DEFAULT true,
  "telephone" TEXT,
  "created_at" TIMESTAMP DEFAULT NOW(),
  "updated_at" TIMESTAMP DEFAULT NOW()
);

-- Create Client table
CREATE TABLE IF NOT EXISTS "Client" (
  "idClient" TEXT PRIMARY KEY,
  "nom" TEXT NOT NULL,
  "prenom" TEXT,
  "email" TEXT UNIQUE,
  "phone" TEXT UNIQUE NOT NULL,
  "password" TEXT NOT NULL,
  "adresse" TEXT,
  "ville" TEXT,
  "codePostal" TEXT,
  "favorite" BOOLEAN DEFAULT false,
  "created_at" TIMESTAMP DEFAULT NOW(),
  "updated_at" TIMESTAMP DEFAULT NOW()
);

-- Create Commande table
CREATE TABLE IF NOT EXISTS "Commande" (
  "idCommande" TEXT PRIMARY KEY,
  "idClient" TEXT NOT NULL,
  "idCollab" TEXT,
  "statut" TEXT NOT NULL DEFAULT 'en_attente',
  "dateCommande" TIMESTAMP DEFAULT NOW(),
  "dateLivraison" TIMESTAMP,
  "montantTotal" DECIMAL(10, 2) NOT NULL,
  "adresseLivraison" TEXT NOT NULL,
  "notes" TEXT,
  "created_at" TIMESTAMP DEFAULT NOW(),
  "updated_at" TIMESTAMP DEFAULT NOW(),
  FOREIGN KEY ("idClient") REFERENCES "Client"("idClient"),
  FOREIGN KEY ("idCollab") REFERENCES "Collaborateurs"("idCollab")
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_collaborateurs_role ON "Collaborateurs"("role");
CREATE INDEX IF NOT EXISTS idx_collaborateurs_email ON "Collaborateurs"("email");
CREATE INDEX IF NOT EXISTS idx_commande_statut ON "Commande"("statut");
CREATE INDEX IF NOT EXISTS idx_commande_date ON "Commande"("dateCommande");
CREATE INDEX IF NOT EXISTS idx_client_phone ON "Client"("phone");
```

---

## Testing the Database

After creating the tables and inserting sample data, you can test the application with:

1. **Client Login**: Use phone `+21698765432` and password `client123`
2. **Coordinator Login**: Use email `jean.dupont@example.com` and password `password123`
3. **Livreur Access**: Use email `sophie.martin@example.com` and password `password123`

Make sure to adjust authentication logic based on your actual implementation.
