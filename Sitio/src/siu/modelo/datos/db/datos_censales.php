<?php
namespace siu\modelo\datos\db;
use kernel\kernel;
use kernel\error_kernel_db;
use kernel\util\db\db;
use siu\modelo\entidades;

class datos_censales
{
	
	const tabla_datos_censales		= 'CENS_';
	const tabla_datos_censales_aux	= 'AUX1_';
	const tabla_datos_censales_aux2 = 'AUX2_';
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function get_datos($parametros)
	{	
		
		$tabla_cens = datos_censales::tabla_datos_censales;
		$tabla_aux	= datos_censales::tabla_datos_censales_aux;
		$tabla_aux2 = datos_censales::tabla_datos_censales_aux2;
		
		$sql = "SELECT 
				sga_datos_censales.estado_civil					as {$tabla_cens}estado_civil      ,
				sga_datos_censales.turno_preferido				as {$tabla_cens}turno_preferido   ,
				sga_datos_censales.e_mail						as {$tabla_cens}e_mail            ,
				sga_datos_censales.tipo_visa					as {$tabla_cens}tipo_visa         ,
				sga_datos_censales.otorgamiento_visa			as {$tabla_cens}otorgamiento_visa ,
				sga_datos_censales.vencimiento_visa				as {$tabla_cens}vencimiento_visa  ,
				sga_datos_censales.tipo_residencia				as {$tabla_cens}tipo_residencia   ,
				sga_datos_censales.tipo_res_per_lect			as {$tabla_cens}tipo_res_per_lect ,
				sga_datos_censales.calle_per_lect				as {$tabla_cens}calle_per_lect    ,
				sga_datos_censales.numero_per_lect				as {$tabla_cens}numero_per_lect   ,
				sga_datos_censales.piso_per_lect				as {$tabla_cens}piso_per_lect     ,
				sga_datos_censales.dpto_per_lect				as {$tabla_cens}dpto_per_lect     ,
				sga_datos_censales.unidad_per_lect				as {$tabla_cens}unidad_per_lect   ,
				sga_datos_censales.loc_per_lect					as {$tabla_cens}loc_per_lect      ,
				sga_datos_censales.cp_per_lect					as {$tabla_cens}cp_per_lect       ,
				trim(sga_datos_censales.te_per_lect)			as {$tabla_cens}te_per_lect       ,
				sga_datos_censales.calle_proc					as {$tabla_cens}calle_proc        ,
				sga_datos_censales.numero_proc					as {$tabla_cens}numero_proc       ,
				sga_datos_censales.piso_proc					as {$tabla_cens}piso_proc         ,
				sga_datos_censales.dpto_proc					as {$tabla_cens}dpto_proc         ,
				sga_datos_censales.unidad_proc					as {$tabla_cens}unidad_proc       ,
				sga_datos_censales.loc_proc						as {$tabla_cens}loc_proc          ,
				sga_datos_censales.cp_proc						as {$tabla_cens}cp_proc           ,
				trim(sga_datos_censales.te_proc)				as {$tabla_cens}te_proc           ,
				sga_datos_censales.nombre_pers_alleg			as {$tabla_cens}nombre_pers_alleg ,
				sga_datos_censales.calle_pers_alleg				as {$tabla_cens}calle_pers_alleg  ,
				sga_datos_censales.nro_pers_alleg				as {$tabla_cens}nro_pers_alleg    ,
				sga_datos_censales.piso_pers_alleg				as {$tabla_cens}piso_pers_alleg   ,
				sga_datos_censales.dpto_pers_alleg				as {$tabla_cens}dpto_pers_alleg   ,
				sga_datos_censales.unidad_pers_alleg			as {$tabla_cens}unidad_pers_alleg ,
				sga_datos_censales.loc_pers_alleg				as {$tabla_cens}loc_pers_alleg    ,
				sga_datos_censales.cp_pers_alleg				as {$tabla_cens}cp_pers_alleg     ,
				trim(sga_datos_censales.te_pers_alleg)			as {$tabla_cens}te_pers_alleg     ,
																							  
				
				sga_datos_censales.rel_trab_carrera				as {$tabla_cens}rel_trab_carrera  ,
				sga_datos_censales.ult_est_cur_padre			as {$tabla_cens}ult_est_cur_padre ,
				sga_datos_censales.sit_laboral_padre			as {$tabla_cens}sit_laboral_padre ,
				sga_datos_censales.ult_est_cur_madre			as {$tabla_cens}ult_est_cur_madre ,
				sga_datos_censales.sit_laboral_madre			as {$tabla_cens}sit_laboral_madre ,
				sga_datos_censales.hora_sem_trab_alum			as {$tabla_cens}hora_sem_trab_alum,
				sga_datos_censales.empresa						as {$tabla_cens}empresa,
				sga_datos_censales.empresa_otra					as {$tabla_cens}empresa_otra,
				sga_datos_censales.sector						as {$tabla_cens}sector,
				sga_datos_censales.subsector					as {$tabla_cens}subsector,
				sga_datos_censales.facilidad_est_emp			as {$tabla_cens}facilidad_est_emp,
				sga_datos_censales.facilidad_est_inst			as {$tabla_cens}facilidad_est_inst,
				sga_datos_censales.antiguedad					as {$tabla_cens}antiguedad,




				trim(sga_datos_cen_aux.celular_numero)			as {$tabla_aux}celular_numero     ,
				sga_datos_cen_aux.celular_compania				as {$tabla_aux}celular_compania   ,
				sga_datos_cen_aux.vive_actual_con				as {$tabla_aux}vive_actual_con    ,
				sga_datos_cen_aux.cant_hijos_alum				as {$tabla_aux}cant_hijos_alum    ,
				sga_datos_cen_aux.cant_fami_cargo				as {$tabla_aux}cant_fami_cargo    ,
				
				sga_datos_cen_aux.existe_trab_alum				as {$tabla_aux}existe_trab_alum		,
				sga_datos_cen_aux.remuneracion					as {$tabla_aux}remuneracion    		,
				sga_datos_cen_aux.horario_trabajo				as {$tabla_aux}horario_trabajo 		,
				sga_datos_cen_aux.padre_vive					as {$tabla_aux}padre_vive      		,
				sga_datos_cen_aux.madre_vive					as {$tabla_aux}madre_vive      		,
				sga_datos_cen_aux.tiene_beca					as {$tabla_aux}tiene_beca      		,
				sga_datos_cen_aux.tiene_beca_univ				as {$tabla_aux}tiene_beca_univ 		,
				sga_datos_cen_aux.tiene_beca_nacio				as {$tabla_aux}tiene_beca_nacio		,
				sga_datos_cen_aux.tiene_beca_inter				as {$tabla_aux}tiene_beca_inter		,


				sga_datos_cen_aux.practica_deportes				as {$tabla_aux}practica_deportes		,
				sga_datos_cen_aux.hace_dep_univ					as {$tabla_aux}hace_dep_univ    		,
				sga_datos_cen_aux.hace_dep_gim_priv				as {$tabla_aux}hace_dep_gim_priv		,
				sga_datos_cen_aux.hace_dep_partic				as {$tabla_aux}hace_dep_partic  		,
				sga_datos_cen_aux.hace_dep_otros				as {$tabla_aux}hace_dep_otros   		,
				sga_datos_cen_aux.prac_dep_futbol				as {$tabla_aux}prac_dep_futbol  		,
				sga_datos_cen_aux.prac_dep_basquet				as {$tabla_aux}prac_dep_basquet 		,
				sga_datos_cen_aux.prac_dep_voley				as {$tabla_aux}prac_dep_voley   		,
				sga_datos_cen_aux.prac_dep_gimnasia				as {$tabla_aux}prac_dep_gimnasia		,
				sga_datos_cen_aux.prac_dep_tenis				as {$tabla_aux}prac_dep_tenis   		,
				sga_datos_cen_aux.prac_dep_natacion				as {$tabla_aux}prac_dep_natacion		,
				sga_datos_cen_aux.prac_dep_handball				as {$tabla_aux}prac_dep_handball		,
				sga_datos_cen_aux.prac_dep_otros				as {$tabla_aux}prac_dep_otros   		,


				sga_datos_cen_aux2.alu_obra_social				as {$tabla_aux2}alu_obra_social  	,
				sga_datos_cen_aux2.alu_est_civil_uh				as {$tabla_aux2}alu_est_civil_uh 	,

				sga_datos_cen_aux2.alu_trab_hace				as {$tabla_aux2}alu_trab_hace    	,
				sga_datos_cen_aux2.alu_trab_desjub				as {$tabla_aux2}alu_trab_desjub  	,
				sga_datos_cen_aux2.alu_trab_fami				as {$tabla_aux2}alu_trab_fami    	,
				sga_datos_cen_aux2.alu_trab_ocup				as {$tabla_aux2}alu_trab_ocup    	,
				sga_datos_cen_aux2.alu_trab_tarea				as {$tabla_aux2}alu_trab_tarea   	,
				sga_datos_cen_aux2.padre_trab_hace				as {$tabla_aux2}padre_trab_hace  	,
				sga_datos_cen_aux2.padre_trab_ocup				as {$tabla_aux2}padre_trab_ocup  	,
				sga_datos_cen_aux2.padre_trab_otro				as {$tabla_aux2}padre_trab_otro  	,
				sga_datos_cen_aux2.padre_trab_tarea				as {$tabla_aux2}padre_trab_tarea 	,
				sga_datos_cen_aux2.madre_trab_hace				as {$tabla_aux2}madre_trab_hace  	,
				sga_datos_cen_aux2.madre_trab_ocup				as {$tabla_aux2}madre_trab_ocup  	,
				sga_datos_cen_aux2.madre_trab_otro				as {$tabla_aux2}madre_trab_otro  	,
				sga_datos_cen_aux2.madre_trab_tarea				as {$tabla_aux2}madre_trab_tarea 	,
				sga_datos_cen_aux2.alu_cos_est_ap_fam			as {$tabla_aux2}alu_cos_est_ap_fam	,
				sga_datos_cen_aux2.alu_cos_est_trab				as {$tabla_aux2}alu_cos_est_trab 	,
				sga_datos_cen_aux2.alu_cos_est_beca				as {$tabla_aux2}alu_cos_est_beca 	,
				sga_datos_cen_aux2.alu_cos_est_plsoc			as {$tabla_aux2}alu_cos_est_plsoc	,
				sga_datos_cen_aux2.alu_cos_est_otra				as {$tabla_aux2}alu_cos_est_otra 	,
				sga_datos_cen_aux2.alu_cos_est_espec			as {$tabla_aux2}alu_cos_est_espec	,
				sga_datos_cen_aux2.alu_beca_muni				as {$tabla_aux2}alu_beca_muni    	,
				sga_datos_cen_aux2.alu_beca_otra				as {$tabla_aux2}alu_beca_otra    	,
				sga_datos_cen_aux2.alu_beca_prov				as {$tabla_aux2}alu_beca_prov    	,
				sga_datos_cen_aux2.alu_beca_tipo_eco			as {$tabla_aux2}alu_beca_tipo_eco	,
				sga_datos_cen_aux2.alu_beca_tipo_ser			as {$tabla_aux2}alu_beca_tipo_ser	,
				sga_datos_cen_aux2.alu_beca_tipo_inv			as {$tabla_aux2}alu_beca_tipo_inv	,
				sga_datos_cen_aux2.alu_beca_eco_tran			as {$tabla_aux2}alu_beca_eco_tran	,
				sga_datos_cen_aux2.alu_beca_eco_come			as {$tabla_aux2}alu_beca_eco_come	,
				sga_datos_cen_aux2.alu_beca_eco_foto			as {$tabla_aux2}alu_beca_eco_foto	,
				sga_datos_cen_aux2.alu_beca_eco_efec			as {$tabla_aux2}alu_beca_eco_efec	,
				sga_datos_cen_aux2.alu_beca_eco_habi			as {$tabla_aux2}alu_beca_eco_habi	,


				sga_datos_cen_aux2.alu_otestsup_uni				as {$tabla_aux2}alu_otestsup_uni  	,
				sga_datos_cen_aux2.alu_otestsup_tipo			as {$tabla_aux2}alu_otestsup_tipo 	,
				sga_datos_cen_aux2.alu_otestsup_area			as {$tabla_aux2}alu_otestsup_area 	,
				sga_datos_cen_aux2.alu_otestsup_carr			as {$tabla_aux2}alu_otestsup_carr 	,
				sga_datos_cen_aux2.alu_otestsup_esta			as {$tabla_aux2}alu_otestsup_esta 	,
				sga_datos_cen_aux2.alu_otestsup_egre			as {$tabla_aux2}alu_otestsup_egre 	,
				sga_datos_cen_aux2.alu_otestsup_niv 			as {$tabla_aux2}alu_otestsup_niv  	,
				sga_datos_cen_aux2.alu_tec_pc_casa				as {$tabla_aux2}alu_tec_pc_casa 	,
				sga_datos_cen_aux2.alu_tec_pc_trab				as {$tabla_aux2}alu_tec_pc_trab   	,
				sga_datos_cen_aux2.alu_tec_pc_univ				as {$tabla_aux2}alu_tec_pc_univ   	,
				sga_datos_cen_aux2.alu_tec_pc_otro				as {$tabla_aux2}alu_tec_pc_otro   	,
				sga_datos_cen_aux2.alu_tec_int_casa				as {$tabla_aux2}alu_tec_int_casa  	,
				sga_datos_cen_aux2.alu_tec_int_trab				as {$tabla_aux2}alu_tec_int_trab  	,
				sga_datos_cen_aux2.alu_tec_int_univ				as {$tabla_aux2}alu_tec_int_univ  	,
				sga_datos_cen_aux2.alu_tec_int_cyber			as {$tabla_aux2}alu_tec_int_cyber 	,
				sga_datos_cen_aux2.alu_tec_int_otro				as {$tabla_aux2}alu_tec_int_otro  	,
				sga_datos_cen_aux2.alu_tec_usint_cha			as {$tabla_aux2}alu_tec_usint_cha 	,
				sga_datos_cen_aux2.alu_tec_usint_cap			as {$tabla_aux2}alu_tec_usint_cap 	,
				sga_datos_cen_aux2.alu_tec_usint_est			as {$tabla_aux2}alu_tec_usint_est 	,
				sga_datos_cen_aux2.alu_tec_usint_per			as {$tabla_aux2}alu_tec_usint_per 	,
				sga_datos_cen_aux2.alu_tec_usint_mai			as {$tabla_aux2}alu_tec_usint_mai 	,
				sga_datos_cen_aux2.alu_tec_int_regul			as {$tabla_aux2}alu_tec_int_regul 	,
				sga_datos_cen_aux2.alu_idioma_ingl				as {$tabla_aux2}alu_idioma_ingl   	,
				sga_datos_cen_aux2.alu_idioma_fran				as {$tabla_aux2}alu_idioma_fran   	,
				sga_datos_cen_aux2.alu_idioma_port				as {$tabla_aux2}alu_idioma_port   	,
				sga_datos_cen_aux2.alu_idioma_ital				as {$tabla_aux2}alu_idioma_ital   	,
				sga_datos_cen_aux2.alu_idioma_alem				as {$tabla_aux2}alu_idioma_alem   	,
				sga_datos_cen_aux2.alu_idioma_otro				as {$tabla_aux2}alu_idioma_otro   	 
				
						
				FROM  sga_datos_censales
				JOIN sga_datos_cen_aux		ON	(sga_datos_cen_aux.unidad_academica		= sga_datos_censales.unidad_academica 
											AND	sga_datos_cen_aux.nro_inscripcion		= sga_datos_censales.nro_inscripcion 
											AND	sga_datos_cen_aux.fecha_relevamiento	= sga_datos_censales.fecha_relevamiento) 
				JOIN sga_datos_cen_aux2		ON	(sga_datos_cen_aux2.unidad_academica	= sga_datos_censales.unidad_academica 
											AND	sga_datos_cen_aux2.nro_inscripcion		= sga_datos_censales.nro_inscripcion
											AND sga_datos_cen_aux2.fecha_relevamiento	= sga_datos_censales.fecha_relevamiento)


				WHERE sga_datos_censales.unidad_academica	= {$parametros['_ua']} 
				AND sga_datos_censales.nro_inscripcion		= {$parametros['nro_inscripcion']}
				AND sga_datos_censales.fecha_relevamiento	= ( SELECT MAX(a.fecha_relevamiento)
									        					FROM 	sga_datos_censales  as a
														        WHERE 	a.unidad_academica = {$parametros['_ua']} 
																AND 	a.nro_inscripcion  = {$parametros['nro_inscripcion']})
				";
		
		return kernel::db()->consultar_fila($sql);
	}
	
