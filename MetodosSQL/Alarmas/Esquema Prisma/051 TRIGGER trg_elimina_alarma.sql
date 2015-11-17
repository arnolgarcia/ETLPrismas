CREATE TRIGGER trg_elimina_alarma
BEFORE DELETE  ON "prismas"."alarma"
    FOR EACH ROW EXECUTE PROCEDURE "prismas"."elimina_alarma"();