DROP PROCEDURE sp_planestu_807ag;
CREATE PROCEDURE sp_planestu_807ag ( p_unidad_academica LIKE sga_atrib_mat_plan.unidad_academica, p_carrera LIKE sga_atrib_mat_plan.carrera, p_plan LIKE sga_atrib_mat_plan.plan,  p_version LIKE sga_atrib_mat_plan.version)

       RETURNING varchar(5),    -- unidad_academica,
                 varchar(5),    -- carrera,
                 varchar(255),  -- nombre_carrera,
                 varchar(5),    -- plan,
                 varchar(5),    -- version,
                 varchar(5),    -- titulo,
                 varchar(255),  -- nombre_titulo,
                 varchar(5),    -- orientacion,
                 varchar(255),  -- nombre_orientacion,
                 varchar(5),    -- materia,
                 varchar(255),  -- nombre_materia,
                 integer,       -- credito,
                 varchar(1),    -- tipo_materia, 
                 integer,       -- anio_de_cursada,
                 varchar(20),   -- periodo_dictado,
                 integer,       -- tope_cr_cursado,
                 integer,       -- tope_cr_reg_vigen,
                 integer,       -- puntaje_requerido,
                 varchar(5),    -- materia_optativa,
                 varchar(255),  -- nombre_materia_opt,
                 varchar(2),    -- indicador,
                 varchar(5),    -- materia_anterior,
                 varchar(1),    -- conector_logico,
                 integer,       -- orden,
                 varchar(1),    -- condicion,
                 varchar(1),    -- condicion_anterior
                 integer,       -- tope_cr_reg,
                 integer,       -- cantidad correlativas,
	 varchar(2);   -- modo de agreso


DEFINE vcunidad_academica   VARCHAR(5);
DEFINE vccarrera            VARCHAR(5);
DEFINE vcnombre_carrera     VARCHAR(255);
DEFINE vcplan               VARCHAR(5);
DEFINE vcversion            VARCHAR(5);
DEFINE vctitulo             VARCHAR(5);
DEFINE vcnombre_titulo      VARCHAR(255);
DEFINE vcorientacion        VARCHAR(5);
DEFINE vcnombre_orientaci   VARCHAR(255);
DEFINE vcmateria            VARCHAR(5);
DEFINE vcnombre_materia     VARCHAR(255);
DEFINE vicredito            INTEGER;
DEFINE vctipo_materia       VARCHAR(1); 
DEFINE vianio_de_cursada    INTEGER;
DEFINE vcperiodo_dictado    VARCHAR(20);
DEFINE vitope_cr_cursado    INTEGER;
DEFINE vitope_cr_reg_vige   INTEGER;
DEFINE vipuntaje_requerid   INTEGER;
DEFINE vcmateria_optativa   VARCHAR(5);
DEFINE vcnombre_materi_op   VARCHAR(255);
DEFINE vcindicador          VARCHAR(2);
DEFINE vcmateria_anterior   VARCHAR(5);
DEFINE vcconector_logico    VARCHAR(1);
DEFINE viorden              INTEGER;
DEFINE vccondicion          VARCHAR(1);
DEFINE vccondicion_anteri   VARCHAR(1);
DEFINE vitope_cr_reg2       INTEGER;
DEFINE vicant_correla       INTEGER;
DEFINE vcegreso       VARCHAR(2);

begin
on exception in (-206)
-- 	tabla no existe
end exception with resume;
drop table  tmp_plan_estudio;
drop table  tmp_plan_estudio2;
DROP TABLE tmp_plan_estudio3;

