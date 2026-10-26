<?php
namespace siu\modelo\datos\cache;

use kernel\kernel;
use kernel\util\manejador_archivos;

/**
 * Recibe un dir con un plan y escanea la actividad de los hilos
 */
class proceso_monitor
{
	static function estado_actual($plan)
	{
		$info = proceso_plan::get_info_plan($plan);
		foreach($info['lista_lotes'] as $lote) {
			$dir = kernel::proyecto()->get_dir_cache() . '/legajos/procesos/' . $plan ;
			$log_file = "{$dir}/lote__{$lote}.log";
			$estado = self::get_ultima_fila($log_file);
			print_r($estado ."\n");
		}		
	}


	static function get_ultima_fila($log_file)
	{
		$filas = file($log_file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
		return array_pop($filas);

	}

}
?>