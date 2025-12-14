create database zootopia;
use zootopia;

create table region (
idRegion int auto_increment primary key,
nombre varchar (20) not null
);

create table pais (
idPais int auto_increment primary key,
nombrePais varchar (30) not null,
idRegion int,
foreign key (idRegion) references region(idRegion)
);

create table tipo (
idTipo int auto_increment primary key,
nombreTipo varchar (20) not null
);

create table ecosistema (
idEcosistema int auto_increment primary key,
nombreEcosistema varchar (30) not null
);

create table estadoConservacion (
idConservacion int auto_increment primary key,
nombreConservacion varchar (15) not null
);

create table especie (
idEspecie int auto_increment primary key,
nombreCientifico varchar (50),
nombreComun varchar (50),
descripcion text,
idTipo int,
idPais int,
idEcosistema int,
idConservacion int,
foreign key (idTipo) references tipo(idTipo),
foreign key (idPais) references pais(idPais),
foreign key (idEcosistema) references ecosistema(idEcosistema),
foreign key (idConservacion) references estadoConservacion(idConservacion)
);

create table fichaTecnica (
idFicha int auto_increment primary key,
idEspecie int unique,
habitat varchar (70),
dieta varchar (70),
reproduccion varchar (70),
longevidad varchar (70),
comportamiento varchar (100),
foreign key (idEspecie) references especie(idEspecie)
);

create table ejemplar (
idEjemplar int auto_increment primary key,
nombre varchar (50),
sexo char(1),
fechaNacimiento date,
fechaIngreso date,
estadoSalud varchar (70),
idEspecie int,
foreign key (idEspecie) references especie(idEspecie)
);

create table rol (
idRol int auto_increment primary key,
nombreRol varchar (20)
);

create table usuario (
idUsuario int auto_increment primary key,
correo varchar (50),
password varchar (255),
idRol int,
foreign key (idRol) references rol(idRol)
);

create table auditoria (
idAuditoria int auto_increment primary key,
idUsuario int,
accion varchar (50),
tablaAfectada varchar (40),
fecha timestamp default current_timestamp,
descripcionAuditoria text,
foreign key (idUsuario) references usuario(idUsuario)
);