end;
-- recupero informacion de materias normales
SELECT DISTINCT sga_atrib_mat_plan.unidad_academica,
                sga_atrib_mat_plan.carrera,
                sga_carreras.nombre nombre_carrera,
                sga_atrib_mat_plan.plan,
		sga_atrib_mat_plan.version,
		sga_orientaciones.titulo,
		sga_titulos.nombre nombre_titulo,
		sga_orientaciones.orientacion, 
		sga_orientaciones.nombre nombre_orientacion,
		sga_atrib_mat_plan.materia,
		sga_atrib_mat_plan.nombre_materia,
		sga_atrib_mat_plan.credito,
		sga_materias.tipo_materia,
		sga_atrib_mat_plan.anio_de_cursada,
		sga_atrib_mat_plan.periodo_dictado,
		sga_planes.tope_cr_cursado,
		sga_planes.tope_cr_reg_vigen,
		sga_materias.puntaje_requerido,
		sga_atrib_mat_plan.materia materia_optativa,
		sga_atrib_mat_plan.nombre_materia nombre_materia_opt,
		'MN' indicador
	   FROM sga_atrib_mat_plan,
		sga_planes,
		sga_materias_ciclo,
		sga_ciclos_orient,
		sga_carreras,
		sga_materias,
		sga_titulos,
		sga_orientaciones
	 WHERE sga_atrib_mat_plan.unidad_academica = p_unidad_academica
		AND sga_atrib_mat_plan.carrera = p_carrera
		AND sga_atrib_mat_plan.plan = p_plan
		AND sga_atrib_mat_plan.version = p_version
		AND sga_atrib_mat_plan.sale_listado = 'S'
		AND sga_atrib_mat_plan.unidad_academica = sga_planes.unidad_academica
		AND sga_atrib_mat_plan.carrera = sga_planes.carrera
		AND sga_atrib_mat_plan.plan = sga_planes.plan
		AND sga_atrib_mat_plan.unidad_academica = sga_materias_ciclo.unidad_academica
		AND sga_atrib_mat_plan.materia = sga_materias_ciclo.materia
		AND sga_materias_ciclo.unidad_academica = sga_ciclos_orient.unidad_academica
		AND sga_atrib_mat_plan.carrera = sga_ciclos_orient.carrera
		AND sga_atrib_mat_plan.plan = sga_ciclos_orient.plan
		AND sga_atrib_mat_plan.version = sga_ciclos_orient.version
		AND sga_materias_ciclo.ciclo = sga_ciclos_orient.ciclo
		AND sga_ciclos_orient.orientacion = '0'
		AND sga_atrib_mat_plan.unidad_academica = sga_carreras.unidad_academica
		AND sga_atrib_mat_plan.carrera = sga_carreras.carrera
		AND sga_atrib_mat_plan.unidad_academica = sga_materias.unidad_academica
		AND sga_atrib_mat_plan.materia = sga_materias.materia
		AND sga_ciclos_orient.unidad_academica = sga_titulos.unidad_academica
		AND sga_ciclos_orient.titulo = sga_titulos.titulo

-- aca deberìa corregirse
--		AND sga_ciclos_orient.unidad_academica = sga_orientaciones.unidad_academica
--		AND sga_ciclos_orient.titulo = sga_orientaciones.titulo
--		AND sga_ciclos_orient.orientacion = sga_orientaciones.orientacion

		AND sga_ciclos_orient.unidad_academica = sga_orientaciones.unidad_academica
		AND sga_ciclos_orient.carrera= sga_orientaciones.carrera
		AND sga_ciclos_orient.plan=sga_orientaciones.plan
		AND sga_ciclos_orient.titulo = sga_orientaciones.titulo
		AND sga_ciclos_orient.orientacion = sga_orientaciones.orientacion


		AND sga_atrib_mat_plan.tipo_materia='N'

 UNION 
