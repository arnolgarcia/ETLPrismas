-- Table: prismas.alarma_estado_actual

-- DROP TABLE prismas.alarma_estado_actual;

CREATE TABLE prismas.alarma_estado_actual
(
  id serial NOT NULL,
  fecha_creacion timestamp without time zone,
  id_alarma integer,
  estado character varying(20),
  fecha_proceso timestamp without time zone,
  par_nivel_medio double precision,
  par_nivel_alto double precision,
  id_tipo_sensor bigint,
  id_alerta bigint,
  parametro bigint,
  campo character varying,
  valor_alarma double precision,
  prisma_alarma character varying(20),
  CONSTRAINT alarma_estado_actual_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE prismas.alarma_estado_actual
  OWNER TO postgres;
