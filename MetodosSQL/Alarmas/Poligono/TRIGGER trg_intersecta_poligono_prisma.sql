CREATE TRIGGER trg_intersecta_poligono_prisma
AFTER UPDATE ON "prismas"."poligono"
    FOR EACH ROW EXECUTE PROCEDURE "prismas"."intersecta_poligono_prisma"();