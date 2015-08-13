
from datetime import datetime,timedelta
import numpy as np
import sys
from osgeo import ogr,osr
import prismas as pr

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
		Datos.registro(Line[0],datetime.strptime(Line[1], '"%Y-%m-%d %H:%M:%S"'),valores)
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
    # Inicializar objeto TablaPrisma
    Datos=pr.TablaPrismas(tablename)
    # iterate over features
    feat = lyr.GetNextFeature()
    while feat is not None:
        nombre = feat.GetField(fieldName[0])
        fecha = feat.GetField(fieldName[1])
        valores =[]
        for l in xrange(len(fieldName)-2):
            valores.append(feat.GetField(fieldName[l+2]))
        #valores[3]=-valores[3]
        Datos.registro(nombre,datetime.strptime(fecha, '%Y/%m/%d %H:%M:%S'),valores)
        feat = lyr.GetNextFeature()
    feat = None
    conn.Destroy()
    Datos.sortbyTime()
    return Datos

def InterMalla(x,y,horas): # interpola la malla (x,y), con un paso "horas" y partiendo desde x[0]
	xx=[x[0]] # x es la fecha hora
	yy=[y[0]] # y es el valor a interpolar en x+i*horas
	dt=timedelta(hours=horas)
	k=0
	while xx[-1]+dt<x[-1]:
		xx.append(xx[-1]+dt)
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
	dt=timedelta(hours=24)
	nexday=datetime(year=x[0].year,month=x[0].month,day=x[0].day,hour=0)
	xx=[]
	yy=[]
	k=0
	while x[-1]+dt>nexday:
		aux=0.0
		elementos=0
		while k<len(x) and x[k]<nexday:
			aux=aux+y[k]
			elementos=elementos+1
			k=k+1
		if elementos>0:
			yy.append(aux/elementos)
			xx.append(nexday)
		nexday=nexday+dt
	return xx,yy

def standarizarAlarma(TablaPrisma):
    for p in xrange(TablaPrisma.elementos):
        datos = TablaPrisma.dataPrismas[p]
        x,y = datos.creaInicio()
        xx,yy = InterMalla(x,y,1)
    return xx,yy,p+1

def interPrisma(prisma,hora):
    prisma.sortbyTime()
    norte = prisma.getColumn(1)
    este = prisma.getColumn(2)
    fecha,deformacion = prisma.listasXY()
    if fecha[0].minute>0 or fecha[0].second >0:
		startday=datetime(year=fecha[0].year,month=fecha[0].month,day=fecha[0].day,hour=fecha[0].hour)
		fecha.insert(0,startday)
		norte.insert(0,norte[0])
		este.insert(0,este[0])
		deformacion.insert(0,deformacion[0])
    deformacion = list(np.array(deformacion)*10.0) # deja la deformacion en [mm]
    interFecha,interDef =  InterMalla(fecha,deformacion,hora)
    aux,interNorte =  InterMalla(fecha,norte,hora)
    aux,interEste =  InterMalla(fecha,este,hora)
    interVel = list(np.array(interDef)/hora)
    return interFecha,interNorte,interEste,interDef,interVel

def creaBDalarmas(connString,tableinput,tableoutput,hora,MA_m,EWMA_m,EWMA_a):
    # Abrir la coneccion
    conn = ogr.Open(connString)
    # create the spatial reference, WGS84
    srs = osr.SpatialReference()
    srs.ImportFromEPSG(1000)
    # Crear la tabla con los campos
    layer = conn.CreateLayer(tableoutput, srs, ogr.wkbPoint, ['OVERWRITE=YES'] )
    field_name = ogr.FieldDefn("PointID", ogr.OFTString)
    field_name.SetWidth(24)
    layer.CreateField(field_name)
    layer.CreateField(ogr.FieldDefn("Fecha", ogr.OFTDateTime))
    layer.CreateField(ogr.FieldDefn("Norte", ogr.OFTReal))
    layer.CreateField(ogr.FieldDefn("Este", ogr.OFTReal))
    layer.CreateField(ogr.FieldDefn("Deformacion", ogr.OFTReal))
    layer.CreateField(ogr.FieldDefn("Velocidad", ogr.OFTReal))
    layer.CreateField(ogr.FieldDefn("Vel_MA", ogr.OFTReal))
    layer.CreateField(ogr.FieldDefn("Vel_EWMA", ogr.OFTReal))
    # Cargar tabla y agregar agregar atributos y feature la tabla de salida
    datos = cargarTabla(tableinput,connString)
    for prisma in datos.dataPrismas:
        pointid = prisma.name
        f,n,e,d,v = interPrisma(prisma,hora)
        vel_MA = MA(v,MA_m)
        vel_EWMA = EWMA(v,EWMA_m,EWMA_a)
        for i in xrange(len(f)):
            # create the feature
            feature = ogr.Feature(layer.GetLayerDefn())
            # Set the attributes using the values from the data
            feature.SetField("PointID", pointid)
            feature.SetField("Fecha", f[i].strftime('%Y-%m-%d %H:%M:%S'))
            feature.SetField("Norte", n[i])
            feature.SetField("Este", e[i])
            feature.SetField("Deformacion", d[i])
            feature.SetField("Velocidad", v[i])
            feature.SetField("Vel_MA", vel_MA[i])
            feature.SetField("Vel_EWMA", vel_EWMA[i])
            # create the WKT for the feature using Python string formatting
            wkt = "POINT(%f %f)" %  (float(n[i]) , float(e[i]))
            # Create the point from the Well Known Txt and set geom
            point = ogr.CreateGeometryFromWkt(wkt)
            feature.SetGeometry(point)
            # Create the feature in the layer (shapefile)
            layer.CreateFeature(feature)
            # Destroy the feature to free resources
            feature.Destroy()
    # eliminar el TimeZone del campo 'fecha'
    sql = 'ALTER TABLE %s ALTER COLUMN %s TYPE timestamp(6);' %(tableoutput,"Fecha")
    conn.ExecuteSQL(sql)
    # Destroy the data source to free resources
    conn.Destroy()

def MA(y,m):
    yy=[]
    w=1.0/(m+1)
    for t in xrange(len(y)):
        if t < m:
            yy.append(None)
        if t >= m:
            aux = 0
            for j in range(m+1):
                aux = aux + w*y[t-j]
            yy.append(aux)
    return yy

def EWMA(y,m,alpha):
    yy=[]
    for t in xrange(len(y)):
        if t < m:
            yy.append(None)
        if t >= m:
            aux = 0
            for j in range(m+1):
                aux = aux + alpha*((1.0-alpha)**j)*y[t-j]
            yy.append(aux)
    return yy
