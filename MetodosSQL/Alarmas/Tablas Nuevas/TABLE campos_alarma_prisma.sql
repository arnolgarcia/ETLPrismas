-- Table: prismas.campos_alarma_prisma

-- DROP TABLE prismas.campos_alarma_prisma;

CREATE TABLE prismas.campos_alarma_prisma
(
  cod_campo varchar(30),
  descripcion_campo varchar(100),
  CONSTRAINT campos_alarma_prisma_pkey PRIMARY KEY (cod_campo)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE prismas.campos_alarma_prisma
  OWNER TO postgres;
