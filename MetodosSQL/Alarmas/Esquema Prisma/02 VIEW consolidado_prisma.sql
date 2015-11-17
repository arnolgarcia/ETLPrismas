CREATE OR REPLACE VIEW prismas.v_consolidado_prismas AS 
	SELECT DISTINCT
		alarma.id AS alarma,
		poligono_prisma.id_prisma AS prisma,
		poligono_prisma.id_poligono AS poligono,
		cons_alarma_prisma.fecha,
		alarma.campo,
		CASE 
			WHEN (LOWER(alarma.campo) = 'deformacion_radial')
				THEN cons_alarma_prisma.deformacion_radial
			WHEN (LOWER(alarma.campo) = 'velocidad_radial')
				THEN cons_alarma_prisma.velocidad_radial
			WHEN (LOWER(alarma.campo) = 'aceleracion_radial')
				THEN cons_alarma_prisma.aceleracion_radial
			WHEN (LOWER(alarma.campo) = 'def_ma_radial')
				THEN cons_alarma_prisma.def_ma_radial
			WHEN (LOWER(alarma.campo) = 'def_ewma_radial')
				THEN cons_alarma_prisma.def_ewma_radial
			WHEN (LOWER(alarma.campo) = 'vel_ma_radial')
				THEN cons_alarma_prisma.vel_ma_radial
			WHEN (LOWER(alarma.campo) = 'vel_ewma_radial')
				THEN cons_alarma_prisma.vel_ewma_radial
			WHEN (LOWER(alarma.campo) = 'acel_ma_radial')
				THEN cons_alarma_prisma.acel_ma_radial
			WHEN (LOWER(alarma.campo) = 'acel_ewma_radial')
				THEN cons_alarma_prisma.acel_ewma_radial
			ELSE
				0
		END AS Valor_Campo

	FROM 
		prismas.cons_alarma_prisma
		INNER JOIN poligonos.poligono_prisma ON 
			poligono_prisma.id_prisma = cons_alarma_prisma.pointid
		INNER JOIN prismas.poligono_alarma ON
			poligono_alarma.id_poligono = poligono_prisma.id_poligono
		INNER JOIN prismas.alarma ON
			alarma.id = poligono_alarma.id_alarma
WHERE
	alarma.estado = true
	AND cons_alarma_prisma.fecha > current_date - CAST(
												(SELECT 
													valor 
												FROM 
													prismas."parametro_AlarmaPrisma" 
												WHERE 
													UPPER(parametro) = 'MOSTRAR_DIAS'
												) as integer)
ORDER BY 
	alarma.id,
	poligono_prisma.id_prisma,
	cons_alarma_prisma.fecha;

ALTER TABLE prismas.v_consolidado_prismas
  OWNER TO postgres;
