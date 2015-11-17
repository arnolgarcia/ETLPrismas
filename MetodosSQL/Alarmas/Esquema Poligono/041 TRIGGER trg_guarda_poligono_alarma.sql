CREATE TRIGGER trg_guarda_poligono_alarma
AFTER INSERT OR UPDATE ON "poligonos"."poligono_alarma"
    FOR EACH ROW EXECUTE PROCEDURE "poligonos"."guarda_poligono_alarma"();