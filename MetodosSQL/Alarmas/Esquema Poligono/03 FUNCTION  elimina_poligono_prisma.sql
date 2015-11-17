-- Function: poligonos.elimina_poligono_prisma
-- DROP FUNCTION poligonos.elimina_poligono_prisma();

CREATE OR REPLACE FUNCTION poligonos.elimina_poligono_prisma()
 RETURNS trigger AS
$BODY$

DECLARE
	/* Variables LOCALES */
	nIdPoligono$	INTEGER;
	
BEGIN
	nIdPoligono$ := new.id;

	DELETE FROM 
		poligonos.poligono_prisma
	WHERE
		id_poligono = nIdPoligono$;
			
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION poligonos.elimina_poligono_prisma()
  OWNER TO postgres;
 