-- re-run safe
DROP TABLE IF EXISTS Linked_List_Node;

PRAGMA foreign_keys = ON;

CREATE TABLE Linked_List_Node (
                                  memory_address INTEGER PRIMARY KEY,  -- node id / address
                                  var_name       TEXT    NOT NULL,
                                  data           BLOB,

    -- recursive 1:1: each node has one "next" (pointing to another node)
                                  next_address   INTEGER NOT NULL UNIQUE,

                                  FOREIGN KEY (next_address)
                                      REFERENCES Linked_List_Node(memory_address)
                                      ON UPDATE CASCADE
                                      ON DELETE RESTRICT
                                      DEFERRABLE INITIALLY DEFERRED,

    -- forbid self-loop
                                  CHECK (next_address <> memory_address)
);
