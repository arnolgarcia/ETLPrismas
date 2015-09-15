  
CREATE TRIGGER trg_calcular_geom_poligono
AFTER INSERT ON "prismas"."points"
    FOR EACH ROW EXECUTE PROCEDURE "prismas"."calcula_geom_poligono_trigger"();