CREATE OR REPLACE VIEW prismas.v_acumulado_prisma AS 
	SELECT 
		fecha,
		id_poligono, 
		AVG(deformacion_radial) AS DEF ,  
		AVG(velocidad_radial) AS VEL ,  
		AVG(aceleracion_radial) AS ACEL,
		count(*) AS cantidad
	FROM 
		prismas.cons_alarma_prisma
		INNER JOIN	poligonos.poligono_prisma ON
				id_prisma = pointid

	GROUP BY
		fecha,
		id_poligono
	ORDER BY
		id_poligono,
		fecha;
ALTER TABLE prismas.v_acumulado_prisma
  OWNER TO postgres;
