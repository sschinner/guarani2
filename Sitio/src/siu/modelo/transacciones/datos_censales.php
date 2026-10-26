<?php

namespace siu\modelo\transacciones;

use kernel\kernel;
use siu\modelo\datos\catalogo;
use siu\errores;
use siu\conf;
use kernel\util\validador;
use siu\conf\definicion_datos_censales;
use siu\conf\definicion_datos_censales_docente;
use kernel\error_kernel_db;
use siu\guarani;

class datos_censales extends transaccion {

    protected $operacion = 'mat00022';
    protected $evento = '2';

    function get_datos_censales() {
        if (kernel::persona()->perfil()->es('DOC')) {
            $datos_censales = kernel::persona()->get_user_data('datos_censales_docente');
            if ($datos_censales === false) {
                $datos_censales = catalogo::consultar('datos_censales', 'get_datos_docente', array(
                            'nro_inscripcion' => $this->nro_inscripcion
                ));
                kernel::persona()->set_user_data('datos_censales_docente', $datos_censales);
            }
        } else if (kernel::persona()->perfil()->es('ALU')) {
            $datos_censales = kernel::persona()->get_user_data('datos_censales');
            if ($datos_censales === false) {
                $datos_censales = catalogo::consultar('datos_censales', 'get_datos', array(
                            'nro_inscripcion' => $this->nro_inscripcion
                ));
                kernel::persona()->set_user_data('datos_censales', $datos_censales);
            }
        }
        return $datos_censales;
    }

