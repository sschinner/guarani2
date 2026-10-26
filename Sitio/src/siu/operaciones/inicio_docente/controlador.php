<?php
namespace siu\operaciones\inicio_docente;

use siu\guarani;
use siu\extension_kernel\controlador_g3w2;

use kernel\kernel;
use kernel\error_kernel;
use siu\extension_kernel\error_procesar_renglones;
use kernel\util\validador;

class controlador extends controlador_g3w2
{	
    function get_clase_vista()
	{
		return 'vista_actas';
	}
	
    /**
     * @return siu\modelo\transacciones\carga_notas_examen
     */
    function modelo()
    {
        return guarani::carga_notas_examen();
    }

    function accion__index()
    {
	
    }

    function info_encuestas_pendientes()
    {
        $encuestas_pendientes = kernel::persona()->get_encuestas_pendientes();
        // corte
        $corte = array();
        foreach($encuestas_pendientes as $encuesta){
            $corte[$encuesta['id_grupo']]['desplegar_encuestas'] = $encuesta['desplegar_encuestas'];
            $encuesta['link_encuesta'] = kernel::vinculador()->crear('encuestas_kolla', 'index', $encuesta['id']);
            if ($encuesta['desplegar_encuestas'] == 1){
                $corte[$encuesta['id_grupo']]['titulo_grupo'] = $encuesta['titulo_grupo'];
                $corte[$encuesta['id_grupo']]['encuestas'][] = $encuesta;
                // $corte[$encuesta['id_grupo']]['item_titulo'] = $encuesta['alcance_titulo'];
            } else {
                $corte[$encuesta['id_grupo']] = $encuesta;
            }

        }
        return $corte;
    }

}

?>
