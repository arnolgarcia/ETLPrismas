CREATE TRIGGER trg_consolida_prisma
AFTER INSERT OR UPDATE ON "prismas"."estado_consolidacion_prisma"
    FOR EACH ROW EXECUTE PROCEDURE "prismas"."consolida_prisma"();