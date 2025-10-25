-- Re-run safe: drop junction first, then parents
DROP TABLE IF EXISTS Pizza_Topping;
DROP TABLE IF EXISTS Food_Item;
DROP TABLE IF EXISTS Pizza;

PRAGMA foreign_keys = ON;

-- Parent 1: PIZZA
CREATE TABLE Pizza (
                       pizza_id    INTEGER PRIMARY KEY AUTOINCREMENT,  -- SQLite auto-incrementing rowid
                       name        TEXT    NOT NULL,
                       description TEXT
);

-- Parent 2: FOOD_ITEM
CREATE TABLE Food_Item (
                           name          TEXT    NOT NULL,                 -- acts as PK per diagram
                           is_delicious  INTEGER NOT NULL DEFAULT 0,       -- use 0/1 in SQLite
                           is_gross      INTEGER NOT NULL DEFAULT 0,
                           PRIMARY KEY (name)
);

-- Junction table: topped_with + relationship attribute added_cost
CREATE TABLE Pizza_Topping (
                               pizza_id    INTEGER  NOT NULL,
                               food_name   TEXT     NOT NULL,
                               added_cost  NUMERIC  NOT NULL DEFAULT 0.00,     -- non-negative money-ish value
                               PRIMARY KEY (pizza_id, food_name),
                               FOREIGN KEY (pizza_id)  REFERENCES Pizza(pizza_id)      ON DELETE CASCADE,
                               FOREIGN KEY (food_name) REFERENCES Food_Item(name)      ON DELETE CASCADE,
                               CHECK (added_cost >= 0)
);
