﻿-- Function: prismas.guarda_alarma
-- DROP FUNCTION prismas.guarda_alarma();

CREATE OR REPLACE FUNCTION prismas.guarda_alarma()
 RETURNS trigger AS
$BODY$

DECLARE
	/* Variables LOCALES */
	sResult$		varchar(200);
	nCantidad$	integer;
	sTransaccion$	varchar(20);
BEGIN
	nCantidad$ := 0;
	
	SELECT
		COUNT(*)
	INTO
		nCantidad$
	FROM
		prismas.alarma_log
	where
	id = new.id;
	
	IF nCantidad$ <> 0 THEN
		sTransaccion$ := 'ACTUALIZACION';
	ELSE
		sTransaccion$ := 'CREACION';
	END IF;
	
	INSERT INTO
		prismas.alarma_log
	VALUES
	(
		NEW.id,
		NEW.nivel_bajo,
		NEW.nivel_medio,
		NEW.nivel_alto,
		NEW.id_tipo_sensor,
		NEW.id_alerta,
		NEW.parametro,
		NEW.campo,
		NEW.nombre,
		NEW.descripcion,
		NEW.algoritmo,
		NEW.estado,
		NOW(),
		0,
		sTransaccion$
	);
	
	SELECT 
		*
	INTO
		sResult$
	FROM 
		prismas.verificar_alarmas();
			
	RETURN NEW;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION prismas.guarda_alarma()
  OWNER TO postgres;
 