-- recupero informacion de materias normales en orientaciones
SELECT sga_atrib_mat_orie.unidad_academica,
		sga_atrib_mat_orie.carrera,
		sga_carreras.nombre nombre_carrera,
		sga_atrib_mat_orie.plan,
		sga_atrib_mat_orie.version,
		sga_orientaciones.titulo,
		sga_titulos.nombre nombre_titulo,
		sga_orientaciones.orientacion,
		sga_orientaciones.nombre nombre_orientacion,
		sga_atrib_mat_orie.materia,
		sga_atrib_mat_plan.nombre_materia,
		sga_atrib_mat_plan.credito,
		sga_materias.tipo_materia,
		sga_atrib_mat_orie.anio_de_cursada,
		sga_atrib_mat_orie.periodo_dictado,
		sga_planes.tope_cr_cursado,
		sga_planes.tope_cr_reg_vigen,
		sga_materias.puntaje_requerido,
		sga_atrib_mat_plan.materia materia_optativa,
		sga_atrib_mat_plan.nombre_materia nombre_materia_opt,
		'MN' indicador
          FROM sga_atrib_mat_orie,
		sga_atrib_mat_plan,
		sga_planes,
		sga_carreras,
		sga_orientaciones,
		sga_titulos,
		sga_materias
	 WHERE sga_atrib_mat_orie.unidad_academica = sga_carreras.unidad_academica
		AND sga_atrib_mat_orie.carrera = sga_carreras.carrera
		AND sga_atrib_mat_orie.unidad_academica = sga_atrib_mat_plan.unidad_academica
		AND sga_atrib_mat_orie.carrera = sga_atrib_mat_plan.carrera
		AND sga_atrib_mat_orie.plan = sga_atrib_mat_plan.plan
		AND sga_atrib_mat_orie.version = sga_atrib_mat_plan.version
		AND sga_atrib_mat_orie.materia = sga_atrib_mat_plan.materia
		AND sga_atrib_mat_orie.unidad_academica = p_unidad_academica
		AND sga_atrib_mat_orie.carrera = p_carrera
		AND sga_atrib_mat_orie.plan = p_plan
		AND sga_atrib_mat_orie.version = p_version
		AND sga_atrib_mat_plan.unidad_academica = sga_planes.unidad_academica
		AND sga_atrib_mat_plan.carrera = sga_planes.carrera
		AND sga_atrib_mat_plan.plan = sga_planes.plan
		AND sga_atrib_mat_plan.sale_listado = 'S'
		AND sga_atrib_mat_plan.unidad_academica = sga_materias.unidad_academica
		AND sga_atrib_mat_plan.materia = sga_materias.materia
		AND sga_atrib_mat_orie.unidad_academica = sga_orientaciones.unidad_academica
		AND sga_atrib_mat_orie.carrera = sga_orientaciones.carrera
		AND sga_atrib_mat_orie.plan = sga_orientaciones.plan
		AND sga_atrib_mat_orie.orientacion = sga_orientaciones.orientacion
		AND sga_orientaciones.unidad_academica = sga_titulos.unidad_academica
		AND sga_orientaciones.titulo = sga_titulos.titulo
		AND sga_orientaciones.orientacion <> '0'
		AND sga_atrib_mat_plan.tipo_materia='N'

UNION
-- recupero informacion de materias genericas
SELECT DISTINCT sga_atrib_mat_plan.unidad_academica,
		sga_atrib_mat_plan.carrera,
		sga_carreras.nombre nombre_carrera,
		sga_atrib_mat_plan.plan,
		sga_atrib_mat_plan.version,
		sga_orientaciones.titulo,
		sga_titulos.nombre nombre_titulo,
		sga_orientaciones.orientacion,
		sga_orientaciones.nombre nombre_orientacion,
		sga_atrib_mat_plan.materia,
		sga_atrib_mat_plan.nombre_materia,
		sga_atrib_mat_plan.credito,
		sga_materias.tipo_materia, 
		sga_atrib_mat_plan.anio_de_cursada,
		sga_atrib_mat_plan.periodo_dictado,
		sga_planes.tope_cr_cursado,
		sga_planes.tope_cr_reg_vigen,
		sga_materias.puntaje_requerido,
		' ' materia_optativa,
		sga_atrib_mat_plan.nombre_materia nombre_materia_opt,
		'MG' indicador
	FROM sga_atrib_mat_plan,
		sga_planes,
		sga_materias_ciclo,
		sga_ciclos_orient,
		sga_carreras,
		sga_materias,
		sga_titulos,
		sga_orientaciones
	WHERE sga_atrib_mat_plan.unidad_academica = p_unidad_academica
		AND sga_atrib_mat_plan.carrera = p_carrera
		AND sga_atrib_mat_plan.plan = p_plan
		AND sga_atrib_mat_plan.version = p_version
		AND sga_atrib_mat_plan.sale_listado = 'S'
		AND sga_atrib_mat_plan.unidad_academica = sga_planes.unidad_academica
		AND sga_atrib_mat_plan.carrera = sga_planes.carrera
		AND sga_atrib_mat_plan.plan = sga_planes.plan
		AND sga_atrib_mat_plan.unidad_academica = sga_materias_ciclo.unidad_academica
		AND sga_atrib_mat_plan.materia = sga_materias_ciclo.materia
		AND sga_materias_ciclo.unidad_academica = sga_ciclos_orient.unidad_academica
		AND sga_atrib_mat_plan.carrera = sga_ciclos_orient.carrera
		AND sga_atrib_mat_plan.plan = sga_ciclos_orient.plan
		AND sga_atrib_mat_plan.version = sga_ciclos_orient.version
		AND sga_materias_ciclo.ciclo = sga_ciclos_orient.ciclo
		AND sga_ciclos_orient.orientacion = '0'
		AND sga_atrib_mat_plan.unidad_academica = sga_carreras.unidad_academica
		AND sga_atrib_mat_plan.carrera = sga_carreras.carrera
		AND sga_atrib_mat_plan.unidad_academica = sga_materias.unidad_academica
		AND sga_atrib_mat_plan.materia = sga_materias.materia
		AND sga_ciclos_orient.unidad_academica = sga_titulos.unidad_academica
		AND sga_ciclos_orient.titulo = sga_titulos.titulo

