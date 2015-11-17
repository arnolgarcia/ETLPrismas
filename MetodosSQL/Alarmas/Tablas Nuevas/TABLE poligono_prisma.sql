CREATE TABLE poligonos.poligono_prisma
(
  id_poligono integer NOT NULL,
  id_prisma character varying NOT NULL,
  CONSTRAINT poligono_prisma_pkey PRIMARY KEY (id_poligono, id_prisma)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE poligonos.poligono_prisma
  OWNER TO postgres;
