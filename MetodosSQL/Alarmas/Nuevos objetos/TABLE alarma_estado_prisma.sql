CREATE TABLE prismas.alarma_estado_prisma
(
  id_estado_alarma	bigint,
  id_prisma			varchar(20),
  valor_campo		double precision,
  CONSTRAINT  alarma_estado_prisma_pk PRIMARY KEY (id_estado_alarma, id_prisma)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE prismas.alarma_estado_prisma
  OWNER TO postgres;