	/**
	 * cache: memoria
	 * cache_expiracion: 3600
	 * filas: n
	 */
	function get_definicion_campos()
	{
		$sql =  "	SELECT	systables.tabname,
							syscolumns.colname,
							syscolumns.collength,
							syscolumns.coltype
						
					FROM 	systables
					JOIN 	syscolumns ON (syscolumns.tabid = systables.tabid)
					WHERE   systables.tabname like 'sga_datos_cen%'";
		
		return kernel::db()->consultar($sql);
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function get_datos_docente($parametros)
	{	
		
		$tabla_cens = datos_censales::tabla_datos_censales;
		$tabla_aux	= datos_censales::tabla_datos_censales_aux;
		
		$sql = "SELECT 
				sga_datos_censales.e_mail						as {$tabla_cens}e_mail            ,
				sga_datos_censales.calle_per_lect				as {$tabla_cens}calle_per_lect    ,
				sga_datos_censales.numero_per_lect				as {$tabla_cens}numero_per_lect   ,
				sga_datos_censales.piso_per_lect				as {$tabla_cens}piso_per_lect     ,
				sga_datos_censales.dpto_per_lect				as {$tabla_cens}dpto_per_lect     ,
				sga_datos_censales.unidad_per_lect				as {$tabla_cens}unidad_per_lect   ,
				sga_datos_censales.loc_per_lect					as {$tabla_cens}loc_per_lect      ,
				sga_datos_censales.cp_per_lect					as {$tabla_cens}cp_per_lect       ,
				trim(sga_datos_censales.te_per_lect)			as {$tabla_cens}te_per_lect       ,								
				trim(sga_datos_cen_aux.celular_numero)			as {$tabla_aux}celular_numero     ,
				sga_datos_cen_aux.celular_compania				as {$tabla_aux}celular_compania 
						
				FROM  sga_datos_censales
				JOIN sga_datos_cen_aux		ON	(sga_datos_cen_aux.unidad_academica		= sga_datos_censales.unidad_academica 
											AND	sga_datos_cen_aux.nro_inscripcion		= sga_datos_censales.nro_inscripcion 
											AND	sga_datos_cen_aux.fecha_relevamiento	= sga_datos_censales.fecha_relevamiento) 

				WHERE sga_datos_censales.unidad_academica	= {$parametros['_ua']} 
				AND sga_datos_censales.nro_inscripcion		= {$parametros['nro_inscripcion']}
				AND sga_datos_censales.fecha_relevamiento	= ( SELECT MAX(a.fecha_relevamiento)
									        					FROM 	sga_datos_censales  as a
														        WHERE 	a.unidad_academica = {$parametros['_ua']} 
																AND 	a.nro_inscripcion  = {$parametros['nro_inscripcion']})
				";
		
		return kernel::db()->consultar_fila($sql);
	}

	
	private function armar_sql_where($condiciones)
	{
		$where = '';
		foreach ($condiciones as $columna => $valor) {
			$where == '' ?  $where .= " WHERE {$columna} = {$valor}" : $where .= " AND  {$columna} = {$valor}";
		}
		return $where;
	}
	
	private function armar_sql($indicador_tabla, $datos)
	{
		switch ($indicador_tabla) {
			case datos_censales::tabla_datos_censales:
				$tabla = 'sga_datos_censales';
				break;
			case datos_censales::tabla_datos_censales_aux:
				$tabla = 'sga_datos_cen_aux';
				break;
			case datos_censales::tabla_datos_censales_aux2:
				$tabla = 'sga_datos_cen_aux2';
				break;

			default:
				//errorrr
				break;
		}
				
		$sql = '';
		foreach ($datos as $key => $dato) {
			$dato = ($dato == "''") ? 'NULL' : $dato;
			$columna = strtolower(substr($key, strlen($indicador_tabla), strlen($key)));
			$sql != '' ?  $sql .= ", {$columna} = {$dato}" :  $sql .= "{$columna} = {$dato}";
		}
		
		$sql = "UPDATE $tabla SET " . $sql;
		
		return $sql;
	}
	
    /**
	 * parametros: _ua, nro_inscripcion, cens_, aux1_, aux2_
	 * cache: no
	 * filas: n
	 */
	function actualizar_datos($parametros)
	{
        $hay_cambios_cens_aux = !empty($parametros['aux1_']);
        $hay_cambios_cens_aux2 = !empty($parametros['aux2_']);
		$hay_cambios_cens = !empty($parametros['cens_']);
		$hay_cambios = ($hay_cambios_cens || $hay_cambios_cens_aux || $hay_cambios_cens_aux2);

        if($hay_cambios) {
            // Tabla sga_datos_cens_aux
            if ($hay_cambios_cens_aux) {
                $sql_aux = $this->armar_sql(datos_censales::tabla_datos_censales_aux, $parametros['aux1_']);
            }

            // Tabla sga_datos_cens_aux
            if ($hay_cambios_cens_aux2) {
                $sql_aux2 = $this->armar_sql(datos_censales::tabla_datos_censales_aux2, $parametros['aux2_']);
            }

            }
		
        $parametros['cens_']['CENS_FECHA_ACTUALIZ'] = 'TODAY';
       	$sql_cens = $this->armar_sql(datos_censales::tabla_datos_censales, $parametros['cens_']);
        
        try {
            kernel::db()->abrir_transaccion();
            $sql = "execute procedure sp_i_datoscensales({$parametros['_ua']},{$parametros['nro_inscripcion']})";
            $datos_fecha_relevamiento = kernel::db()->consultar_fila($sql, db::FETCH_NUM);

            if ($datos_fecha_relevamiento[0] == -1) {
                // codigo de error en $datos_fecha_relevamiento[2]
                // mensaje $datos_fecha_relevamiento[3]
                $msj = "Error al recuperar la fecha de relevamiento {$datos_fecha_relevamiento[2]} : {$datos_fecha_relevamiento[3]}  ";
                kernel::db()->abortar_transaccion($msj);
                throw new error_guarani($msj);
            }

            $fecha_relevamiento = "to_date('{$datos_fecha_relevamiento[1]}','%Y-%m-%d')";

            $condiciones['unidad_academica']	= "{$parametros['_ua']}";
            $condiciones['nro_inscripcion']		= "{$parametros['nro_inscripcion']}";
            $condiciones['fecha_relevamiento']	= "{$fecha_relevamiento}";

            $where = $this->armar_sql_where($condiciones);				

            if (isset($sql_cens))	kernel::db()->ejecutar($sql_cens.$where);
            if (isset($sql_aux))	kernel::db()->ejecutar($sql_aux.$where);
            if (isset($sql_aux2))	kernel::db()->ejecutar($sql_aux2.$where);
            kernel::db()->cerrar_transaccion();

        } catch (error_kernel_db $e) {
            $msj = 'Error al Actualizar las tablas de Datos Censales' . $e->get_mensaje();
            kernel::db()->abortar_transaccion($msj);
            throw $e;
        }
	}
    /**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 */
	function actualizar_revision($parametros)
	{
	$sql_fecha_max = "SELECT to_char(MAX(a.fecha_relevamiento), '%d/%m/%Y') 
                                   FROM sga_datos_censales as a
                                  WHERE a.unidad_academica = {$parametros['_ua']} 
                                    AND a.nro_inscripcion = {$parametros['nro_inscripcion']}";
	$fecha_max = current(kernel::db()->consultar_fila($sql_fecha_max));         
            
	$sql = "UPDATE sga_datos_censales 
			SET fecha_actualiz = TODAY 
			WHERE unidad_academica = {$parametros['_ua']} 
			AND nro_inscripcion = {$parametros['nro_inscripcion']}
			AND (to_char(fecha_relevamiento, '%d/%m/%Y') = '$fecha_max')";
		kernel::db()->ejecutar($sql);
	}
    
    /**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 */
	function datos_discapacidad($parametros)
	{
		$sql = " SELECT 	sga_datos_salud.id_datos_salud      AS id,
                            sga_datos_salud.unidad_academica	AS ua,
                            sga_datos_salud.nro_inscripcion     AS nro_inscripcion,
                            sga_datos_salud.tipo_discapacidad	AS tipo,
                            mdp_discap_tipos.descripcion		AS tipo_nombre,
                            sga_datos_salud.tipo_grado          AS grado,   
                            mdp_discap_grado.descripcion        AS grado_nombre,   
                            sga_datos_salud.tipo_caracter       AS caracter,
                            mdp_discap_caracter.descripcion     AS caracter_nombre,
                            to_char(sga_datos_salud.fecha_desde, '%d/%m/%Y')  as fecha_desde,
                            to_char(sga_datos_salud.fecha_hasta, '%d/%m/%Y')  as fecha_hasta,
                            sga_datos_salud.cobertura_medica	AS cobertura_salud,
                            sga_datos_salud.observaciones       AS observaciones
                            
                FROM sga_datos_salud

                JOIN 	mdp_discap_tipos
                ON	sga_datos_salud.tipo_discapacidad = mdp_discap_tipos.tipo_discapacidad		

                JOIN	mdp_discap_caracter
                ON	sga_datos_salud.tipo_caracter = mdp_discap_caracter.tipo_caracter

                JOIN	mdp_discap_grado
                ON	sga_datos_salud.tipo_grado	= mdp_discap_grado.tipo_grado

                WHERE sga_datos_salud.unidad_academica = {$parametros['_ua']} 
				AND   sga_datos_salud.nro_inscripcion = {$parametros['nro_inscripcion']}
                ORDER BY sga_datos_salud.id_datos_salud";
        return kernel::db()->consultar($sql);
	}
    
    /**
	 * parametros: _ua, nro_inscripcion, tipo, grado, caracter, fecha_desde, fecha_hasta, cobertura_salud, observaciones
	 * cache: no
	 */
	function insert_datos_salud($parametros)
	{
        $sql = " INSERT INTO sga_datos_salud 
                                (unidad_academica  , 
                                 nro_inscripcion   , 
                                 tipo_discapacidad ,   
                                 tipo_caracter     , 
                                 tipo_grado        , 
                                 fecha_desde       , 
                                 fecha_hasta       , 
                                 cobertura_medica  , 
                                 observaciones     )
                                 
                VALUES         ({$parametros['_ua']}            ,
                                {$parametros['nro_inscripcion']},
                                {$parametros['tipo']}           ,
                                {$parametros['caracter']}       ,
                                {$parametros['grado']}          ,                                    
                                to_date({$parametros['fecha_desde']}, '%d/%m/%Y'),
                                to_date({$parametros['fecha_hasta']}, '%d/%m/%Y'),   
                                {$parametros['cobertura_salud']},    
                                {$parametros['observaciones']}      )";
                                    
        return kernel::db()->ejecutar($sql);
	}
    
    /**
	 * parametros: _ua, nro_inscripcion, id, tipo, grado, caracter, fecha_desde, fecha_hasta, cobertura_salud, observaciones
	 * cache: no
	 */
	function update_datos_salud($parametros)
	{
        $sql = "UPDATE sga_datos_salud
                SET	tipo_discapacidad 	= {$parametros['tipo']}         ,
                    tipo_caracter       = {$parametros['caracter']}     ,
                    tipo_grado          = {$parametros['grado']}        ,
                    to_date({$parametros['fecha_desde']}, '%d/%m/%Y'),
                    to_date({$parametros['fecha_hasta']}, '%d/%m/%Y'), 
                    cobertura_medica	= {$parametros['cobertura_salud']},
                    observaciones       = {$parametros['observaciones']}
                WHERE	sga_datos_salud.unidad_academica 	= {$parametros['_ua']}
                AND     sga_datos_salud.nro_inscripcion     = {$parametros['nro_inscripcion']}
                AND     sga_datos_salud.id_datos_salud      = {$parametros['id']}";
        
        return kernel::db()->ejecutar($sql);
	}
    
    /**
	 * parametros: _ua, nro_inscripcion, id
	 * cache: no
	 */
	function delete_datos_salud($parametros)
	{
        $sql = "DELETE FROM 	sga_datos_salud
                WHERE   sga_datos_salud.id_datos_salud  = {$parametros['id']}    
                AND     sga_datos_salud.unidad_academica= {$parametros['_ua']} 
				AND     sga_datos_salud.nro_inscripcion = {$parametros['nro_inscripcion']}";
        return kernel::db()->ejecutar($sql);
	}
	
    /**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 */
	function get_ultima_fecha_actualizacion($parametros)
	{						
		$sql = "SELECT fecha_actualiz
				FROM	sga_datos_censales
				WHERE unidad_academica = {$parametros['_ua']}
				AND nro_inscripcion = {$parametros['nro_inscripcion']}
				AND fecha_relevamiento = 
				(
					SELECT MAX(a.fecha_relevamiento) 
				    FROM sga_datos_censales as a
				    WHERE a.unidad_academica = {$parametros['_ua']} 
				    AND a.nro_inscripcion = {$parametros['nro_inscripcion']}				
				)";
        $fecha = current(kernel::db()->consultar_fila($sql));
		return $fecha;
	}	
	
    /**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 */
	function get_cant_dias_ultima_actualizacion($parametros)
	{								
		$sql = "SELECT  TODAY - fecha_actualiz
				FROM	sga_datos_censales
				WHERE unidad_academica = {$parametros['_ua']}
				AND nro_inscripcion = {$parametros['nro_inscripcion']}
				AND fecha_relevamiento =				
				(
					SELECT MAX(a.fecha_relevamiento) 
				    FROM sga_datos_censales as a
				    WHERE a.unidad_academica = {$parametros['_ua']} 
				    AND a.nro_inscripcion = {$parametros['nro_inscripcion']}				
				)";
        $fecha = current(kernel::db()->consultar_fila($sql));
		return $fecha;
	}	
	
    /**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 */
	function tiene_datos_censales_actualizados($parametros)
	{
		$cantidad_dias_controla_datos_censales = entidades\parametro::cantidad_dias_controla_datos_censales();
		$dias_desde_ultima_actualizacion = $this->get_cant_dias_ultima_actualizacion($parametros);
		return ($dias_desde_ultima_actualizacion < $cantidad_dias_controla_datos_censales[0]);
	}	
}
?>