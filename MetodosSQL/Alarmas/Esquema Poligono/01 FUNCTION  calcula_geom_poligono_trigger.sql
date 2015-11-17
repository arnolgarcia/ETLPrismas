-- Function: poligonos.calcula_geom_poligono_trigger
-- DROP FUNCTION poligonos.calcula_geom_poligono_trigger();

CREATE OR REPLACE FUNCTION poligonos.calcula_geom_poligono_trigger()
 RETURNS trigger AS
$BODY$

DECLARE
	/* Variables LOCALES */
	nIdPoligono$	INTEGER;
	sResult$		varchar(200);
		
BEGIN
	nIdPoligono$ := new.poligono_id;
	
	SELECT 
		*
	INTO
		sResult$
	FROM 
		poligonos.calcula_geom_poligono(nIdPoligono$);
		
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION poligonos.calcula_geom_poligono_trigger()
  OWNER TO postgres;



 