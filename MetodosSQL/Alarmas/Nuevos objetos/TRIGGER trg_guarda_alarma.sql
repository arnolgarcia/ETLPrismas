CREATE TRIGGER trg_guarda_alarma
AFTER INSERT OR UPDATE  ON "prismas"."alarma"
    FOR EACH ROW EXECUTE PROCEDURE "prismas"."guarda_alarma"();