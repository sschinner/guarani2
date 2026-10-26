INSERT INTO dba.mce_estados (entidad, estado, nombre, descripcion) 
	VALUES (1, 'X', 'Tramite Especial', 'Tramite Especial');

INSERT INTO dba.sga_requisitos (requisito, nombre) 
	VALUES ('1023', 'Constancia de reemplazo de diploma carton');

INSERT INTO dba.u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima, tipo_tramite) 
	VALUES ('C', 'P', '1023', 'Constancia de reemplazo de diploma carton', 'Completo', 1, 'X');

INSERT INTO dba.u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima, tipo_tramite) 
	VALUES ('P', 'P', '1023', 'Constancia de reemplazo de diploma carton', 'Completo', 1, 'X');

INSERT INTO dba.u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima, tipo_tramite) 
	VALUES ('R', 'P', '1023', 'Constancia de reemplazo de diploma carton', 'Completo', 1, 'X');

INSERT INTO dba.u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima, tipo_tramite) 
	VALUES ('W', 'P', '1023', 'Constancia de reemplazo de diploma carton', 'Completo', 1, 'X');

UPDATE dba.u820_requisitos_diploma SET tipo_tramite = 'N' WHERE tipo_tramite IS NULL;

INSERT INTO mce_eventos (entidad, evento, nombre, descripcion) 
    VALUES (1, 82052, 'Verificar documentacion', 'Verificar documentacion');

INSERT INTO mce_caminos (entidad, evento, estado, nuevo_estado) 
    VALUES (1, 82052, 'D', 'X');

INSERT INTO mce_eventos_activ values (1, 8205, 82052);