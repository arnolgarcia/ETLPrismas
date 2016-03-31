
#from datetime import datetime,timedelta
import numpy as np
import sys
from osgeo import ogr,osr
import ClasePrismas as pr
import datetime as dt

# -----------------------------------------------------------------------------
#   Funciones y metodos
# -----------------------------------------------------------------------------
def cargarArchivo(filename): # Guarda un archivo de texto como un objeto TablaPrisma
	#print "Cargando %s" % filename
	file=open(filename)
	line=file.readline()
	#encabezado
	line=file.readline()
	Datos=pr.TablaPrismas(filename)
	while (line != ""):
		Line=line.split(";")
		#print Line[2:]
		valores=map(float,Line[2:])
		#valores[3]=-valores[3]
		Datos.registro(Line[0],dt.datetime.strptime(Line[1], '"%Y-%m-%d %H:%M:%S"'),valores)
		line=file.readline()
	file.close()
	Datos.sortbyTime()
	return Datos

def cargarTabla(tablename,connString): # Guarda una table desde PG como objeto TablaPrisma
	conn = ogr.Open(connString)
	lyr = conn.GetLayer( tablename )
	if lyr is None:
		print >> sys.stderr, '[ ERROR ]: layer name = "%s" could not be found in defined database' % ( tablename )
		sys.exit( 1 )
	lyrDefn = lyr.GetLayerDefn()
	fieldName = []
	fieldType = []
	for i in xrange( lyrDefn.GetFieldCount() ):
		fieldName.append(lyrDefn.GetFieldDefn(i).GetName())
		fieldTypeCode = lyrDefn.GetFieldDefn(i).GetType()
		fieldType.append(lyrDefn.GetFieldDefn(i).GetFieldTypeName(fieldTypeCode))
	# Inicializar objeto TablaPrisma con nombre igual a tablename
	Datos=pr.TablaPrismas(tablename)
	# iterate over features
	feat = lyr.GetNextFeature()
	while feat is not None:
		nombre = feat.GetField(fieldName[0])
		fecha = feat.GetField(fieldName[1])
		valores =[]
		for l in xrange(len(fieldName)-2):
			valores.append(feat.GetField(fieldName[l+2]))
		#valores[3]=-valores[3] # TODO: revisar esto
		Datos.registro(nombre,dt.datetime.strptime(fecha, '%Y/%m/%d %H:%M:%S'),valores)
		feat = lyr.GetNextFeature()
	#feat.Destroy()
	conn.Destroy()
	Datos.sortbyTime()
	return Datos
#   Fin de la funcion

def InterMalla(x,y,horas): # interpola la malla (x,y), con un paso "horas" y partiendo desde x[0]
	xx=[x[0]] # x es la fecha hora
	yy=[y[0]] # y es el valor a interpolar en x+i*horas
	deltat=dt.timedelta(hours=horas)
	k=0
	while xx[-1]+deltat<x[-1]:
		xx.append(xx[-1]+deltat)
		while((x[k]>=xx[-1])or (x[k+1]<xx[-1])): # el x[k]>=xx[-1] esta de mas??
			k=k+1
		e=(xx[-1]-x[k])/int((x[k+1]-x[k]).total_seconds())
		e=e.total_seconds()
		aux=y[k+1]*e+(1-e)*y[k] # =y[k] + e*(y[k+1]-y[k])
		yy.append(aux)
	return xx,yy

def filtro(y,l): # Calcula MA centradas de radio l con reflejo en los bordes y datos equidistantes
	n=len(y)
	#reflejo en los bordes
	yy=[]
	for k in xrange(0,n):
		fil=y[k]
		for i in xrange(1,l+1):
			esig=k+i
			if esig>(n-1):
				esig=n-(esig-(n-1)) # reflejo en el borde derecho
			eant=k-i
			if eant<0:
				eant=-eant # reflejo en el borde izquerdo
			fil=fil+y[esig]+y[eant]
		fil=fil/(2*l+1)
		yy.append(fil)
	return yy

def filtro2(y,l,n): # Aplica la funcion filtro n+1 veces sobre los datos
	yy=filtro(y,l)
	for k in xrange(0,n):
		yy=filtro(yy,l)
	return yy

def dife(x,y,aux): # Calcula diferencias finitas en cada punto ("velocidad")
	yy=[0]
	n=len(y)
	for k in xrange(1,n):
		delta=x[k]-x[k-1]
		if aux:
			delta=delta.total_seconds()/3600
		else:
			delta=1.0
		yy.append((y[k]-y[k-1])/delta)
	return yy

