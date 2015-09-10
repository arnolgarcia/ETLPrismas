__author__ = 'Arnol'


# Parametros
host = "152.231.85.227"
port = "5433"
dbname = "Testing_AlarmaPrisma"
user = "postgres"
password = "Admin321"
connString = 'PG: host=%s port=%s dbname=%s user=%s password=%s' %(host,port,dbname,user,password)

tableinput = "prismas.cons_alarma_prisma" #TODO: cambiar port tabla ".consolidado"