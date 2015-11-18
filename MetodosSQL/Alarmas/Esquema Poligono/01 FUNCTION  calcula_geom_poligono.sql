-- Function: poligonos.calcula_geom_poligono()

-- DROP FUNCTION poligonos.calcula_geom_poligono();

CREATE OR REPLACE FUNCTION poligonos.calcula_geom_poligono(integer)
 RETURNS VOID AS 
$BODY$

DECLARE

	/* Variables LOCALES */
	nCantidad$		INTEGER;
	/*variables lectura Cursor cur_Puntos*/
	cur_Puntos 		RECORD;	
	nIdPoligono$	ALIAS FOR $1;
	nIdPuntoMinimo$ INTEGER;
	nIdPuntoMaximo$ INTEGER;
	fLongitud$		NUMERIC;
	fLatitud$		NUMERIC;
	fLongitudMinima$	NUMERIC;
	fLatitudMinima$		NUMERIC;
	fLongitudMaxima$	NUMERIC;
	fLatitudMaxima$		NUMERIC;	
	/*--------------------------------- */
	sQuery$			VARCHAR(10000);

		
BEGIN

	nCantidad$ := 0;
	FOR cur_Puntos in
		SELECT
			id,
			longitud,
			latitud
		FROM 
			poligonos.points
		WHERE 
			poligono_id = nIdPoligono$	
		ORDER BY 
			id ASC

		LOOP
			fLongitud$ := cur_Puntos.longitud;
			fLatitud$ := cur_Puntos.latitud;
			nIdPuntoMaximo$ := cur_Puntos.id;

			IF nCantidad$ = 0 THEN
				nIdPuntoMinimo$ := cur_Puntos.id;
				fLongitudMinima$ := cur_Puntos.longitud;
				fLatitudMinima$ := cur_Puntos.latitud;
				sQuery$ := 'POLYGON(('  || fLongitud$ || ' ' || fLatitud$;
			ELSE
				sQuery$ := sQuery$ || ', ' || fLongitud$ || ' ' || fLatitud$;
				fLongitudMaxima$ := cur_Puntos.longitud;
				fLatitudMaxima$ := cur_Puntos.latitud;
			END IF;
			
			nCantidad$ := nCantidad$ +1;			
			
		END LOOP;
		
		sQuery$ := sQuery$ || ' ))';
		
--Raise notice 'sQuery$ %',sQuery$;		
		IF nCantidad$ > 2 THEN
			IF fLongitudMinima$ = fLongitudMaxima$ AND fLatitudMinima$ = fLatitudMaxima$ THEN
				UPDATE
					poligonos.poligono
				SET
					geom = ST_Transform (
								ST_GeomFromText (sQuery$,4326)
							,1000)
				WHERE
					id = nIdPoligono$;
			
			END IF;
		END IF;


	END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION poligonos.calcula_geom_poligono(integer)
  OWNER TO postgres;
