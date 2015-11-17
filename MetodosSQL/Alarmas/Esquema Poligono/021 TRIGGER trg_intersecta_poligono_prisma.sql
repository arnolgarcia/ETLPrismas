CREATE TRIGGER trg_intersecta_poligono_prisma
AFTER UPDATE ON "poligonos"."poligono"
    FOR EACH ROW EXECUTE PROCEDURE "poligonos"."intersecta_poligono_prisma"();