-- aca tambien deberìa corregirse
--		AND sga_ciclos_orient.unidad_academica = sga_orientaciones.unidad_academica
--		AND sga_ciclos_orient.titulo = sga_orientaciones.titulo
--		AND sga_ciclos_orient.orientacion = sga_orientaciones.orientacion

		AND sga_ciclos_orient.unidad_academica = sga_orientaciones.unidad_academica
		AND sga_ciclos_orient.carrera= sga_orientaciones.carrera
		AND sga_ciclos_orient.plan=sga_orientaciones.plan
		AND sga_ciclos_orient.titulo = sga_orientaciones.titulo
		AND sga_ciclos_orient.orientacion = sga_orientaciones.orientacion

		AND sga_atrib_mat_plan.tipo_materia='G'

 UNION 

-- recupero informacion de materias genericas en orientaciones
SELECT sga_atrib_mat_orie.unidad_academica,
		sga_atrib_mat_orie.carrera,
		sga_carreras.nombre nombre_carrera,
		sga_atrib_mat_orie.plan,
		sga_atrib_mat_orie.version,
		sga_orientaciones.titulo,
		sga_titulos.nombre nombre_titulo,
		sga_orientaciones.orientacion,
		sga_orientaciones.nombre nombre_orientacion,
		sga_atrib_mat_orie.materia,
		sga_atrib_mat_plan.nombre_materia,
		sga_atrib_mat_plan.credito,
		sga_materias.tipo_materia,
		sga_atrib_mat_orie.anio_de_cursada,
		sga_atrib_mat_orie.periodo_dictado,
		sga_planes.tope_cr_cursado,
		sga_planes.tope_cr_reg_vigen,
		sga_materias.puntaje_requerido,
		' ' materia_optativa,
		sga_atrib_mat_plan.nombre_materia nombre_materia_opt,
		'MG' indicador
	FROM sga_atrib_mat_orie,
		sga_atrib_mat_plan,
		sga_planes,
		sga_carreras,
		sga_orientaciones,
		sga_titulos,
		sga_materias
	WHERE sga_atrib_mat_orie.unidad_academica = sga_carreras.unidad_academica
		AND sga_atrib_mat_orie.carrera = sga_carreras.carrera
		AND sga_atrib_mat_orie.unidad_academica = sga_atrib_mat_plan.unidad_academica
		AND sga_atrib_mat_orie.carrera = sga_atrib_mat_plan.carrera
		AND sga_atrib_mat_orie.plan = sga_atrib_mat_plan.plan
		AND sga_atrib_mat_orie.version = sga_atrib_mat_plan.version
		AND sga_atrib_mat_orie.materia = sga_atrib_mat_plan.materia
		AND sga_atrib_mat_orie.unidad_academica = p_unidad_academica
		AND sga_atrib_mat_orie.carrera = p_carrera
		AND sga_atrib_mat_orie.plan = p_plan
		AND sga_atrib_mat_orie.version = p_version
		AND sga_atrib_mat_plan.unidad_academica = sga_planes.unidad_academica
		AND sga_atrib_mat_plan.carrera = sga_planes.carrera
		AND sga_atrib_mat_plan.plan = sga_planes.plan
		AND sga_atrib_mat_plan.sale_listado = 'S'
		AND sga_atrib_mat_plan.unidad_academica = sga_materias.unidad_academica
		AND sga_atrib_mat_plan.materia = sga_materias.materia
		AND sga_atrib_mat_orie.unidad_academica = sga_orientaciones.unidad_academica
		AND sga_atrib_mat_orie.carrera = sga_orientaciones.carrera
		AND sga_atrib_mat_orie.plan = sga_orientaciones.plan
		AND sga_atrib_mat_orie.orientacion = sga_orientaciones.orientacion
		AND sga_orientaciones.unidad_academica = sga_titulos.unidad_academica
		AND sga_orientaciones.titulo = sga_titulos.titulo
		AND sga_orientaciones.orientacion <> '0'
		AND sga_atrib_mat_plan.tipo_materia='G'


