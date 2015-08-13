from datetime import datetime
import numpy as np

# -----------------------------------------------------------------------------
#     Objeto Registro
# -----------------------------------------------------------------------------
class Registro(object):
	def __init__(self):
		self.Time=""
		self.Norte=0.0
		self.Este=0.0
		self.Altura=0.0
		self.D=0.0
		self.Hz=0.0
		self.V=0.0
		self.Hor_Distancia=0.0
		self.Velocidad=0.0 #TODO: Este campo es distinto al de la clase del CMM, ver como dejarlo
	def registro(self,fecha,data):
		self.Time=fecha
		self.Norte=data[0]
		self.Este=data[1]
		self.Altura=data[2]
		self.D=data[3]
		self.Hz=data[4]
		self.V=data[5]
		self.Hor_Distancia=data[6]
		self.Velocidad=data[7]
	def getData(self):
		return [(self.Time).strftime('%Y-%m-%d %H:%M:%S'),
          self.Norte,
          self.Este,
          self.Altura,
          self.D,
          self.Hz,
          self.V,
          self.Hor_Distancia,
          self.Velocidad]


# -----------------------------------------------------------------------------
#     Objeto Prisma
# -----------------------------------------------------------------------------
class Prisma(object):
	def __init__(self,name):
		self.name=name
		self.elementos=0 # Numero de registros que tiene el Prisma
		self.datos=[] # Objetos de clase "registro"
	def registro(self,fecha,data): # Fn para agregar un nuevo registro a Prisma
		reg=Registro()
		reg.registro(fecha,data)
		(self.datos).append(reg)
		self.elementos=self.elementos+1
	def listasXY(self): # Fn que entrega un vector con (t , D_t - D_0), con (D_t-D_0) en [cm]
		x=[]
		y=[]
		for ele in self.datos:
			x.append(ele.Time)
			y.append((ele.D-((self.datos)[0]).D)*100.0)
		return x,y
	def informacion(self): # Fn que devuelve (Nombre prisma, # elementos, valor maximo de deformacion, tiempo del valor maximo)
		x,y=self.listasXY()
		a=zip(x,np.abs(y)) # crea una lista con (xi,abs(yi))
		b=max(a,key=lambda l:l[1])	# Devuelve el maximo de a=(x,abs(y)), comparando su segundo atributo (a[1]=abs(y))
		res="%s\t%d\t%f\t%s"%(self.name,self.elementos,b[1],b[0])
		return res
	def sortbyTime(self):
		self.datos=sorted(self.datos,key=lambda l:l.Time)
	def getData(self,k):
		return (self.datos[k]).getData()
	def creaInicio(self): # Crea un arreglo con dato inicial en la primera hora con registros "HH:00:00"
		self.sortbyTime()
		x,y = self.listasXY()
		xx = x
		yy = y
		if x[0].minute>0 or x[0].second >0:
			startday=datetime(year=x[0].year,month=x[0].month,day=x[0].day,hour=x[0].hour)
			xx.insert(0,startday)
			yy.insert(0,y[0])
		return xx,yy
	def getColumn(self,columna): # Obtiene todos los datos del campo "columna" como una lista
		xx = []
		for i in xrange(self.elementos):
			xx.append((self.datos[i]).getData()[columna])
		return xx


# -----------------------------------------------------------------------------
#     Objeto TablaPrisma
# -----------------------------------------------------------------------------
class TablaPrismas(object):
	def __init__(self,name):
		self.name=name
		self.elementos=0
		self.namePrismas=[]
		self.dataPrismas=[] # Arreglo con objetos de clase Prisma
	def registro(self,name,fecha,data): # Fn para annadir un nuevo registro a un prisma, si no existe, lo crea
		indice=0
		if not (name in self.namePrismas):
			(self.namePrismas).append(name)
			(self.dataPrismas).append(Prisma(name)) # Crea un nuevo objeto Prisma y lo annade
			indice=-1
			self.elementos=self.elementos+1
		else:
			indice=(self.namePrismas).index(name)
		(self.dataPrismas[indice]).registro(fecha,data)
	def informacion(self): # Fn devuelve informacion para cada Prisma en TablaPrisma
		res=self.name
		for ele in self.dataPrismas:
			res=res+"\n"+ele.informacion()
		return res
	def listasXY(self,k): # Devuelve un arreglo con (t,Dt-D0) para el Prisma k de TablaPrisma
		return ((self.dataPrismas)[k]).listasXY()
	def sortbyTime(self):
		for k in self.dataPrismas:
			k.sortbyTime()
	def getData(self,p,k):
		return (self.dataPrismas[p]).getData(k)