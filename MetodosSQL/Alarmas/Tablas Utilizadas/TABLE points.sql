-- Table: points

-- DROP TABLE points;

CREATE TABLE points
(
  id integer NOT NULL,
  longitud numeric NOT NULL,
  latitud numeric NOT NULL,
  poligono_id numeric NOT NULL,
  CONSTRAINT "Points_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE points
  OWNER TO postgres;

-- Index: point_idx

-- DROP INDEX point_idx;

CREATE INDEX point_idx
  ON points
  USING btree
  (id);