UNION
-- recupero la informacion optativas de las genericas
SELECT DISTINCT sga_atrib_mat_plan.unidad_academica,
                sga_atrib_mat_plan.carrera,
                sga_carreras.nombre nombre_carrera,
                sga_atrib_mat_plan.plan, 
		sga_atrib_mat_plan.version,
		sga_orientaciones.titulo,
		sga_titulos.nombre nombre_titulo,
		sga_orientaciones.orientacion, 
		sga_orientaciones.nombre nombre_orientacion,
		sga_atrib_mat_plan.materia,
		sga_atrib_mat_plan.nombre_materia,
		samp.credito,
		sga_materias.tipo_materia,
		sga_atrib_mat_plan.anio_de_cursada,
		sga_atrib_mat_plan.periodo_dictado,
		sga_materias.puntaje_requerido,
		sga_mat_genericas.valor_materia,
		sga_materias.puntaje_requerido,
		sga_mat_genericas.materia_optativa,
		mat2.nombre nombre_materia_opt,
		'MA' indicador
	   FROM sga_atrib_mat_plan,
	        sga_materias_ciclo,
	        sga_ciclos_orient,
	        sga_carreras,
	        sga_materias,
	        sga_titulos,
	        sga_orientaciones,
	        sga_mat_genericas,
	        sga_materias mat2,
		sga_atrib_mat_plan samp
          WHERE sga_atrib_mat_plan.unidad_academica = p_unidad_academica
		AND sga_atrib_mat_plan.carrera = p_carrera
		AND sga_atrib_mat_plan.plan = p_plan
		AND sga_atrib_mat_plan.version = p_version
		AND sga_atrib_mat_plan.sale_listado = 'S'
		AND sga_atrib_mat_plan.unidad_academica = sga_materias_ciclo.unidad_academica
		AND sga_atrib_mat_plan.materia = sga_materias_ciclo.materia
		AND sga_materias_ciclo.unidad_academica = sga_ciclos_orient.unidad_academica
		AND sga_atrib_mat_plan.carrera = sga_ciclos_orient.carrera
		AND sga_atrib_mat_plan.plan = sga_ciclos_orient.plan
		AND sga_atrib_mat_plan.version = sga_ciclos_orient.version
		AND sga_materias_ciclo.ciclo = sga_ciclos_orient.ciclo
		AND sga_atrib_mat_plan.unidad_academica = sga_carreras.unidad_academica
		AND sga_atrib_mat_plan.carrera = sga_carreras.carrera
		AND sga_atrib_mat_plan.unidad_academica = sga_materias.unidad_academica
		AND sga_atrib_mat_plan.materia = sga_materias.materia
		AND sga_ciclos_orient.unidad_academica = sga_titulos.unidad_academica
		AND sga_ciclos_orient.titulo = sga_titulos.titulo

-- aca tambien podría corregirse
--		AND sga_ciclos_orient.unidad_academica = sga_orientaciones.unidad_academica
--		AND sga_ciclos_orient.titulo = sga_orientaciones.titulo
--		AND sga_ciclos_orient.orientacion = sga_orientaciones.orientacion

		AND sga_ciclos_orient.unidad_academica = sga_orientaciones.unidad_academica
		AND sga_ciclos_orient.carrera= sga_orientaciones.carrera
		AND sga_ciclos_orient.plan=sga_orientaciones.plan
		AND sga_ciclos_orient.titulo = sga_orientaciones.titulo
		AND sga_ciclos_orient.orientacion = sga_orientaciones.orientacion

		AND sga_materias.unidad_academica =  sga_mat_genericas.unidad_academica
		AND sga_materias.materia = sga_mat_genericas.materia_generica
		AND mat2.unidad_academica = sga_mat_genericas.unidad_academica
		AND mat2.materia = sga_mat_genericas.materia_optativa
		AND samp.unidad_academica= sga_atrib_mat_plan.unidad_academica
		AND samp.carrera  = sga_atrib_mat_plan.carrera
		AND samp.plan = sga_atrib_mat_plan.plan
		AND samp.version = sga_atrib_mat_plan.version
		AND samp.materia = sga_mat_genericas.materia_optativa
--		AND samp.periodo_dictado is not null

UNION

