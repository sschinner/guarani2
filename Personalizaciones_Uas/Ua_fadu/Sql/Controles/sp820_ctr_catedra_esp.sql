CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_ctr_cat_esp') THEN
		DROP PROCEDURE sp820_ctr_cat_esp;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


CREATE PROCEDURE "dba".sp820_ctr_cat_esp ( pUnidadAcademica 	LIKE sga_alumnos.unidad_academica,
					   pCarrera 		LIKE sga_alumnos.carrera,
					   pLegajo  		LIKE sga_alumnos.legajo,
					   pComision 		LIKE sga_comisiones.comision,
						pMateriaCorrelativa LIKE sga_materias.materia,
						pCondRegular integer)
	RETURNING 	smallint,       -- status
			varchar(255);   -- <mensaje, parametros>

  /*  controla el Alumno Cursa Vertical.
       devuelve:  1 - si esta OK            cursa Vertical
             -1 - en otro caso       no cursa Vertical
  */

  -- vars para la respuesta
  DEFINE iStatus 		smallint;	-- status
  DEFINE vcMsg 		varchar(255);	-- mensaje y parametros

  -- var's para el manejo de excepciones
   DEFINE sql_err,isam_err 	integer;
   DEFINE error_info 	varchar(76);

   DEFINE vcUserError	varchar(10);


   -- variables locales

DEFINE vcNro_inscripcion like sga_alumnos.nro_inscripcion;
DEFINE vcCarrera like sga_comisiones.carrera;
DEFINE vcNombre like sga_comisiones.nombre;
DEFINE vcTurno, vcTurnoCurso like sga_comisiones.turno;
DEFINE vcMateria like sga_comisiones.materia;
DEFINE vc_legajo like sga_docentes_com.legajo;

-- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info
     LET iStatus = -1 ;
     LET vcMsg = '800321' || ',' || 'sp820_ctr_cat_esp' || ',' || sql_err || ' - '  || error_info ;  
     RETURN iStatus, vcMsg ;
   END EXCEPTION;        


BEGIN
   -- seteo los valores default
   LET iStatus		= -1 ;
   LET vcMsg		= '82012001';
   LET vcNro_inscripcion = NULL;
   LET vcCarrera = NULL;
   LET vcNombre = NULL;
   LET vcTurno = NULL;
   LET vcMateria = NULL;
   LET vc_legajo = NULL;
   LET vcTurnoCurso = NULL;


-- Se obtiene el docente responsable de la comisión.
SELECT com.carrera, com.nombre, com.turno, com.materia, doc.legajo Into vcCarrera, vcNombre, vcTurno, vcMateria, vc_legajo
   FROM sga_comisiones com
	left join sga_docentes_com doc
	on com.comision = doc.comision
   WHERE com.comision = pComision
	and doc.responsabilidad = 1;

-- Se obtiene la materia
SELECT com.carrera, com.nombre, com.turno, com.materia Into vcCarrera, vcNombre, vcTurno, vcMateria
   FROM sga_comisiones com
   WHERE com.comision = pComision;

-- Si tiene una cursada vigente, de la materia correlativa con el docente equivalente, y en la condición solicitada entoces OK.
-- Docente equivalente: es con quien se empareja el docente de la comision a cursar


IF vc_legajo = '3206' THEN -- Rodriguez
	LET vc_legajo = '2324'; -- Soijet
END IF;



