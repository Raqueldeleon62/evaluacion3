from datetime import datetime

from typing import Optional, List

from fastapi import FastAPI, UploadFile, Form, File, HTTPException, Depends

from sqlalchemy import create_engine, Column, Integer, String, TIMESTAMP, DECIMAL, Enum, ForeignKey

from sqlalchemy.ext.declarative import declarative_base

from sqlalchemy.orm import sessionmaker, relationship, Session

from pydantic import BaseModel

from fastapi.staticfiles import StaticFiles

from fastapi.middleware.cors import CORSMiddleware

import shutil
import requests

import os
import hashlib  #Para encriptar con MD5

app= FastAPI()

app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

DATABASE_URL= "mysql+pymysql://root:@localhost/logistica"

engine = create_engine(DATABASE_URL)

SessionLocal = sessionmaker(bind=engine)

Base = declarative_base()

class Usuarios(Base):
    __tablename__ = "usuarios"
    id_usr = Column(Integer, primary_key=True, index=True)
    usuario = Column(String(50), nullable=False, unique=True)
    nombre = Column(String(100), nullable=False)
    passwo = Column(String(100), nullable=False)
    transporte = Column(String(50), nullable=True)
    rol = Column(Enum("admin", "agente", name="rol_enum"), default='agente', nullable=False)

class Paquetes(Base):
    __tablename__ = "paquetes"
    id_pac = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(150), nullable=False)
    descripcion = Column(String(255), nullable=False)
    direc = Column(String(255), nullable=False)
    estatus = Column(Enum("POR ENTREGAR", "ENTREGADO", name="estatus_enum"), nullable=False, default="POR ENTREGAR")
    id_usr = Column(Integer, ForeignKey("usuarios.id_usr"), nullable=False)

    usr = relationship("Usuarios")


class Ubicaciones(Base):
    __tablename__ = "ubicaciones"
    id_ubi = Column(Integer, primary_key=True, index=True)
    latitud = Column( DECIMAL(10, 8), nullable=False)
    longitud = Column(DECIMAL(11, 8), nullable=False)
    ubi_gps = Column(String(500), nullable=False)
    foto = Column(String(255), nullable=False)

class Entrega(Base):
    __tablename__ = "entrega"
    id_ent = Column(Integer, primary_key=True, index=True)
    fecha = Column(TIMESTAMP, default=datetime.utcnow)
    id_pac = Column(Integer, ForeignKey("paquetes.id_pac"))
    id_ubi = Column(Integer, ForeignKey("ubicaciones.id_ubi"))
    pacq = relationship("Paquetes")
    ubi = relationship("Ubicaciones")

Base.metadata.create_all(bind=engine)

class UsuarioSchema(BaseModel):
    usuario: str
    nombre: str
    passwo: str
    transporte: str | None = None
    rol: str | None = None

class UsuarioOut(UsuarioSchema):
    id_usr: int 

    class Config:
        orm_mode = True

class PaquetesSchema(BaseModel):
    nombre: str
    descripcion: str
    direc: str
    id_usr: int


class PaquetesOut(PaquetesSchema):
    id_pac: int
    estatus: str 

    class Config:
        orm_mode = True

class UbicacionesSchema(BaseModel):
    latitud: float
    longitud: float
    ubi_gps: str

class UbicacionesOut(UbicacionesSchema):
    id_ubi: int
    foto: str

    class Config:
        orm_mode = True

class EntregaSchema(BaseModel):
    # foto: str
    pass

class EntregaOut(EntregaSchema):
    id_ent: int
    fecha: Optional[datetime]
    id_pac: int
    id_ubi:int

    class Config:
        orm_mode = True


class LoginModel(BaseModel):
    usuario: str
    passwo: str


class EntregaDetalleOut(BaseModel):
    id_ent: int
    fecha: Optional[datetime]
    id_pac: int
    nombre_paquete: str
    descripcion_paquete: str
    direccion_paquete: str
    estatus_paquete: str
    id_usr: int
    id_ubi: int
    latitud: float
    longitud: float
    ubi_gps: str
    foto: str

    class Config:
        orm_mode = True

# dependecia DB
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Función para encriptar contraseñas con MD5
def md5_hash(passwo: str) -> str:
    return hashlib.md5(passwo.encode()).hexdigest()


#   Creacion de edpoints
#Endpoint: Registro de usuario
@app.post("/registro")
def register(data: UsuarioSchema, db=Depends(get_db)):
    hashed_pw = md5_hash(data.passwo) #Encriptación con MD5
    user = Usuarios(
        usuario=data.usuario,
        nombre=data.nombre,
        passwo= hashed_pw,
        transporte=data.transporte,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return {"msg": "Usuario registrado", "id_usr": user.id_usr, "rol": user.rol}

#Endpoint: Login de usuario
@app.post("/login/")
def login(data: LoginModel, db=Depends(get_db)):
    user = db.query(Usuarios).filter(Usuarios.usuario == data.usuario).first()
    if not user or user.passwo != md5_hash(data.passwo):
        raise HTTPException(status_code=400, detail="Credenciales inválidas")
    return {"msg": "Login exitoso", "id_usr": user.id_usr, "rol": user.rol}



# Agregar usuario
@app.post("/usuario/", response_model=UsuarioOut)
def crear_usuario(datos: UsuarioSchema, db: Session = Depends(get_db)):
    nuevo = Usuarios(**datos.dict())
    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)
    return nuevo