-- recupero la informacion de las optativas de las genericas
SELECT DISTINCT sga_atrib_mat_plan.unidad_academica,
		sga_atrib_mat_plan.carrera,
		sga_carreras.nombre nombre_carrera,
		sga_atrib_mat_plan.plan, 
		sga_atrib_mat_plan.version, 
		sga_orientaciones.titulo, 
		sga_titulos.nombre nombre_titulo,
		sga_orientaciones.orientacion,
		sga_orientaciones.nombre nombre_orientacion,
		sga_atrib_mat_plan.materia,
		sga_atrib_mat_plan.nombre_materia,
		sga_atrib_mat_plan.credito,
		sga_materias.tipo_materia,
		sga_atrib_mat_plan.anio_de_cursada,
		sga_atrib_mat_plan.periodo_dictado,
		sga_materias.puntaje_requerido,
		sga_mat_genericas.valor_materia,
		sga_materias.puntaje_requerido,
		sga_mat_genericas.materia_optativa,
		mat2.nombre nombre_materia_opt,
		'MA' indicador
	FROM sga_atrib_mat_plan,
		sga_materias_ciclo,
		sga_ciclos_orient,
		sga_carreras,
		sga_materias,
		sga_titulos,
		sga_orientaciones,
		sga_mat_genericas,
		sga_materias mat2,
		sga_atrib_mat_orie samp
	WHERE sga_atrib_mat_plan.unidad_academica = p_unidad_academica
		AND sga_atrib_mat_plan.carrera = p_carrera
		AND sga_atrib_mat_plan.plan = p_plan
		AND sga_atrib_mat_plan.version = p_version
		AND sga_atrib_mat_plan.sale_listado = 'S'
		AND sga_atrib_mat_plan.unidad_academica = sga_materias_ciclo.unidad_academica
		AND sga_atrib_mat_plan.materia = sga_materias_ciclo.materia
		AND sga_materias_ciclo.unidad_academica = sga_ciclos_orient.unidad_academica
		AND sga_atrib_mat_plan.carrera = sga_ciclos_orient.carrera
		AND sga_atrib_mat_plan.plan = sga_ciclos_orient.plan
		AND sga_atrib_mat_plan.version = sga_ciclos_orient.version
		AND sga_materias_ciclo.ciclo = sga_ciclos_orient.ciclo
		AND sga_atrib_mat_plan.unidad_academica = sga_carreras.unidad_academica
		AND sga_atrib_mat_plan.carrera = sga_carreras.carrera
		AND sga_atrib_mat_plan.unidad_academica = sga_materias.unidad_academica
		AND sga_atrib_mat_plan.materia = sga_materias.materia
		AND sga_ciclos_orient.unidad_academica = sga_titulos.unidad_academica
		AND sga_ciclos_orient.titulo = sga_titulos.titulo

-- aca tambien debería corregirse
--		AND sga_ciclos_orient.unidad_academica = sga_orientaciones.unidad_academica
--		AND sga_ciclos_orient.titulo = sga_orientaciones.titulo
--		AND sga_ciclos_orient.orientacion = sga_orientaciones.orientacion

		AND sga_ciclos_orient.unidad_academica = sga_orientaciones.unidad_academica
		AND sga_ciclos_orient.carrera= sga_orientaciones.carrera
		AND sga_ciclos_orient.plan=sga_orientaciones.plan
		AND sga_ciclos_orient.titulo = sga_orientaciones.titulo
		AND sga_ciclos_orient.orientacion = sga_orientaciones.orientacion

		AND sga_materias.unidad_academica =  sga_mat_genericas.unidad_academica
		AND sga_materias.materia = sga_mat_genericas.materia_generica
		AND mat2.unidad_academica = sga_mat_genericas.unidad_academica
		AND mat2.materia = sga_mat_genericas.materia_optativa
		AND samp.unidad_academica= sga_atrib_mat_plan.unidad_academica
		AND samp.carrera  = sga_atrib_mat_plan.carrera
		AND samp.plan = sga_atrib_mat_plan.plan
		AND samp.version = sga_atrib_mat_plan.version
		AND samp.materia = sga_mat_genericas.materia_optativa
into temp tmp_plan_estudio with no log;

