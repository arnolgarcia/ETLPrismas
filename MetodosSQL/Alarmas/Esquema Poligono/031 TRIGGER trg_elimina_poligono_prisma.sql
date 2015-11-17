CREATE TRIGGER trg_elimina_poligono_prisma
BEFORE DELETE ON "poligonos"."poligono"
    FOR EACH ROW EXECUTE PROCEDURE "poligonos"."elimina_poligono_prisma"();