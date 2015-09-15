-- Table: prismas.estado_consolidacion_prisma

-- DROP TABLE prismas.estado_consolidacion_prisma;

CREATE TABLE prismas.estado_consolidacion_prisma
(
	ID			SERIAL PRIMARY KEY,
	fechaconsolidacion	TIMESTAMP,
	codestado			VARCHAR(10),
	fechaestado			TIMESTAMP

)
WITH (
  OIDS=FALSE
);
ALTER TABLE prismas.estado_consolidacion_prisma
  OWNER TO postgres;