-- recupero las correlativas de todas las materias anteriores
SELECT tmp_plan_estudio.unidad_academica,
		tmp_plan_estudio.carrera,
		tmp_plan_estudio.nombre_carrera,
		tmp_plan_estudio.plan,
		tmp_plan_estudio.version,
		tmp_plan_estudio.titulo,
		tmp_plan_estudio.nombre_titulo,
		tmp_plan_estudio.orientacion,
		tmp_plan_estudio.nombre_orientacion,
		tmp_plan_estudio.materia,
		tmp_plan_estudio.nombre_materia,
		tmp_plan_estudio.credito,
		tmp_plan_estudio.tipo_materia, 
		tmp_plan_estudio.anio_de_cursada,
		tmp_plan_estudio.periodo_dictado,
		tmp_plan_estudio.tope_cr_cursado,
		tmp_plan_estudio.tope_cr_reg_vigen,
		tmp_plan_estudio.puntaje_requerido,
		tmp_plan_estudio.materia_optativa,
		samp.nombre_materia nombre_materia_opt,
		'Co' indicador,
		sga_correlativas.materia_anterior,
		sga_correlativas.conector_logico,
		sga_correlativas.orden,
		sga_correlativas.condicion,
		sga_correlativas.condicion_anterior,
		0 credreg,
		0 cantcorr
	from tmp_plan_estudio, sga_correlativas, sga_atrib_mat_plan samp
	where sga_correlativas.unidad_academica = tmp_plan_estudio.unidad_academica AND   
		sga_correlativas.carrera = tmp_plan_estudio.carrera AND
		sga_correlativas.plan = tmp_plan_estudio.plan AND   
		sga_correlativas.version = tmp_plan_estudio.version AND
		sga_correlativas.materia = tmp_plan_estudio.materia_optativa AND 
		sga_correlativas.unidad_academica = samp.unidad_academica AND   
		sga_correlativas.carrera = samp.carrera AND
		sga_correlativas.plan = samp.plan AND   
		sga_correlativas.version = samp.version AND
		sga_correlativas.materia_anterior = samp.materia 
into temp  tmp_plan_estudio2 with no log;

-- recupero las correlativas especiales de todas las materias anteriores
insert into tmp_plan_estudio2
SELECT tmp_plan_estudio.unidad_academica,
		tmp_plan_estudio.carrera,
		tmp_plan_estudio.nombre_carrera,
		tmp_plan_estudio.plan,
		tmp_plan_estudio.version,
		tmp_plan_estudio.titulo,
		tmp_plan_estudio.nombre_titulo,
		tmp_plan_estudio.orientacion,
		tmp_plan_estudio.nombre_orientacion,
		tmp_plan_estudio.materia,
		tmp_plan_estudio.nombre_materia,
		tmp_plan_estudio.credito,
		tmp_plan_estudio.tipo_materia, 
		tmp_plan_estudio.anio_de_cursada,
		tmp_plan_estudio.periodo_dictado,
		tmp_plan_estudio.tope_cr_cursado,
		tmp_plan_estudio.tope_cr_reg_vigen,
		tmp_plan_estudio.puntaje_requerido,
		tmp_plan_estudio.materia_optativa,
		sga_correlativ_esp.descripcion nombre_materia_opt,
		'Co' indicador,
		'CoEsp',
		'',
		100,
		sga_correlativ_esp.cursar_aprobar,
		'E',
		0 credreg,
		0 cantcorr
	from tmp_plan_estudio, sga_correlativ_esp
	where sga_correlativ_esp.unidad_academica = tmp_plan_estudio.unidad_academica AND   
		sga_correlativ_esp.carrera = tmp_plan_estudio.carrera AND
		sga_correlativ_esp.plan = tmp_plan_estudio.plan AND   
		sga_correlativ_esp.version = tmp_plan_estudio.version AND
		sga_correlativ_esp.materia = tmp_plan_estudio.materia_optativa;

-- mezclo todo lo anterior
insert into tmp_plan_estudio2 (unidad_academica, carrera, nombre_carrera, plan, version, titulo, nombre_titulo, orientacion, nombre_orientacion,  materia, nombre_materia, credito, tipo_materia, 
 anio_de_cursada, periodo_dictado, tope_cr_cursado, tope_cr_reg_vigen, puntaje_requerido, materia_optativa, nombre_materia_opt, indicador)
select * from tmp_plan_estudio;

-- actualizo los creditos por plan
-- update tmp_plan_estudio2 set credreg=(select tope_cr_reg_vigen from sga_planes where unidad_academica=p_unidad_academica and carrera=p_carrera and plan=p_plan);

select tope_cr_reg_vigen 
	into vitope_cr_reg2
	from sga_planes 
	where unidad_academica=p_unidad_academica 
		and carrera=p_carrera 
		and plan=p_plan;


