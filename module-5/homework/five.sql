-- Only new code for the recursive relationship
PRAGMA foreign_keys = ON;

-- Each row says: base_ingredient -> is used in -> prepared_food
CREATE TABLE Food_Composition (
                                  prepared_food   TEXT NOT NULL,   -- references Food_Item(name)
                                  base_ingredient TEXT NOT NULL,   -- references Food_Item(name)
                                  PRIMARY KEY (prepared_food, base_ingredient),

                                  FOREIGN KEY (prepared_food)
                                      REFERENCES Food_Item(name)
                                      ON DELETE CASCADE,

                                  FOREIGN KEY (base_ingredient)
                                      REFERENCES Food_Item(name)
                                      ON DELETE CASCADE

    -- Optional guard to forbid an item listing itself as an ingredient:
    -- ,CHECK (prepared_food <> base_ingredient)
);
