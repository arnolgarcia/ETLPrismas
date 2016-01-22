-- Function: prismas.verificar_alarmas()

-- DROP FUNCTION prismas.verificar_alarmas();

CREATE OR REPLACE FUNCTION prismas.verificar_alarmas()
  RETURNS INTEGER AS
$BODY$

DECLARE

	/* Variables LOCALES */
	tFecha$		timestamp;
	sEstado$	varchar(20);
	nIdAlarmaEstado$	BIGINT;
	/*variables lectura Cursor Alarmas*/
	nIdAlarma$	INTEGER;
	fNivelMedio$ double precision;
	fNivelAlto$ 	double precision;
	nIdTipoSensor$	BIGINT;
	nIdAlerta$	BIGINT;
	nParametro$	BIGINT;
	sCampo$		VARCHAR(200);
	/*variables cursor vistasPrismas */
	nVisPrisma$ VARCHAR(20);
	nVispoligono$ BIGINT;
	tVisFecha$ timestamp;
	tVisFechaAnterior$ timestamp;
	tVisCampo$ varchar (20);
	fVisValorCampo$	double precision;
	/*--------------------------------- */
	--sQuery$			VARCHAR(200);
	cur_Alarmas 		RECORD;
	cur_VistaPrismas	RECORD;
		
BEGIN
	
	FOR cur_Alarmas in
		SELECT
			id,
			nivel_medio,
			nivel_alto,
			id_tipo_sensor,
			id_alerta,
			parametro,
			campo
		FROM 
			prismas.alarma
		WHERE 
			estado = true		

		LOOP

			nIdAlarma$ := cur_Alarmas.id;
			fNivelMedio$ := cur_Alarmas.nivel_medio;
			fNivelAlto$ := cur_Alarmas.nivel_alto;
			nIdTipoSensor$  := cur_Alarmas.id_tipo_sensor;
			nIdAlerta$  := cur_Alarmas.id_alerta;
			nParametro$  := cur_Alarmas.parametro;
			sCampo$  := cur_Alarmas.campo;
			tFecha$ := NULL;
			
			--BEGIN
			SELECT
				MAX(fecha_proceso)
			INTO
				tFecha$
			FROM
				prismas.alarma_estado_actual
			WHERE
				id_alarma = nIdAlarma$;
			/*EXCEPTION
				WHEN NO_DATA_FOUND THEN
				tFecha$ := TO_DATE('19000101','YYYYMMDD');
			END;*/
			IF tFecha$ IS NULL THEN
				tFecha$ := TO_DATE('19000101','YYYYMMDD');
			END IF;
			
			tVisFechaAnterior$ := TO_DATE('19000101','YYYYMMDD');
			
			FOR cur_VistaPrismas IN
				SELECT
					prisma,
					poligono,
					fecha,
					campo,
					valor_campo
				FROM
					prismas.v_consolidado_prismas
				WHERE
					alarma = nIdAlarma$ AND
					fecha >= tFecha$
				ORDER BY
					fecha ASC,
					valor_campo DESC
					
				LOOP
					nVisPrisma$ := cur_VistaPrismas.prisma;
					nVispoligono$  := cur_VistaPrismas.poligono;
					tVisFecha$  := cur_VistaPrismas.fecha;
					tVisCampo$  := cur_VistaPrismas.campo;
					fVisValorCampo$	 := cur_VistaPrismas.valor_campo;
				
					IF tVisFechaAnterior$ <> tVisFecha$ THEN
					-- verificar los posibles valores y operaciones a partir del tipo de campo (valores positivos, negativos, absolutos, etc)
						IF fVisValorCampo$ >= fNivelAlto$ THEN
							sEstado$ := 'ALTO';
						ELSE
							IF fVisValorCampo$ >= fNivelMedio$ THEN
								sEstado$ := 'MEDIO';
							ELSE
								sEstado$ := 'BAJO';
							END IF;
						END IF;
						
						nIdAlarmaEstado$ := nextval('prismas.alarma_estado_actual_id_seq');
						/*validar con calma, la opcion de: para una misma alarma/fecha, verificar si los datos o prismas cambiaron */
						INSERT INTO
						prismas.alarma_estado_actual
						(
							id,
							fecha_creacion,
							id_alarma,
							estado,
							fecha_proceso,
							par_nivel_medio,
							par_nivel_alto,
							id_tipo_sensor,
							id_alerta,
							parametro,
							campo,
							valor_alarma,
							prisma_alarma
						)
						VALUES
						(
							nIdAlarmaEstado$,
							NOW(),
							nIdAlarma$,
							sEstado$,
							tVisFecha$,
							fNivelMedio$,
							fNivelAlto$,
							nIdTipoSensor$,
							nIdAlerta$,
							nParametro$,
							sCampo$,
							fVisValorCampo$,
							nVisPrisma$
						);
						
						tVisFechaAnterior$ := tVisFecha$;
					END IF;
					
					INSERT INTO
					prismas.alarma_estado_prisma
					(
						id_estado_alarma,
						id_prisma,
						valor_campo
					)
					VALUES
					(
						nIdAlarmaEstado$,
						nVisPrisma$,
						fVisValorCampo$
					);
				END LOOP;
	
						
			
		END LOOP;
	RETURN 0;
	
END;
	
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION prismas.verificar_alarmas()
  OWNER TO postgres;