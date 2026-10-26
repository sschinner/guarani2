DROP PROCEDURE "dba".sp820_ranking_insc_cur1;
CREATE PROCEDURE "dba".sp820_ranking_insc_cur1( pComision LIKE sga_comisiones.comision, pEstado char(1)) RETURNING
		integer,			-- comision
		varchar(5),		-- carrera
		varchar(60),		-- nombre carrera
		varchar(5),		-- materia
		varchar(60),		-- nombre materia
		varchar(15),		-- legajo
		varchar(30),		-- apellido
		varchar(30),		-- nombres
		integer,			-- aprobadas
		integer,			-- aplazadas
		date			-- fecha_inscripcion	

	-- vars para el manejo de excepciones
	DEFINE 		SQLErr ,ISAMError	integer;
	DEFINE 		errorInfo 		varchar(76);

	DEFINE	v_comision		integer;
	DEFINE	v_carrera			varchar(5);
	DEFINE	v_nombre_carrera		varchar(60);
	DEFINE	v_materia			varchar(5);
	DEFINE	v_nombre_materia		varchar(60);
	DEFINE	v_legajo			varchar(15);
	DEFINE	v_apellido		varchar(30);
	DEFINE	v_nombres		varchar(30);
	DEFINE	v_aprobadas		integer;
	DEFINE	v_aplazadas		integer;
	DEFINE	v_fecha_inscripcion		date;
             DEFINE	v_plan			varchar(5);
	DEFINE	v_version			varchar(5);
              DEFINE 	aprobadas INTEGER;
              DEFINE 	aplazadas INTEGER;
		


	-- si hay algun error
	ON EXCEPTION SET SQLErr, ISAMError, errorInfo
		RAISE EXCEPTION  SQLErr, SQLErr, errorInfo ;
	END EXCEPTION;

	BEGIN
   
		SELECT  i.carrera,
			i.plan,
			i.comision,
			i.legajo,
			car.nombre as nombre_carrera,
			c.materia,
			a.nro_inscripcion	
		FROM sga_insc_cursadas i
			JOIN sga_carreras car
			  ON i.carrera = car.carrera
			JOIN sga_comisiones c
			  ON i.comision = c.comision
			JOIN sga_alumnos a
			  ON i.legajo = a.legajo
				and i.carrera = a.carrera
		WHERE i.comision = pComision
			and (i.estado = pestado or pestado = 'T')
 --                                         and i.legajo in ('28488481-6', '35127730-4', '29722246-4', '32291221-8', '33502846-5')
		INTO TEMP temporal;

		SELECT  i.*,
			m.nombre as nombre_materia,
			p.apellido,
			p.nombres,
			ca.fecha_inscripcion,
                                          pla.version_actual
		FROM temporal i
			JOIN sga_materias m
			  ON i.materia = m.materia
			JOIN sga_carrera_aspira ca
			  ON i.nro_inscripcion = ca.nro_inscripcion
				and i.carrera = ca.carrera
			JOIN sga_personas p
			  ON i.nro_inscripcion = p.nro_inscripcion
                                          JOIN sga_planes pla
                                            ON pla.carrera = i.carrera and pla.estado = 'V'
		INTO TEMP temporal1;
                         
		FOREACH  
			SELECT i.comision,
				i.carrera,
				i.nombre_carrera,
				i.materia,
				i.nombre_materia,
				i.legajo,
				i.apellido,
				i.nombres,
                                            u820_cuenta_mat_rapido( 'FCE', i.carrera, i.legajo,'A',i.plan, i.version_actual)  as aprobadas,
                                          u820_cuenta_mat_rapido( 'FCE', i.carrera, i.legajo,'R',i.plan, i.version_actual)  as aplazadas,
				i.fecha_inscripcion
			INTO v_comision,
				v_carrera,
				v_nombre_carrera,
				v_materia,
				v_nombre_materia,
				v_legajo,
				v_apellido,
				v_nombres,
				v_aprobadas,
				v_aplazadas,
				v_fecha_inscripcion	
			FROM temporal1 i


			RETURN v_comision,
				v_carrera,
				v_nombre_carrera,
				v_materia,
				v_nombre_materia,
				v_legajo,
				v_apellido,
				v_nombres,
				v_aprobadas,
				v_aplazadas,
				v_fecha_inscripcion	 WITH RESUME ;	
		END FOREACH;
	
		DROP TABLE TEMPORAL;
		DROP TABLE TEMPORAL1;
	END;
END PROCEDURE;
                                                                                          
