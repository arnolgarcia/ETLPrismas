CREATE TRIGGER trg_guarda_poligono_alarma
AFTER INSERT OR UPDATE ON "prismas"."poligono_alarma"
    FOR EACH ROW EXECUTE PROCEDURE "prismas"."guarda_poligono_alarma"();