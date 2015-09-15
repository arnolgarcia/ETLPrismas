-- Function: prismas.consolida_prisma()

-- DROP FUNCTION prismas.consolida_prisma();

CREATE OR REPLACE FUNCTION prismas.consolida_prisma()
  RETURNS trigger AS
$BODY$

DECLARE
	/* Variables de Entrada */

	/*--------------------------------- */
	cur_Prismas 	RECORD;
	sPointID$		VARCHAR(20);
	gGeom$			geometry;
	
	cur_Poligonos	RECORD;
	nIdPoligono$	INTEGER;
	/* Variables  */
	sResult$		varchar(200);

	
BEGIN
	
	IF NEW.codestado = 'PENDI' THEN
		
		DELETE FROM 
			prismas.poligono_prisma;
				
		FOR cur_Prismas IN
			SELECT distinct
				pointid as prisma,
				id as poligono
			FROM
				prismas.cons_alarma_prisma
			INNER JOIN prismas.poligono ON ST_Intersects (
				prismas.cons_alarma_prisma.geom,
				prismas.poligono.geom
				)
			WHERE
				ST_isvalid (prismas.cons_alarma_prisma.geom) = 't'
				AND ST_isvalid (prismas.poligono.geom) = 't'

			LOOP

				sPointID$ := cur_Prismas.prisma;
				nIdPoligono$ := cur_Prismas.poligono;
			
			
				INSERT INTO
					prismas.poligono_prisma
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
		
		UPDATE
			prismas.estado_consolidacion_prisma
		SET
			codestado = 'FINAL',
			fechaestado = now()
		WHERE
			id = new.id;			
	
	END IF;
	
 RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION prismas.consolida_prisma()
  OWNER TO postgres;
    