def filtroWeek(x,y): # Agrupa (promedia) los valores por dia
	deltat=dt.timedelta(hours=24)
	nexday=dt.datetime(year=x[0].year,month=x[0].month,day=x[0].day,hour=0)
	xx=[]
	yy=[]
	k=0
	while x[-1]+deltat>nexday:
		aux=0.0
		elementos=0
		while k<len(x) and x[k]<nexday:
			aux=aux+y[k]
			elementos=elementos+1
			k=k+1
		if elementos>0:
			yy.append(aux/elementos)
			xx.append(nexday)
		nexday=nexday+deltat
	return xx,yy

def interPrisma(prisma,hora):
	prisma.sortbyTime()
	norte = prisma.getColumn(1)
	este = prisma.getColumn(2)
	altura = prisma.getColumn(3)
	fecha,deformacion = prisma.listasXY()
	if fecha[0].minute>0 or fecha[0].second >0 or fecha[0].hour >0:
		startday=dt.datetime(year=fecha[0].year,month=fecha[0].month,day=fecha[0].day)
		fecha.insert(0,startday)
		norte.insert(0,norte[0])
		este.insert(0,este[0])
		altura.insert(0,altura[0])
		deformacion.insert(0,deformacion[0])
	deformacion = list(np.array(deformacion)*10.0) # deja la deformacion en [mm]
	interFecha,interDef =  InterMalla(fecha,deformacion,hora)
	aux,interNorte =  InterMalla(fecha,norte,hora)
	aux,interEste =  InterMalla(fecha,este,hora)
	aux,interAltura =  InterMalla(fecha,altura,hora)
	interVel = list((np.array(interDef[1:])-np.array(interDef[0:-1]))/hora)
	interAcel= list((np.array(interVel[1:])-np.array(interVel[0:-1]))/hora)
	interVel.insert(0,None)
	interAcel.insert(0,None)
	interAcel.insert(0,None)
	return interFecha,interNorte,interEste,interAltura,interDef,interVel,interAcel