    function grabar_datos_censales($datos) {
        if (kernel::persona()->perfil()->es('DOC')) {
            $this->validar_datos_docente($datos);
        } else if (kernel::persona()->perfil()->es('ALU')) {
            $this->validar_datos($datos);
        }

        $datos_de_sesion = $this->get_datos_censales();
        $datos_modificados = array();

        $datos_modificados['CENS_'] = array();
        $datos_modificados['AUX1_'] = array();
        $datos_modificados['AUX2_'] = array();

        foreach (array_keys($datos_de_sesion) as $key) {
            // Si el dato vino en el Post y es distinto al que se mandó
            if (isset($datos[$key]) && $datos[$key] != $datos_de_sesion[$key]) {
                switch (substr($key, 0, 5)) {
                    case 'CENS_':
                        $datos_modificados['CENS_'][$key] = $datos[$key];
                        break;
                    case 'AUX1_':
                        $datos_modificados['AUX1_'][$key] = $datos[$key];
                        break;
                    case 'AUX2_':
                        $datos_modificados['AUX2_'][$key] = $datos[$key];
                        break;
                    default:
                        break;
                }
                // Esto va acá porque solo los datos que se enviaron al usuario son los que se tienen 
                // en cuenta (esto se controla usando el $key que es un prefijo de la tabla + el nombre campo
                $datos_de_sesion[$key] = $datos[$key];
            }
        }

        /*
         * Datos censales
         * Solapa Situación familiar
         * Cuando se modifica el campo 'Condición de actividad de la semana pasada' sga_datos_censales.sit_laboral_padre / sga_datos_censales.sit_laboral_madre:
         * 
         * Si la situación es distinta de 3  No trabajó y no buscó trabajo (no esta pensando en trabajar), Tranqui!
         * Se blanquea el campo:
         * sga_datos_cen_aux2.padre_trab_otro - En el caso del padre
         * sga_datos_cen_aux2.madre_trab_otro - En el caso de la madre
         *
         * 
         * Si la situación es distinta de 1 - Trabajó al menos una hora (incluye ausencia por licencia, vacaciones, enfermedad)
         * Se blanquean los campos:
         * 
         * Padre:
         * sga_datos_cen_aux2.padre_trab_hace
         * sga_datos_cen_aux2.padre_trab_ocup
         * sga_datos_cen_aux2.padre_trab_tarea
         * 
         * Madre:
         * sga_datos_cen_aux2.madre_trab_hace
         * sga_datos_cen_aux2.madre_trab_ocup
         * sga_datos_cen_aux2.madre_trab_tarea
         * 
         */
        if (!empty($datos_modificados['CENS_']['CENS_SIT_LABORAL_PADRE'])) {
            if ($datos_modificados['CENS_']['CENS_SIT_LABORAL_PADRE'] != '3') {
                $datos_modificados['AUX2_']['AUX2_PADRE_TRAB_OTRO'] = "";
            }

            if ($datos_modificados['CENS_']['CENS_SIT_LABORAL_PADRE'] != '1') {
                $datos_modificados['AUX2_']['AUX2_PADRE_TRAB_HACE'] = "";
                $datos_modificados['AUX2_']['AUX2_PADRE_TRAB_OCUP'] = "";
                $datos_modificados['AUX2_']['AUX2_PADRE_TRAB_TAREA'] = "";
            }
        }

        if (!empty($datos_modificados['CENS_']['CENS_SIT_LABORAL_MADRE'])) {
            if ($datos_modificados['CENS_']['CENS_SIT_LABORAL_MADRE'] != '3') {
                $datos_modificados['AUX2_']['AUX2_MADRE_TRAB_OTRO'] = "";
            }

            if ($datos_modificados['CENS_']['CENS_SIT_LABORAL_MADRE'] != '1') {
                $datos_modificados['AUX2_']['AUX2_MADRE_TRAB_HACE'] = "";
                $datos_modificados['AUX2_']['AUX2_MADRE_TRAB_OCUP'] = "";
                $datos_modificados['AUX2_']['AUX2_MADRE_TRAB_TAREA'] = "";
            }
        }
        
        /*
         * Datos censales
         * Solapa Situación laboral
         * Cuando se modifica el campo 'Condición de actividad de la semana pasada' (sga_datos_cen_aux.existe_trab_alum) y el mismo es distinto de 1 'trabajó':
         * Se Blanquean los campos:
         * sga_datos_censales.rel_trab_carrera
         * sga_datos_censales.hora_sem_trab_alum
         * sga_datos_cen_aux.remuneracion
         * sga_datos_cen_aux2.alu_trab_desjub
         * sga_datos_cen_aux2.alu_trab_fami
         * sga_datos_cen_aux2.alu_trab_ocup
         * sga_datos_cen_aux2.alu_trab_tarea
         * 
         */        
        if (!empty($datos_modificados['AUX1_']['AUX1_EXISTE_TRAB_ALUM'])) {
            if ($datos_modificados['AUX1_']['AUX1_EXISTE_TRAB_ALUM'] != '1') {
                $datos_modificados['CENS_']['CENS_REL_TRAB_CARRERA'] = "";
                $datos_modificados['CENS_']['CENS_HORA_SEM_TRAB_ALUM'] = "";
                
                $datos_modificados['AUX1_']['AUX1_REMUNERACION'] = "";
                
                $datos_modificados['AUX2_']['AUX2_ALU_TRAB_DESJUB'] = "";
                $datos_modificados['AUX2_']['AUX2_ALU_TRAB_FAMI'] = "";
                $datos_modificados['AUX2_']['AUX2_ALU_TRAB_OCUP'] = "";
                $datos_modificados['AUX2_']['AUX2_ALU_TRAB_TAREA'] = "";
            }
        }
        
        $parametros = array(
            'CENS_' => $datos_modificados['CENS_'],
            'AUX1_' => $datos_modificados['AUX1_'],
            'AUX2_' => $datos_modificados['AUX2_'],
            'nro_inscripcion' => $this->nro_inscripcion
        );

        catalogo::consultar('datos_censales', 'actualizar_datos', $parametros);

        // Actualizo los datos de la session 
        if (kernel::persona()->perfil()->es('DOC')) {
            kernel::persona()->set_user_data('datos_censales_docente', $datos_de_sesion);
        } else if (kernel::persona()->perfil()->es('ALU')) {
            kernel::persona()->set_user_data('datos_censales', $datos_de_sesion);
        }
    }

    function validar_datos(&$datos) {
        $e = new errores\error_procesar_datos_censales();

        foreach ($datos as $clave => $valor) {
            if (!conf\definicion_datos_censales::es_campo_a_validar($clave)) {
                continue;
            }

            $def = conf\definicion_datos_censales::get_campo($clave);
            $filtro = $def[definicion_datos_censales::filtro];
            $allow_empty = !$def[definicion_datos_censales::obligatorio];
            $largo = $def[definicion_datos_censales::largo];
            $format = isset($def[definicion_datos_censales::format]) ? $def[definicion_datos_censales::format] : '';

            $es_valido = validador::es_valido($valor, $filtro, array(
                        'allowempty' => $allow_empty,
                        'format' => $format
            ));

            if ($es_valido) {
                $datos[$clave] = \mb_substr($valor, 0, $largo);
            } else {
                // si hay error, acumular mensajes
                $e->agregar_mensaje($clave, "Error en $clave");
            }
        }

        if ($e->hay_errores()) {
            throw $e;
        }
    }

