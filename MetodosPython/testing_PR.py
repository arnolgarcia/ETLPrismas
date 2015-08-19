__author__ = 'Arnol'

import ogr
import ClasePrismas as pr
import MetodosPrismas as met



# -----------------------------------------------------------------------------
#     Parametros
# -----------------------------------------------------------------------------

#TODO: borrar valores iniciales de configuarcion
host = "152.231.85.227"
port = "5433"
dbname = "Testing_AlarmaPrisma"
user = "postgres"
password = "Admin321"
connString = 'PG: host=%s port=%s dbname=%s user=%s password=%s' %(host,port,dbname,user,password)

tableinput = "prismas.consolidado_testing" #TODO: cambiar port tabla ".consolidado"
tableoutput = "prismas.test_ag4" #TODO: cambiar por ",consAlarmaPrisma"
hora = 12
MA_m = 3
EWMA_m = 3
EWMA_a = 0.3

# -----------------------------------------------------------------------------
#     Funciones
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
#     Testing
# -----------------------------------------------------------------------------

met.testConn(connString)

met.creaBDalarmas(connString,tableinput,tableoutput,hora,MA_m,EWMA_m,EWMA_a)
