CREATE TRIGGER trg_elimina_poligono_prisma
BEFORE DELETE ON "prismas"."poligono"
    FOR EACH ROW EXECUTE PROCEDURE "prismas"."elimina_poligono_prisma"();