    function validar_datos_docente(&$datos) {
        $e = new errores\error_procesar_datos_censales();

        foreach ($datos as $clave => $valor) {
            if (!conf\definicion_datos_censales_docente::es_campo_a_validar($clave)) {
                continue;
            }

            $def = conf\definicion_datos_censales_docente::get_campo($clave);
            $filtro = $def[definicion_datos_censales_docente::filtro];
            $allow_empty = !$def[definicion_datos_censales_docente::obligatorio];
            $largo = $def[definicion_datos_censales_docente::largo];
			$format = isset($def[definicion_datos_censales_docente::format]) ? $def[definicion_datos_censales_docente::format] : '';
			
            $es_valido = validador::es_valido($valor, $filtro, array(
                        'allowempty' => $allow_empty,
                        'format' => $format
            ));

            if ($es_valido) {
                $datos[$clave] = \mb_substr($valor, 0, $largo);
            } else {
                // si hay error, acumular mensajes
                $e->agregar_mensaje($clave, "Error en $clave");
            }
        }

        if ($e->hay_errores()) {
            throw $e;
        }
    }

	//--------------------------------------------------------------------------
	//---- Control de faltantes ------------------------------------------------
	//--------------------------------------------------------------------------

	function get_datos_faltantes()
	{
		$datos_faltantes = array();
		$datos_censales = $this->get_datos_censales();
		$definicion_datos_censales = array();
		
		kernel::log()->add_debug("=== Datos censales ===", $datos_censales);
		
		// Si es docente
		if (kernel::persona()->perfil()->es('DOC')) {
			$clase_definicion = "siu\\conf\\definicion_datos_censales_docente";
		} elseif (kernel::persona()->perfil()->es('ALU')) {// Si es alumno
			$clase_definicion = "siu\\conf\\definicion_datos_censales";
		}
		
		$definicion_datos_censales = $clase_definicion::get_def();
		
		/****************************************************
		 ******************* Situación laboral **************
		 ****************************************************
		 */
		
		// Si el campo "Condición de actividad de la semana pasada" es distinto a "Trabajó al menos una hora" ...
		if (isset($datos_censales['AUX1_EXISTE_TRAB_ALUM']) && $datos_censales['AUX1_EXISTE_TRAB_ALUM'] != 1) {
			
			// ... pongo los siguientes campos como no obligatorios
			if (isset($definicion_datos_censales['AUX2_ALU_TRAB_OCUP'])) {
				$definicion_datos_censales['AUX2_ALU_TRAB_OCUP'][$clase_definicion::obligatorio] = false;
			}
			
			if (isset($definicion_datos_censales['CENS_HORA_SEM_TRAB_ALUM'])) {
				$definicion_datos_censales['CENS_HORA_SEM_TRAB_ALUM'][$clase_definicion::obligatorio] = false;
			}
			
			if (isset($definicion_datos_censales['AUX2_ALU_TRAB_TAREA'])) {
				$definicion_datos_censales['AUX2_ALU_TRAB_TAREA'][$clase_definicion::obligatorio] = false;
			}
			
			if (isset($definicion_datos_censales['AUX2_ALU_TRAB_HACE'])) {
				$definicion_datos_censales['AUX2_ALU_TRAB_HACE'][$clase_definicion::obligatorio] = false;
			}
			
			if (isset($definicion_datos_censales['CENS_REL_TRAB_CARRERA'])) {
				$definicion_datos_censales['CENS_REL_TRAB_CARRERA'][$clase_definicion::obligatorio] = false;
			}
			
			if (isset($definicion_datos_censales['AUX2_ALU_TRAB_DESJUB'])) {
				$definicion_datos_censales['AUX2_ALU_TRAB_DESJUB'][$clase_definicion::obligatorio] = false;
			}
			
			if (isset($definicion_datos_censales['AUX2_ALU_TRAB_FAMI'])) {
				$definicion_datos_censales['AUX2_ALU_TRAB_FAMI'][$clase_definicion::obligatorio] = false;
			}
			
			if (isset($definicion_datos_censales['AUX1_REMUNERACION'])) {
				$definicion_datos_censales['AUX1_REMUNERACION'][$clase_definicion::obligatorio] = false;
			}
		}
		
		/****************************************************
		 ******************* Situación del padre ************
		 ****************************************************
		 */
		
		// Si el "padre vive" ...
		if (isset($datos_censales['AUX1_PADRE_VIVE']) && $datos_censales['AUX1_PADRE_VIVE'] == 'S') {
			
			// ... pongo el campo "Condición de actividad de la semana pasada" como obligatorio
			if (isset($definicion_datos_censales['CENS_SIT_LABORAL_PADRE'])) {
				$definicion_datos_censales['CENS_SIT_LABORAL_PADRE'][$clase_definicion::obligatorio] = true;
			}
			
		}
		
		// Si el campo "Condición de actividad de la semana pasada" del padre es igual a "Trabajó al menos una hora" ...
		if (isset($datos_censales['CENS_SIT_LABORAL_PADRE']) && $datos_censales['CENS_SIT_LABORAL_PADRE'] == 1) {
			
			// ... pongo los campos "Cargo", "Estado del trabajo", y "Describa la tarea que realiza" como obligatorios
			if (isset($definicion_datos_censales['AUX2_PADRE_TRAB_HACE'])) {
				$definicion_datos_censales['AUX2_PADRE_TRAB_HACE'][$clase_definicion::obligatorio] = true;
			}
			
			if (isset($definicion_datos_censales['AUX2_PADRE_TRAB_OCUP'])) {
				$definicion_datos_censales['AUX2_PADRE_TRAB_OCUP'][$clase_definicion::obligatorio] = true;
			}
			
			if (isset($definicion_datos_censales['AUX2_PADRE_TRAB_TAREA'])) {
				$definicion_datos_censales['AUX2_PADRE_TRAB_TAREA'][$clase_definicion::obligatorio] = true;
			}
			
		}
		
		// Si el campo "Condición de actividad de la semana pasada" del padre es igual a "No trabajó y no buscó trabajo" ...
		if (isset($datos_censales['CENS_SIT_LABORAL_PADRE']) && $datos_censales['CENS_SIT_LABORAL_PADRE'] == 3) {
			
			// ... pongo el campo "Si no trabaja y no busca trabajo" como obligatorio
			if (isset($definicion_datos_censales['AUX2_PADRE_TRAB_OTRO'])) {
				$definicion_datos_censales['AUX2_PADRE_TRAB_OTRO'][$clase_definicion::obligatorio] = true;
			}
			
		}
		
		/****************************************************
		 ******************* Situación del madre ************
		 ****************************************************
		 */
		
		// Si la "madre vive" ...
		if (isset($datos_censales['AUX1_MADRE_VIVE']) && $datos_censales['AUX1_MADRE_VIVE'] == 'S') {
			
			// ... pongo el campo "Condición de actividad de la semana pasada" como obligatorio
			if (isset($definicion_datos_censales['CENS_SIT_LABORAL_MADRE'])) {
				$definicion_datos_censales['CENS_SIT_LABORAL_MADRE'][$clase_definicion::obligatorio] = true;
			}
			
		}
		
		// Si el campo "Condición de actividad de la semana pasada" de la madre es igual a "Trabajó al menos una hora" ...
		if (isset($datos_censales['CENS_SIT_LABORAL_MADRE']) && $datos_censales['CENS_SIT_LABORAL_MADRE'] == 1) {
			
			// ... pongo los campos "Cargo", "Estado del trabajo", y "Describa la tarea que realiza" como obligatorios
			if (isset($definicion_datos_censales['AUX2_MADRE_TRAB_HACE'])) {
				$definicion_datos_censales['AUX2_MADRE_TRAB_HACE'][$clase_definicion::obligatorio] = true;
			}
			
			if (isset($definicion_datos_censales['AUX2_MADRE_TRAB_OCUP'])) {
				$definicion_datos_censales['AUX2_MADRE_TRAB_OCUP'][$clase_definicion::obligatorio] = true;
			}
			
			if (isset($definicion_datos_censales['AUX2_MADRE_TRAB_TAREA'])) {
				$definicion_datos_censales['AUX2_MADRE_TRAB_TAREA'][$clase_definicion::obligatorio] = true;
			}
			
		}
		
		// Si el campo "Condición de actividad de la semana pasada" del padre es igual a "No trabajó y no buscó trabajo" ...
		if (isset($datos_censales['CENS_SIT_LABORAL_MADRE']) && $datos_censales['CENS_SIT_LABORAL_MADRE'] == 3) {
			
			// ... pongo el campo "Si no trabaja y no busca trabajo" como obligatorio
			if (isset($definicion_datos_censales['AUX2_MADRE_TRAB_OTRO'])) {
				$definicion_datos_censales['AUX2_MADRE_TRAB_OTRO'][$clase_definicion::obligatorio] = true;
			}
			
		}
		
		kernel::log()->add_debug("=== Definicion datos censales ===", $definicion_datos_censales);
		
		// Recorro la definición de datos censales
		foreach ($definicion_datos_censales as $key_dato_censal => $definicion_dato_censal) {
				
			// Si existe el dato censal, es obligatorio y esta vacío
			if (array_key_exists($key_dato_censal, $datos_censales) && ($definicion_dato_censal[$clase_definicion::obligatorio]) && (empty($datos_censales[$key_dato_censal]))) {
				$datos_faltantes[$definicion_dato_censal[$clase_definicion::sub_form]][] = $key_dato_censal;
			}
			
		}

		kernel::log()->add_debug("=== Datos faltantes ===", $datos_faltantes);
		
		return $datos_faltantes;
	}
	
