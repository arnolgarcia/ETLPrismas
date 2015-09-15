-- Table: prismas.alarma_log

-- DROP TABLE prismas.alarma_log;

CREATE TABLE prismas.alarma_log
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
  log_fecha	timestamp NOT NULL,
  log_usuario character varying,
  CONSTRAINT alarma_log_pkey PRIMARY KEY (id,log_fecha)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE prismas.alarma_log
  OWNER TO postgres;
