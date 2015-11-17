-- Function: prismas.elimina_alarma
-- DROP FUNCTION prismas.elimina_alarma();

CREATE OR REPLACE FUNCTION prismas.elimina_alarma()
 RETURNS trigger AS
$BODY$

DECLARE
	/* Variables LOCALES */
	sResult$		varchar(200);
	
BEGIN

	INSERT INTO
		prismas.alarma_log
	VALUES
	(
		OLD.id,
		OLD.nivel_bajo,
		OLD.nivel_medio,
		OLD.nivel_alto,
		OLD.id_tipo_sensor,
		OLD.id_alerta,
		OLD.parametro,
		OLD.campo,
		OLD.nombre,
		OLD.descripcion,
		OLD.algoritmo,
		OLD.estado,
		NOW(),
		0,
		'ELIMINACION'
	);
		
	RETURN NEW;
	
END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION prismas.elimina_alarma()
  OWNER TO postgres;
 