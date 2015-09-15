CREATE TABLE prismas.alarma_estado_resumen
(
  fecha_creacion	timestamp,
  fecha_estado_desde	timestamp,
  fecha_estado_hasta	timestamp,
  cantidad_nivel_medio	integer,
  cantidad_nivel_alto	integer,
  estado	character varying,
  CONSTRAINT alarma_estado_resumen_pkey PRIMARY KEY (fecha_estado_desde,fecha_estado_hasta)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE prismas.alarma_estado_resumen
  OWNER TO postgres;