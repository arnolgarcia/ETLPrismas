-- Table: prismas.alarma

-- DROP TABLE prismas.alarma;

CREATE TABLE prismas.alarma
(
  id bigint NOT NULL,
  nivel_bajo double precision,
  nivel_medio double precision,
  nivel_alto double precision,
  id_tipo_sensor bigint,
  id_alerta bigint,
  parametro bigint,
  campo character varying,
  nombre character varying,
  descripcion character varying,
  algoritmo character varying,
  estado boolean,
  CONSTRAINT alarma_pkey PRIMARY KEY (id),
  CONSTRAINT alerta_fkey FOREIGN KEY (id_alerta)
      REFERENCES prismas.alerta (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE prismas.alarma
  OWNER TO postgres;
