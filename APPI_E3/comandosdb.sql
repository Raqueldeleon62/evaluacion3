CREATE DATABASE logistica;
use logistica;

CREATE Table usuarios(
    id_usr int AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    passwo VARCHAR(100) NOT NULL,
    transporte VARCHAR(50) NULL,
    rol ENUM('admin', 'agente') NOT NULL DEFAULT 'agente'
);

CREATE Table paquetes(
    id_pac int AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    direc VARCHAR(255) NOT NULL,
    estatus ENUM('POR ENTREGAR', 'ENTREGADO') NOT NULL DEFAULT 'POR ENTREGAR',
    id_usr int NOT NULL,

    FOREIGN KEY (id_usr) REFERENCES usuarios(id_usr)
);

CREATE Table ubicaciones(
    id_ubi INT AUTO_INCREMENT PRIMARY KEY,
    latitud DECIMAL(10,8) NOT NULL,
    longitud DECIMAL(11,8) NOT NULL,
    ubi_gps VARCHAR(500)NOT NULL
    foto VARCHAR(255) NOT NULL,
);

CREATE TABLE entrega(
    id_ent INT AUTO_INCREMENT PRIMARY KEY,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_pac INT NULL,
    id_ubi INT NULL,
    FOREIGN KEY (id_pac) REFERENCES paquetes(id_pac),
    FOREIGN KEY (id_ubi) REFERENCES ubicaciones(id_ubi)
);


ALTER TABLE usuarios 
MODIFY COLUMN passwo CHAR(32) NOT NULL;