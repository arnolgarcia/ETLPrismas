-- F|unction: poligonos.intersecta_poligono_prisma
-- DROP FUNCTION poligonos.intersecta_poligono_prisma();

CREATE OR REPLACE FUNCTION poligonos.intersecta_poligono_prisma()
 RETURNS trigger AS
	$BODY$

DECLARE
	/* Variables LOCALES */
	nIdPoligono$	INTEGER;
	/*variables lectura Cursor cur_Interseccion*/
	cur_Interseccion 		RECORD;	
	sPointID$ varchar(255);
	sResult$		varchar(200);
	
BEGIN
	nIdPoligono$ := new.id;

	DELETE FROM 
		poligonos.poligono_prisma
	WHERE
		id_poligono = nIdPoligono$;
		
	FOR cur_Interseccion in		
		SELECT distinct
			pointid as prisma,
			id as poligono
		FROM
			prismas.cons_alarma_prisma
		INNER JOIN poligonos.poligono ON ST_Intersects (
			prismas.cons_alarma_prisma.geom,
			poligonos.poligono.geom
			)
		WHERE
			ST_isvalid (prismas.cons_alarma_prisma.geom) = 't'
			AND ST_isvalid (poligonos.poligono.geom) = 't'
			AND poligono.id = nIdPoligono$
	LOOP
	
		sPointID$ := cur_Interseccion.prisma;
		
		--BEGIN
			INSERT INTO
				poligonos.poligono_prisma
				(
				id_poligono,
				id_prisma
				)
			VALUES
				(
				nIdPoligono$,
				sPointID$
				);
		
	END LOOP;
		
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
ALTER FUNCTION poligonos.intersecta_poligono_prisma()
  OWNER TO postgres;
 