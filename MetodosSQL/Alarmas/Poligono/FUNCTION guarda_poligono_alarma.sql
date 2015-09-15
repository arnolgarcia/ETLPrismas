-- Function: prismas.guarda_poligono_alarma
-- DROP FUNCTION prismas.guarda_poligono_alarma();

CREATE OR REPLACE FUNCTION prismas.guarda_poligono_alarma()
 RETURNS trigger AS
$BODY$

DECLARE
	/* Variables LOCALES */
	sResult$		varchar(200);
	
BEGIN
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
ALTER FUNCTION prismas.guarda_poligono_alarma()
  OWNER TO postgres;
 