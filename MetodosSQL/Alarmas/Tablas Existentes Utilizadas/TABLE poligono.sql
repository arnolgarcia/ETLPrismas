-- Table: poligono

-- DROP TABLE poligono;

CREATE TABLE poligono
(
  id bigint NOT NULL,
  nombre character varying,
  zona_id bigint,
  CONSTRAINT poligono_pkey PRIMARY KEY (id),
  CONSTRAINT zona_fkey FOREIGN KEY (zona_id)
      REFERENCES zona (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE poligono
  OWNER TO postgres;

-- Index: poligono_idx

-- DROP INDEX poligono_idx;

CREATE INDEX poligono_idx
  ON poligono
  USING btree
  (id DESC);