@app.get("/usuario/", response_model=List[UsuarioOut])
def listar_usuarios(db: Session = Depends(get_db)):
    usuariosobtenido = db.query(Usuarios).all()
    return usuariosobtenido

#Agregar entrega
@app.post("/paquetes/", response_model=PaquetesOut)
def crear_paquete(datos: PaquetesSchema, db: Session = Depends(get_db)):
    nuevo = Paquetes(**datos.dict())
    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)
    return nuevo

#Listar paquetes
@app.get("/paquetes/", response_model=List[PaquetesOut])
def listar_paquetes(db: Session = Depends(get_db)):
    paqueteobtenido = db.query(Paquetes).all()
    return paqueteobtenido

@app.get("/paquetes/asignados/{agente_id}", response_model=List[PaquetesOut])
def listar_paquetes_asignados(agente_id: int, db: Session = Depends(get_db)):
    paquetes = db.query(Paquetes).filter(
        Paquetes.id_usr == agente_id,
        Paquetes.estatus == "POR ENTREGAR"
    ).all()
    return paquetes

# Ubicaciones
@app.post("/ubicaciones")
async def ubicaciones(latitud: float = Form(...), longitud: float = Form(...), ubi_gps: str = Form(...), foto: UploadFile = File(...), db=Depends(get_db)):
    try:
        # Consumir API pública de Nominatim con cabecera obligatoria
        url = f"https://nominatim.openstreetmap.org/reverse?format=json&lat={latitud}&lon={longitud}"
        headers = {"User-Agent": "FastAPIApp/1.0"} #Cabecera requerida
        response = requests.get(url, headers=headers)
        direccion = response.json().get("display_name", "Error al obtener dirección")

        os.makedirs("uploads", exist_ok=True)
        ruta = f"uploads/{foto.filename}"
        with open(ruta, "wb") as buffer:
            shutil.copyfileobj(foto.file, buffer)

        # Guardar registro en BD
        ubicacion = Ubicaciones(
            latitud=latitud,
            longitud=longitud,
            ubi_gps=ubi_gps,
            foto =ruta
        )
        db.add(ubicacion)
        db.commit()
        db.refresh(ubicacion)
        return{
            "msg": "Registro guardado",
            "id_ubi": ubicacion.id_ubi,
            "ubi_gps": ubicacion.ubi_gps,
            "address": direccion 
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")

#Endpoint: Obtener registros de asistencias 
@app.get("/ubicaciones/lista")
def obtener_ubicaciones(db=Depends(get_db)):
    ubicaciones = db.query(Ubicaciones).all()
    resultado = []
    for a in ubicaciones:
        resultado.append({
            "id_ubi": a.id_ubi,
            "latitud": float(a.latitud),
            "longitud": float(a.longitud),
            "ubi_gps": a.ubi_gps,
            "foto": a.foto
        })
    return resultado

# Entrega
@app.post("/entrega/", response_model=EntregaOut)
async def crear_entrega(id_pac: int = Form(...), id_ubi: int = Form(...), db: Session = Depends(get_db)):
    # Verificar que el paquete exista
    paquete = db.query(Paquetes).filter(Paquetes.id_pac == id_pac).first()
    if not paquete:
        raise HTTPException(status_code=404, detail="Paquete no encontrado")
    
    # Verificar que el paquete esté asignado al agente
    # if paquete.id_usr != id_usr:
    #     raise HTTPException(status_code=403, detail="No puedes entregar este paquete")

    # Verificar estatus
    if paquete.estatus == "ENTREGADO":
        raise HTTPException(status_code=400, detail="Este paquete ya fue entregado")

    # UBICACION GUARDADA
    ubicacion = db.query(Ubicaciones).filter(Ubicaciones.id_ubi == id_ubi).first()
    if not ubicacion:
        raise HTTPException(status_code=404, detail="Ubicación no encontrada")
    

    # Crear registro de entrega
    nueva_entrega = Entrega(
        id_pac=id_pac,
        id_ubi=id_ubi
    )
    db.add(nueva_entrega)
    
    paquete.estatus = "ENTREGADO"
    
    db.commit()
    db.refresh(nueva_entrega)
    return nueva_entrega

@app.post("/fotos/")
async def subir_foto(foto: UploadFile = File(...), descripcion: str = Form(...)):
    os.makedirs("uploads", exist_ok=True)
    ruta = f"uploads/{foto.filename}"
    with open(ruta, "wb") as buffer:
        shutil.copyfileobj(foto.file, buffer)
    return {"foto": {"ruta_foto": ruta}, "descripcion": descripcion}

# Endpoint para listar todas las entregas con detalle
@app.get("/entregas/lista", response_model=List[EntregaDetalleOut])
def listar_entregas(db: Session = Depends(get_db)):
    entregas = db.query(Entrega).all()
    resultado = []

    for e in entregas:
        paquete = e.pacq
        ubicacion = e.ubi
        resultado.append({
            "id_ent": e.id_ent,
            "fecha": e.fecha,
            "id_pac": paquete.id_pac,
            "nombre_paquete": paquete.nombre,
            "descripcion_paquete": paquete.descripcion,
            "direccion_paquete": paquete.direc,
            "estatus_paquete": paquete.estatus,
            "id_usr": paquete.id_usr,
            "id_ubi": ubicacion.id_ubi,
            "latitud": float(ubicacion.latitud),
            "longitud": float(ubicacion.longitud),
            "ubi_gps": ubicacion.ubi_gps,
            "foto": ubicacion.foto
        })
    return resultado