    function actualizar_revision() {
        catalogo::consultar('datos_censales', 'actualizar_revision', array(
            'nro_inscripcion' => $this->nro_inscripcion
        ));
    }

    function tiene_datos_censales_actualizados() {
        return catalogo::consultar('datos_censales', 'tiene_datos_censales_actualizados', array(
            'nro_inscripcion' => $this->nro_inscripcion
        ));
    }

	function get_ultima_fecha_actualizacion() {
        return catalogo::consultar('datos_censales', 'get_ultima_fecha_actualizacion', array(
            'nro_inscripcion' => $this->nro_inscripcion
        ));
    }

    function get_datos_discapacidad() {
        $datos = catalogo::consultar('datos_censales', 'datos_discapacidad', array(
                    'nro_inscripcion' => $this->nro_inscripcion
        ));

        $respuesta = array();
        foreach ($datos as $key => $dato) {
            $respuesta[$key] = $dato;
            $respuesta[$key][catalogo::id] = catalogo::generar_id($dato['ID']);
        }
        return $respuesta;
    }

    function grabar_datos_salud($parametros) {
//        if ($parametros['form_datos_discapacidad']['FECHA_DESDE']) {
//            $parametros['form_datos_discapacidad']['FECHA_DESDE'] = date('m/d/Y', strtotime(str_replace('/', '-', $parametros['form_datos_discapacidad']['FECHA_DESDE'])));
//        }
//
//        if ($parametros['form_datos_discapacidad']['FECHA_HASTA']) {
//            $parametros['form_datos_discapacidad']['FECHA_HASTA'] = date('m/d/Y', strtotime(str_replace('/', '-', $parametros['form_datos_discapacidad']['FECHA_HASTA'])));
//        }

        $params = $parametros['form_datos_discapacidad'];
        $params['NRO_INSCRIPCION'] = $this->nro_inscripcion;

        if (!empty($params['ID'])) {
            $estado = catalogo::consultar('datos_censales', 'update_datos_salud', $params);
        } else {
            $estado = catalogo::consultar('datos_censales', 'insert_datos_salud', $params);
        }
        return $estado;
    }

    function eliminar_datos_salud($id) {
        $params = array(
            'id' => $id,
            'nro_inscripcion' => $this->nro_inscripcion
        );

        try {
            catalogo::consultar('datos_censales', 'delete_datos_salud', $params);
            return true;
        } catch (error_kernel_db $e) {
            return false;
        }
    }

    function control__inicial() {
        $proceso = $this->nuevo_proceso_control();

//        $nro_inscripcion	= guarani::persona()->get_nro_inscripcion();	
        $carrera = guarani::persona()->get_id_carrera_activa();
        $legajo = guarani::persona()->get_id_legajo_activo();

        //(Persona - Operación) - Una Persona elige una operación
        $proceso->agregar_punto(2, array('nro_inscripcion' => $this->nro_inscripcion,
            'operacion' => $this->operacion));
        //(Alumno - Operación) - Un Alumno elige una operación
        $proceso->agregar_punto(3, array('carrera' => $carrera,
            'legajo' => $legajo,
            'operacion' => $this->operacion));
        $proceso->agregar_punto(24, array('nro_inscripcion' => $this->nro_inscripcion,
            'carrera' => $carrera));
        return $proceso->ejecutar();
    }
	
	}

?>