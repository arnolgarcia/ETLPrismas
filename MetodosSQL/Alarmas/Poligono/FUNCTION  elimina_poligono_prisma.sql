-- Function: prismas.elimina_poligono_prisma
-- DROP FUNCTION prismas.elimina_poligono_prisma();

CREATE OR REPLACE FUNCTION prismas.elimina_poligono_prisma()
 RETURNS trigger AS
$BODY$

DECLARE
	/* Variables LOCALES */
	nIdPoligono$	INTEGER;
	
BEGIN
	nIdPoligono$ := new.id;

	DELETE FROM 
		prismas.poligono_prisma
	WHERE
		id_poligono = nIdPoligono$;
			
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION prismas.elimina_poligono_prisma()
  OWNER TO postgres;
 