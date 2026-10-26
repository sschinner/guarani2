-- DROP PROCEDURE sp820_crear_comision;

CREATE PROCEDURE "dba".sp820_crear_comision(
	vc_unidad_academica	LIKE	u820_capic_com.unidad_academica,		-- Unidad Académica de Origen del Alumno de Integración
	vg_unidad_academica 	LIKE 	sga_comisiones.unidad_academica,		-- Unidad Académica Destino del Alumno de Integración
	vg_materia 		LIKE 	sga_comisiones.materia,			-- Materia de la Unidad Académica Destino
	vc_capic_comision		LIKE	u820_capic_com.capic_comision,		-- Comisión de Capic a la que se inscribe el alumno
	vg_anio_academico 	LIKE 	sga_comisiones.anio_academico,		-- Año Académico de Cursada
	vg_periodo_lectivo 		LIKE 	sga_comisiones.periodo_lectivo		-- Período Lectivo de Cursada
	);

DEFINE	vg_comision 		LIKE 	u820_capic_com.comision;			-- Comisión que se crea en Guaraní
DEFINE	vg_nombre 		LIKE 	sga_comisiones.nombre;
DEFINE	vg_escala_notas 		LIKE 	sga_comisiones.escala_notas;
DEFINE	vg_insc_habilitada 		LIKE 	sga_comisiones.insc_habilitada;
DEFINE	vg_estado 		LIKE 	sga_comisiones.estado;


BEGIN
-- Seteo variables que voy a utilizar en la insersion a sga_comisiones
	LET vg_nombre 		= vc_capic_comision || "-" || vc_unidad_academica;
	LET vg_insc_habilitada	= "N";
	LET vg_estado		= "A";
	
	-- Selecciono la escala de notas para la comision
	SELECT tm.escala_cursada
		INTO vg_escala_notas
		FROM sga_tipos_materia tm, sga_materias m
		WHERE 	tm.tipo_de_materia 	= m.tipo_de_materia
		AND 	m.materia 	= vg_materia;

-- Verifico que no se encuentre creada la comisión en sga_comisiones
	IF NOT EXISTS (SELECT *
			FROM sga_comisiones 
			WHERE	unidad_academica = vg_unidad_academica
			AND 	materia = vg_materia
			AND 	nombre = vg_nombre) THEN

	-- Se insertan los datos en la tabla sga_comisiones de Guarani
		INSERT INTO sga_comisiones (unidad_academica, materia, anio_academico, periodo_lectivo, nombre, escala_notas, insc_habilitada, estado)
			VALUES (vg_unidad_academica, vg_materia, vg_anio_academico, vg_periodo_lectivo, vg_nombre, vg_escala_notas, vg_insc_habilitada, vg_estado);

	END IF;

-- Seteo variables que voy a utilizar en la insersion a u820_capic_com
	SELECT comision
		INTO vg_comision
		FROM sga_comisiones
		WHERE 	unidad_academica 	= vg_unidad_academica
		AND 	materia 		= vg_materia
		AND	anio_academico 	= vg_anio_academico
		AND	periodo_lectivo	= vg_periodo_lectivo
		AND	nombre		= vg_nombre;

-- Verifico que no se encuentre creada la comisión en u820_capic_com
	IF NOT EXISTS (SELECT * 
			FROM u820_capic_com
			WHERE 	comision = vg_comision
			AND 	unidad_academica = vc_unidad_academica
			AND 	capic_comision = vc_capic_comision) THEN

	-- Se insertan los datos en la tabla u820_capic_com que relaciona las comisiones capic con las de guarani
		INSERT INTO u820_capic_com (comision, unidad_academica, capic_comision)
			VALUES (vg_comision, vc_unidad_academica, vc_capic_comision);
	
	END IF;

END;
END PROCEDURE;