IF EXISTS (Select '*' from sga_det_acta_curs det
		join sga_actas_cursado act
			on det.acta = act.acta
		join sga_comisiones com
			on act.comision = com.comision
		left join sga_docentes_com doc
			on com.comision = doc.comision
	where com.materia = pMateriaCorrelativa
	AND ( 
	(det.fin_vigencia_regul >= today and det.resultado IN('A')) -- Comprobar Vigencia.
		OR
	(det.cond_regularidad = pCondRegular OR (pCondRegular = 0 and det.resultado IN('P'))) -- Condicion
	)

	and det.legajo = plegajo) THEN

	-- Si es recursante
	IF EXISTS (Select '*' from sga_det_acta_curs det
			join sga_actas_cursado act
				on det.acta = act.acta
			join sga_comisiones com
				on act.comision = com.comision
			where com.materia = vcMateria
			and det.legajo = plegajo) THEN 

		-- Si la curso en algun momento, solo permite inscribirse a comisión de libres (sin turno definido)
		IF vc_legajo IS NULL OR   trim (vc_legajo ) = ""  THEN
			LET iStatus  = 1;
			LET vcMsg  =  'OK';
			RETURN iStatus, vcMsg;
		ELSE 
			LET iStatus  = -1;
			LET vcMsg  =  '82012001';
			RETURN iStatus, vcMsg;
		END IF;
	END IF;	


	IF (vc_legajo IN (Select doc.legajo 
		from sga_det_acta_curs det
			join sga_actas_cursado act
				on det.acta = act.acta
			join sga_comisiones com
				on act.comision = com.comision
			left join sga_docentes_com doc
				on com.comision = doc.comision
		where com.materia = pMateriaCorrelativa
		and  ( 
			(det.fin_vigencia_regul >= today and det.resultado IN('A')) -- Comprobar Vigencia.
				OR
			(det.cond_regularidad = pCondRegular OR (pCondRegular = 0 and det.resultado IN('P'))) -- Condicion
		)
		and det.legajo = plegajo
		and doc.responsabilidad = 1
		-- and vcTurno = com.turno )) THEN -- y que sea del mismo turno
		)) THEN


		LET iStatus  = 1; 
		LET vcMsg  = 'OK';

	ELSE -- Si la regularidad esta vigente solo se puede inscribir en la cátedra con la que lo cursó
		LET iStatus  = -1;
		LET vcMsg  =  '82012001';
	END IF;
ELSE 
	-- Si no tiene regularidad en la correlativa, permite inscribirse a comisión de libres (si catedra definida)
	IF vc_legajo IS NULL  THEN
		LET iStatus  = 1;
		LET vcMsg  =  'OK';
	ELSE
		LET iStatus  = -1;
		LET vcMsg  =  '82012001' ;
	END IF;

END IF;

			

RETURN iStatus, vcMsg; 

END;
END PROCEDURE;


-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_ctr_cat_esp
-- *****************************************************************************
revoke execute on "dba".sp820_ctr_cat_esp from public;
grant execute on "dba".sp820_ctr_cat_esp to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_ctr_cat_esp to internet; -- Rol de usuario de Internet


{
Select doc.legajo 
		from sga_det_acta_curs det
			join sga_actas_cursado act
				on det.acta = act.acta
			join sga_comisiones com
				on act.comision = com.comision
			left join sga_docentes_com doc
				on com.comision = doc.comision
		where com.materia = 'D0311'
		and det.fin_vigencia_regul >= today
		and (det.cond_regularidad = 0 OR (0 = 0 and det.resultado IN('P', 'A'))) -- Condicion
		and det.legajo = '29986952-8'
		and doc.responsabilidad = 1

Select '*' from sga_det_acta_curs det
		join sga_actas_cursado act
			on det.acta = act.acta
		join sga_comisiones com
			on act.comision = com.comision
		left join sga_docentes_com doc
			on com.comision = doc.comision
	where com.materia = 'D0305'
	AND ( 
	(det.fin_vigencia_regul >= today and det.resultado IN('A')) -- Comprobar Vigencia.
		OR
	(det.cond_regularidad = 0 OR (0 = 0 and det.resultado IN('P'))) -- Condicion
	)

	and det.legajo = '41866574-6';

Select '*' from sga_det_acta_curs det
			join sga_actas_cursado act
				on det.acta = act.acta
			join sga_comisiones com
				on act.comision = com.comision
			where com.materia = 'D0311'
			and det.legajo = '41866574-6';

Select *
		from sga_det_acta_curs det
			join sga_actas_cursado act
				on det.acta = act.acta
			join sga_comisiones com
				on act.comision = com.comision
			left join sga_docentes_com doc
				on com.comision = doc.comision
		where com.materia = 'D0305'
		and  ( 
			(det.fin_vigencia_regul >= today and det.resultado IN('A')) -- Comprobar Vigencia.
				OR
			(det.cond_regularidad = 0 OR (0 = 0 and det.resultado IN('P'))) -- Condicion
		)
		and det.legajo = '41866574-6'
		and doc.responsabilidad = 1


begin;

set triggers for sga_docentes_com  disabled;
update sga_docentes_com set responsabilidad = 1, legajo = 3407 where comision = 8709 and legajo = 4147;
set triggers for sga_docentes_com  enabled;

commit;
}
