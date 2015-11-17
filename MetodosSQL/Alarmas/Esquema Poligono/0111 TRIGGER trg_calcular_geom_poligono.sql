  
CREATE TRIGGER trg_calcular_geom_poligono
AFTER INSERT ON "poligonos"."points"
    FOR EACH ROW EXECUTE PROCEDURE "poligonos"."calcula_geom_poligono_trigger"();