-- update tmp_plan_estudio2 set tope_cr_cursado=(select tope_cr_cursado from sga_planes where unidad_academica=p_unidad_academica and carrera=p_carrera and plan=p_plan);

select tope_cr_cursado 
	into vitope_cr_cursado
	from sga_planes 
	where unidad_academica=p_unidad_academica 
		and carrera=p_carrera 
		and plan=p_plan;

-- seteo la cantidad de correlativas que tiene cada materia
foreach
 select titulo, orientacion, materia, materia_optativa, condicion, count(*)
   into vctitulo, vcorientacion, vcmateria, vcmateria_optativa, vccondicion, vicant_correla
   from tmp_plan_estudio2
  where indicador='Co'
  group by titulo, orientacion, materia, materia_optativa, condicion

	update tmp_plan_estudio2 set cantcorr=vicant_correla
		where titulo=vctitulo and
			orientacion=vcorientacion and
			materia=vcmateria and
			materia_optativa=vcmateria_optativa and
			condicion=vccondicion;

end foreach;

-- actualizo el año y periodo de cursada de cada optativa de las genericas y su correlativas
-- se presupone que la genérica tiene el año y periodo y todas las optativas tienen que amoldarse
foreach select distinct orientacion, materia, anio_de_cursada, periodo_dictado
	into vcorientacion, vcmateria, vianio_de_cursada, vcperiodo_dictado
	from tmp_plan_estudio2
	where indicador='MG'

	update tmp_plan_estudio2 set anio_de_cursada= vianio_de_cursada,
				periodo_dictado=vcperiodo_dictado
				where orientacion=vcorientacion and
					materia=vcmateria and
					(indicador='MA' or indicador='Co');

end foreach;

-- recupero los modos de egreso de cada titulo que otorga el plan
SELECT DISTINCT unidad_academica, carrera, plan, titulo, calculo_egreso
	FROM sga_titulos_plan 
	WHERE unidad_academica = p_unidad_academica AND
		carrera = p_carrera AND
		plan = p_plan
into temp tmp_plan_estudio3 with no log;


-- retorno la informacion generada y ordenada
foreach select tpe2.unidad_academica, tpe2.carrera, nombre_carrera, tpe2.plan, version, tpe2.titulo, nombre_titulo, orientacion, nombre_orientacion,  materia, nombre_materia, credito, 
		tipo_materia, anio_de_cursada, periodo_dictado, tope_cr_reg_vigen, puntaje_requerido, materia_optativa, nombre_materia_opt, indicador, 
		materia_anterior, conector_logico, orden, condicion, condicion_anterior, cantcorr, calculo_egreso
	into vcunidad_academica, vccarrera, vcnombre_carrera, vcplan, vcversion, vctitulo, vcnombre_titulo, vcorientacion, vcnombre_orientaci, vcmateria, vcnombre_materia, vicredito, 
		vctipo_materia, vianio_de_cursada, vcperiodo_dictado, vitope_cr_reg_vige, vipuntaje_requerid, vcmateria_optativa, vcnombre_materi_op, vcindicador, 
		vcmateria_anterior, vcconector_logico, viorden, vccondicion, vccondicion_anteri, vicant_correla, vcegreso
	from tmp_plan_estudio2 tpe2, tmp_plan_estudio3 tpe3
	where tpe2.unidad_academica = tpe3.unidad_academica
		and tpe2.carrera = tpe3.carrera
		and tpe2.plan = tpe3.plan
		and tpe2.titulo = tpe3.titulo
	ORDER BY tpe2.titulo, orientacion, anio_de_cursada, periodo_dictado, materia, materia_optativa, indicador desc, condicion desc, orden 

	return vcunidad_academica, vccarrera, vcnombre_carrera, vcplan, vcversion, vctitulo, vcnombre_titulo, vcorientacion, vcnombre_orientaci, vcmateria, vcnombre_materia, vicredito, 
		vctipo_materia, vianio_de_cursada, vcperiodo_dictado, vitope_cr_cursado, vitope_cr_reg_vige, vipuntaje_requerid, vcmateria_optativa, vcnombre_materi_op, vcindicador, 
		vcmateria_anterior, vcconector_logico, viorden, vccondicion, vccondicion_anteri, vitope_cr_reg2, vicant_correla, vcegreso with resume;

end foreach;

DROP TABLE tmp_plan_estudio;
DROP TABLE tmp_plan_estudio2;
DROP TABLE tmp_plan_estudio3;

END PROCEDURE;                                        
