<?php
namespace siu\operaciones\inscripciones;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;

class pagelet_cursadas extends pagelet
{
	function ini()
	{
	}
	
	function get_nombre()
	{
		return 'cursadas';
	}
	
	function get_alcance() 
	{
		return $this->controlador->get_var('alcance_cursadas', 'A');
	}

	function datos () 
	{
		// parametros cursadas
		$parametros_cursada = array();
		$parametros_cursada['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
		$parametros_cursada['estado'] = "T";
		
		if ($this->get_alcance() == "T"){
			$parametros_cursada['alcance'] = "T";
                        $historico = true;
		} else {
			$parametros_cursada['alcance'] = "A";
                        $historico = false;
		}

		// datos cursadas
		$inscripciones_cursadas_rechazadas = catalogo::consultar('alumno', 'inscripciones_cursadas_rechazadas', $parametros_cursada);
		$inscripciones_cursadas = catalogo::consultar('alumno', 'inscripciones_cursadas', $parametros_cursada);
		$cursadas = array_merge($inscripciones_cursadas_rechazadas, $inscripciones_cursadas);
                
                // agrega url comprobante incripcion
                foreach($cursadas as $key => $cursada){
                    if($cursada['estado'] != 'Rechazada' ){
                        $cursadas[$key]['url_comp'] = kernel::vinculador()->crear('cursada', 
                                                                                  'generar_comprobante', 
                                                                                   array('materia' => $cursada['url_materia'],
                                                                                         'transaccion' => $cursada['url_nro_transaccion'],
                                                                                         'mis_inscripciones' => true,
                                                                                         'i' => true,
                                                                                         'historico' => $historico)
                                                                                 );
                    } 
                    else { 
                        unset($cursadas[$key]['url_comp']);
                    }
                }
                self::ordenar_desc($cursadas);
		return $cursadas;
	}
	
        static function ordenar_desc (&$lista){
                uasort($lista, function($a, $b) {
                        return strcasecmp($b['orden'], $a['orden']);
                });
        }
        
	function prepare()
	{
		$operacion = kernel::ruteador()->get_id_operacion();
		$this->add_var_js('url_cursadas', kernel::vinculador()->crear($operacion, 'cursadas'));
		$this->data['cursadas'] = $this->datos();
		$this->data['alcance_examenes'] = $this->get_alcance();
                $this->data['url_pdf_parcial'] = kernel::vinculador()->crear('solicitud_certificado', 'exportar_pdf_parcial');
                $this->data['pdf_lista'] = kernel::vinculador()->crear($operacion, 'generar_pdf', array('cursada', $this->get_alcance()));
                $this->data['xls_lista'] = kernel::vinculador()->crear($operacion, 'generar_xls', array('cursada', $this->get_alcance()));
	}
}
?>