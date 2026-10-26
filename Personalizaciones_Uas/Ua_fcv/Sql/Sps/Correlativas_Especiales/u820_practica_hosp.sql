CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_practica_hosp') THEN
		DROP PROCEDURE u820_practica_hosp;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Execute procedure u820_practica_hosp("FCV", "01", '36913816-3', "10004", 2011, 17) -- esta en condiciones
-- EXECUTE  PROCEDURE sp_opt_gen_puntaje( 'FCV', '01', '36913816-3' ) -- esta en condiciones

-- Execute procedure u820_practica_hosp("FCV", "01", '36490237-3', "10004", 2011, 17) -- esta en condiciones
-- EXECUTE  PROCEDURE sp_opt_gen_puntaje( 'FCV', '01', '36490237-3' ) -- esta en condiciones

-- Execute procedure u820_practica_hosp("FCV", "01", '36054957-2', "10004", 2011, 17) -- no esta en condiciones
-- EXECUTE  PROCEDURE sp_opt_gen_puntaje( 'FCV', '01', '36054957-2' ) -- no esta en condiciones

-- Execute procedure u820_practica_hosp("FCV", "01", '36101259-8', "10004", 2011, 17) -- no esta en condiciones
-- EXECUTE  PROCEDURE sp_opt_gen_puntaje( 'FCV', '01', '36101259-8' ) -- no esta en condiciones


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Ultima modificacion: Version 2.9.2
--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Create procedure "dba".u820_practica_hosp (v_unidad_acad	like sga_alumnos.unidad_academica,
				v_carrera		like sga_alumnos.carrera,
				v_legajo		like sga_alumnos.legajo,
				v_materia		like sga_actas_examen.materia,
				v_plan		like sga_alumnos.plan,
				v_version		like sga_actas_examen.version)
				
		returning smallint, varchar(255);
BEGIN

-- vars para la respuesta

DEFINE iStatus            	smallint;      -- status

DEFINE vcMsg              	varchar(255);  -- mensaje y parametros
DEFINE sql_err, isam_err integer;
DEFINE error_info 			varchar(76);

DEFINE n_puntos_apro integer;

DEFINE ls_materia_opt    LIKE sga_materias.materia;

DEFINE ls_mat_opt_nombre LIKE sga_materias.nombre;
DEFINE ls_result         CHAR(1);
DEFINE li_valor_materia  LIKE sga_mat_genericas.valor_materia;

DEFINE ls_materia_gen    LIKE sga_materias.materia;
DEFINE ls_mat_gen_nombre LIKE sga_materias.nombre;

DEFINE li_requerido      INTEGER;

DEFINE li_puntaje_apr    INTEGER;

DEFINE li_puntaje_reg    INTEGER;

DEFINE ls_plan           LIKE sga_planes.plan;

DEFINE ls_version        LIKE sga_planes.version_actual;

DEFINE ls_nombre         LIKE sga_personas.nombres;

DEFINE ls_apellido       LIKE sga_personas.apellido;

DEFINE ls_nom_carrera    LIKE sga_carreras.nombre;



   -- blk de excepciones

   ON EXCEPTION SET sql_err, isam_err, error_info

      LET iStatus = -1 ;

      LET vcMsg = '800321,' || 'u820_practica_hosp,' || sql_err || ' - '  || error_info ;



      RETURN iStatus, vcMsg;

   END EXCEPTION;



-- seteo los valores default

LET iStatus = 1;

LET vcMsg = '800320';
LET n_puntos_apro = 0;

-- *****************************************************************************
-- Retorna las optativas con su genérica, puntaje requerido de la genérica, las
-- optativas aprobadas y regularizadas. Devuelve datos del alumno, plan y version actual.
-- *****************************************************************************
-- DESCRIPCION DEL RETURN

-- ls_materia_opt,

-- ls_mat_opt_nombre,

-- ls_result,

-- li_valor_materia,

-- ls_materia_gen,

-- ls_mat_gen_nombre,

-- li_requerido,

-- li_puntaje_apr,

-- li_puntaje_reg,

-- ls_plan: plan actual

-- ls_version: version actual del plan del alumno

-- ls_nombre,

-- ls_apellido,

-- ls_nom_carrera,

-- v_carrera,

-- v_Legajo;

FOREACH EXECUTE  PROCEDURE sp_opt_gen_puntaje(v_unidad_acad, v_carrera, v_legajo ) INTO   ls_materia_opt, ls_mat_opt_nombre, ls_result, li_valor_materia, ls_materia_gen, ls_mat_gen_nombre, li_requerido, li_puntaje_apr, li_puntaje_reg, ls_plan, ls_version, ls_nombre, ls_apellido, ls_nom_carrera, v_carrera, v_Legajo

	-- Contabilizar 200 puntos de materias optativas aprobadas o regularizadas. No se cuentan las acreditaciones
	IF ls_materia_gen IN ('12000', '12001', '12002') AND ls_result IN ('A', 'R') THEN
		-- Contar puntos
		LET n_puntos_apro = n_puntos_apro + li_valor_materia;
	END IF;
END FOREACH;

IF n_puntos_apro < 200 THEN
	LET iStatus = -1;
	LET vcMsg = '82002038';
ELSE

END IF;

return iStatus, vcMsg ;
end;
end procedure;

-- ******************** FIN PROCESO u820_practica_hosp ********************

revoke execute on "dba".u820_practica_hosp from public;
grant execute on "dba".u820_practica_hosp to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_practica_hosp to internet; -- Rol de usuario de Internet
