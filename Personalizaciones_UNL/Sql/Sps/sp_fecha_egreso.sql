CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_fecha_egreso') THEN
		DROP PROCEDURE sp_fecha_egreso;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- sp_fecha_egreso
-- Ultima version de Modificacion: 2.01.0, 2.04.0,2.06
--
-- Recupera la fecha de la ultima aprobacion de materia por parte del alumno para un titulo 
-- U820 No se consideran materias Homologadas.
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DROP PROCEDURE "dba".sp_fecha_egreso;
CREATE PROCEDURE "dba".sp_fecha_egreso (pUA		like sga_titulos_otorg.unidad_academica ,
					pCarrera		like sga_titulos_otorg.carrera ,
					pLegajo		like sga_titulos_otorg.legajo ,
					pTitulo		like sga_titulos_otorg.titulo ,
					pPlan		like sga_titulos_otorg.plan,
					pVersion		like sga_titulos_otorg.version,
					pOrientacion	like sga_ciclos_orient.orientacion  )
RETURNING date ;

  DEFINE dFechaEgreso,dFechaEgresoOpt,dFechaAE	DATE;

BEGIN

 LET dFechaEgreso       = to_date('01011900',"%d%m%Y");
 LET dFechaEgresoOpt = to_date('01011900',"%d%m%Y");
 LET dFechaAE =  to_date('01011900',"%d%m%Y");

 -- Aca no recupera la fecha de una materia Optativa de algun ciclo de la orientacion. Porque la materia optativa no existe
 -- en el ciclo, sino existe la materia Generica.
 SELECT MAX(h.fecha)
    INTO dFechaEgreso
    FROM vw_hist_academica h, 
	sga_materias_ciclo m,
	sga_ciclos_orient o 
    WHERE 
	( h.unidad_academica = pUA ) AND
	( h.carrera =  pCarrera ) AND
	( h.legajo = pLegajo ) AND
	( h.resultado = 'A' ) AND
	-- U820 No se consideran materias Homologadas.
	( h.forma_aprobacion <> 'Homologada' ) AND

	( h.unidad_academica = m.unidad_academica ) AND
	( h.materia = m.materia ) AND

	( o.unidad_academica = h.unidad_academica )  AND
	( o.carrera = h.carrera ) AND
	( o.plan = pPlan ) AND
	( o.version = pVersion ) AND
	( o.ciclo = m.ciclo ) AND
	( o.titulo = pTitulo ) AND
	( o.orientacion = pOrientacion )  ;

  IF dFechaEgreso IS NULL THEN
	-- El ciclo solo tiene materias genericas.
	 LET dFechaEgreso   = to_date('01011900',"%d%m%Y");
  END IF;

  -- Recupero la fecha de aprobacion de las materias optativas de las Genericas.. si es que existe alguna.
 SELECT MAX(h.fecha)
    INTO dFechaEgresoOpt
    FROM vw_hist_academica h, 
	sga_mat_genericas mg,
	sga_materias_ciclo m,
	sga_ciclos_orient o 
    WHERE 
	( h.unidad_academica = pUA ) AND
	( h.carrera =  pCarrera ) AND
	( h.legajo = pLegajo ) AND
	( h.resultado = 'A' ) AND
	-- U820 No se consideran materias Homologadas.
	( h.forma_aprobacion <> 'Homologada' ) AND

	( mg.unidad_academica = h.unidad_academica ) AND
	( mg.materia_optativa     = h.materia ) AND    -- La materia que se aprueba es Optativa.

	( m.unidad_academica = mg.unidad_academica ) AND
	( m.materia                    = mg.materia_generica ) AND   -- La materia que existe en los ciclos, es generica.

	( o.unidad_academica = h.unidad_academica )  AND
	( o.carrera  = h.carrera ) AND
	( o.plan       = pPlan ) AND
	( o.version  = pVersion ) AND
	( o.ciclo      = m.ciclo ) AND
	( o.titulo      = pTitulo ) AND
	( o.orientacion = pOrientacion )  ;

  IF dFechaEgresoOpt IS NULL THEN
	 LET dFechaEgresoOpt = to_date('01011900',"%d%m%Y");
  END IF;

  IF dFechaEgresoOpt > dFechaEgreso THEN
	-- La ultima materia que aprobo de la Orientacion, es una materia Optativa.
	LET dFechaEgreso = dFechaEgresoOpt;
  END IF; 

  SELECT MAX(aa.fecha) 
       INTO dFechaAE
     FROM sga_activ_alumno aa, sga_alumnos_resol ar, sga_resol_activ ra
  WHERE aa.unidad_academica = pUA
	AND aa.carrera = pCarrera
	AND aa.legajo  = pLegajo
	AND aa.resol_actividades = ar.resol_actividades
	AND aa.carrera = ar.carrera
	AND aa.legajo = ar.legajo
	AND ar.unidad_academica = ra.unidad_academica 
	AND ar.resol_actividades = ra.resol_actividades
	AND ra.estado = 'C'
	AND aa.area   IN ( SELECT  sga_areas_x_titulo.area
			 FROM sga_areas_x_titulo, sga_atri_area_plan
		              WHERE  	sga_areas_x_titulo.unidad_academica = pUA
			AND 	sga_areas_x_titulo.carrera = pCarrera
			AND 	sga_areas_x_titulo.plan    = pPlan
			AND 	sga_areas_x_titulo.version = pversion
			AND 	sga_areas_x_titulo.titulo  = pTitulo
			AND	sga_areas_x_titulo.unidad_academica = sga_atri_area_plan.unidad_academica
			AND	sga_areas_x_titulo.carrera = sga_atri_area_plan.carrera
			AND	sga_areas_x_titulo.plan    = sga_atri_area_plan.plan
			AND	sga_areas_x_titulo.version = sga_atri_area_plan.version
			AND	sga_areas_x_titulo.area = sga_atri_area_plan.area
			AND	sga_atri_area_plan.obligatoria = 'S' );


  IF dFechaAE > dFechaEgreso THEN
         LET dFechaEgreso = dFechaAE;
  END IF;

  RETURN dFechaEgreso ;
END;
END PROCEDURE;
-- +++++++++++++++++++++++++++++++++++++++ Fin Proceso sp_fecha_egreso ++++++++++++++++++++++++++++

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_fecha_egreso
-- *****************************************************************************
revoke execute on "dba".sp_fecha_egreso from public;
grant execute on "dba".sp_fecha_egreso to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_fecha_egreso to internet; -- Rol de usuario de Internet