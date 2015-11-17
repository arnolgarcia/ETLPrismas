CREATE OR REPLACE VIEW prismas.v_acumulado_prisma_detalle AS 
	SELECT 
		fecha,
		id_poligono, 
		deformacion_radial,  
		velocidad_radial,  
		aceleracion_radial,
		pointid
	FROM 
		prismas.cons_alarma_prisma
		INNER JOIN	poligonos.poligono_prisma ON
				id_prisma = pointid

	ORDER BY
		id_poligono,
		fecha;
ALTER TABLE prismas.v_acumulado_prisma_detalle
  OWNER TO postgres;
