-- Table: prismas."parametro_AlarmaPrisma"

-- DROP TABLE prismas."parametro_AlarmaPrisma";

CREATE TABLE prismas."parametro_AlarmaPrisma"
(
  parametro character varying(32),
  valor double precision
)
WITH (
  OIDS=FALSE
);
ALTER TABLE prismas."parametro_AlarmaPrisma"
  OWNER TO postgres;