def creaBDalarmas(connString,tableinput,tableoutput,hora,MA_m,EWMA_a):
	if len(tableoutput.split("."))==2:
		schema = tableoutput.split(".")[0]
		tablename = tableoutput.split(".")[1]
	else:
		print "[ ERROR ]: Entregar tableoutput como 'esquema.tabla'"
		sys.exit( 1 )
	time_ini = dt.datetime.now()
	ogr.UseExceptions()
	try:
		conn = ogr.Open(connString)
	except:
		print '[ ERROR ]: Error de conexion'
		sys.exit( 1 )
	# create the spatial reference, 1000: Coordenadas MEL local
	srs = osr.SpatialReference()
	srs.ImportFromEPSG(4326)
	# Crear la tabla con los campos
	layer = conn.CreateLayer(tableoutput, srs, ogr.wkbPoint, ['OVERWRITE=YES','GEOMETRY_NAME=geom'] )
	field_name = ogr.FieldDefn("PointID", ogr.OFTString)
	field_name.SetWidth(24)
	layer.CreateField(field_name)
	layer.CreateField(ogr.FieldDefn("fecha", ogr.OFTDateTime))
	layer.CreateField(ogr.FieldDefn("norte", ogr.OFTReal))
	layer.CreateField(ogr.FieldDefn("este", ogr.OFTReal))
	layer.CreateField(ogr.FieldDefn("altura", ogr.OFTReal))
	layer.CreateField(ogr.FieldDefn("deformacion_radial", ogr.OFTReal))
	layer.CreateField(ogr.FieldDefn("velocidad_radial", ogr.OFTReal))
	layer.CreateField(ogr.FieldDefn("aceleracion_radial", ogr.OFTReal))
	layer.CreateField(ogr.FieldDefn("def_ma_radial", ogr.OFTReal))
	layer.CreateField(ogr.FieldDefn("def_ewma_radial", ogr.OFTReal))
	layer.CreateField(ogr.FieldDefn("vel_ma_radial", ogr.OFTReal))
	layer.CreateField(ogr.FieldDefn("vel_ewma_radial", ogr.OFTReal))
	layer.CreateField(ogr.FieldDefn("acel_ma_radial", ogr.OFTReal))
	layer.CreateField(ogr.FieldDefn("acel_ewma_radial", ogr.OFTReal))
	# Cargar tabla y agregar atributos y feature la tabla de salida
	datos = cargarTabla(tableinput,connString)
	ntotal = datos.elementos
	print "Numero de prismas a cargar: %d"%(ntotal)
	iter = 1
	for prisma in datos.dataPrismas:
		pointid = prisma.name
		print("procesando prisma "+ pointid + " ... "),
		f,n,e,a,d,v,acel_r = interPrisma(prisma,hora)
		def_MA = MA(d,MA_m)
		def_EWMA = EWMA(d,EWMA_a)
		vel_MA = MA(v,MA_m)
		vel_EWMA = EWMA(v,EWMA_a)
		acel_MA = MA(acel_r,MA_m)
		acel_EWMA = EWMA(acel_r,EWMA_a)
		for i in xrange(len(f)):
			# create the feature
			feature = ogr.Feature(layer.GetLayerDefn())
			# Set the attributes using the values from the data
			feature.SetField("pointid", pointid)
			feature.SetField("fecha", f[i].strftime('%Y-%m-%d %H:%M:%S'))
			feature.SetField("norte", n[i])
			feature.SetField("este", e[i])
			feature.SetField("altura", a[i])
			feature.SetField("deformacion_radial", d[i])
			feature.SetField("velocidad_radial", v[i])
			feature.SetField("aceleracion_radial", acel_r[i]) #TODO: calcular aceleracion
			feature.SetField("def_ma_radial", def_MA[i])
			feature.SetField("def_ewma_radial", def_EWMA[i])
			feature.SetField("vel_ma_radial", vel_MA[i])
			feature.SetField("vel_ewma_radial", vel_EWMA[i])
			feature.SetField("acel_ma_radial", acel_MA[i])
			feature.SetField("acel_ewma_radial", acel_EWMA[i])
			# create the WKT for the feature using Python string formatting
			#wkt = "POINT(%f %f)" %  (float(n[i]) , float(e[i]))
			# Create the point from the Well Known Txt and set geom
			#point = ogr.CreateGeometryFromWkt(wkt)
			#feature.SetGeometry(point)
			# Create the feature in the layer (shapefile)
			layer.CreateFeature(feature)
			# Destroy the feature to free resources
			feature.Destroy()
		print " prisma '%s' procesado (%d/%d)"%(pointid,iter,ntotal)
		iter = iter + 1
	# eliminar el TimeZone del campo 'fecha'
	sql1 = 'ALTER TABLE %s ALTER COLUMN %s TYPE timestamp(6);' %(tableoutput,"fecha")
	printSQL(sql1)
	conn.ExecuteSQL(sql1)
	# cambiar el srid a 1000
	sql2 = "select UpdateGeometrySRID('%s', '%s', '%s', %d) ;" %(schema,tablename,'geom',1000)
	printSQL(sql2)
	conn.ExecuteSQL(sql2)
	# Calcular el campo geom
	sql3 = 'update "%s"."%s" set geom = ST_SetSRID(ST_MakePoint("%s"."norte" , "%s"."este") , 1000);' \
		   ' Create INDEX idx_%s on "%s"."%s" USING Gist(geom);' %(schema,tablename,tablename,tablename,tablename,schema,tablename)
	printSQL(sql3)
	conn.ExecuteSQL(sql3)
	# TODO: ejecutar sql para cambiar estado (trigger)
#	sql4 = ''
#	printSQL(sql4)
#	conn.ExecuteSQL(sql4)
	# Destroy the data source to free resources
	conn.Destroy()
	# Imprime fin del proceso
	time_fin = dt.datetime.now()
	print "Carga de archivos finalizada"
	print "Tiempo de ejecucion: " + str(time_fin-time_ini)
#	Fin de la funcion

def MA(y,m):
	if m < 0:
		print '[ ERROR ]: parametros no validos para  la funcion MA'
		sys.exit( 1 )
	yy=[]
	w=1.0/(m+1)
	for t in xrange(len(y)):
		if t < m or y[t-m]==None:
			yy.append(None)
		else:
			aux = 0
			for j in range(m+1):
				aux = aux + w*y[t-j]
			yy.append(aux)
	return yy

def EWMA(y,alpha):
	alpha = 1.0*alpha
	yy = []
	if y[0]==None:
		yy.append(0.0)
	else:
		yy.append(y[0])
	for t in range(1,len(y)):
		if y[t]==None:
			st = 0.0
		else:
			st = alpha*y[t]+(1.0-alpha)*yy[t-1]
		yy.append(st)
	return yy

def testConn(connString):
	ogr.UseExceptions()
	try:
		conn = ogr.Open(connString)
		conn.Destroy()
		print "Conexion exitosa"
	except:
		print '[ ERROR ]: Error de conexion'
		sys.exit( 1 )
#   Fin de la funcion

def aceleracion(vel,tiempo):
	acel = []
	acel.append(None)
	for i in range(len(vel)-1):
		acel_i = (vel[i+1]-vel[i])*1.0/tiempo
		acel.append(acel_i)
	return acel
#	Fin de la funcion

def printSQL(sqltext):
	print "Ejecutando sentencia SQL '%s'"%(sqltext)
#	Fin de la funcion
