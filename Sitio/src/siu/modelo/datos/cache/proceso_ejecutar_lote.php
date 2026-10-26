<?php
namespace siu\modelo\datos\cache;

use kernel\kernel;
use kernel\error_kernel;
use siu\errores\error_guarani;
use siu\modelo\datos\catalogo;
use kernel\util\manejador_archivos;

/**
 *	Ejecuta un bloque del plan
 * 
 *	En un Dir de trabajo
 *		- a partir de su ID decide su bloque
 *		- Levanta la lista de alumnos
 *		- va dejando el log del proceso en el mismo dir con su ID
 */

class proceso_ejecutar_lote
{
	protected $proceso;
	protected $plan;
	protected $lote;
	protected $log;
	protected $dir;
	protected $alumnos;
	protected $alumnos_x_aviso;
	protected $tiempo_alumnos = array();
	protected $log_file;
	
	function __construct($plan, $lote, $log=true, $alumnos_x_aviso=20)
	{
		$this->proceso = getmypid();
		$this->plan = $plan;
		$this->lote = $lote;
		$this->log = $log;
		$this->alumnos_x_aviso = $alumnos_x_aviso;
		$this->dir = kernel::proyecto()->get_dir_cache() . '/legajos/procesos/' . $this->plan ;
		if(!is_dir($this->dir)) {
			throw new error_guarani("No existe el LOTE: {$this->plan}");
		}
		$id = "lote__{$this->lote}";
		$path = $this->dir . '/' . $id . '.php';
		if(!file_exists($path)) {
			throw new error_guarani("No existe el LOTE: {$this->lote}");
		}
		require_once($path);
		$clase = "\\siu\\cache\\legajo\\proceso\\{$id}";
		$dao = new $clase();
		$this->alumnos = $dao->get_alumnos();
		$this->cantidad_alumnos = count($this->alumnos);
		// Se conecta para que el tiempo de conexion no entre en los calculo
		if ($this->log) {
			$this->log_file = $this->dir .'/' . $id . '.log';
			if(file_exists($this->log_file)){
				unlink($this->log_file);
			}
		}
		kernel::db();
	}
	
	function procesar()
	{
		$a = 0;
		$t_inicial = time();
		$lote = str_pad($this->lote, 3, " ", STR_PAD_LEFT);
		$momento = date('Y/m/d h:i:s A');
		$this->aviso("LOTE $lote | INIT - $momento | alumnos[{$this->cantidad_alumnos}] | pid[{$this->proceso}]");
		foreach($this->alumnos as $alumno) {
			try {
				$microtime = explode(' ', microtime());
				$t_ini_persona =  $microtime[1] . substr($microtime[0], 1);
				//print_r($alumno);
				$p = new generar_legajo($alumno['CARRERA'], $alumno['LEGAJO'], $alumno['NRO_INSCRIPCION'], $alumno['PLAN'], $alumno['VERSION']);
				$p->procesar();
				$microtime = explode(' ', microtime());
				$t_fin_persona =  $microtime[1] . substr($microtime[0], 1);
				$t_persona = number_format($t_fin_persona - $t_ini_persona,2,'.','');
				$this->tiempo_alumnos[] = $t_persona;
			} catch (error_kernel $e) {
				$momento = date('Y/m/d h:i:s A');
				$this->aviso("LOTE $lote | ERROR - $momento | " . $e->getMessage());
				return;
			}

			// INFORMAR
			if ( ($a % $this->alumnos_x_aviso) == 0 ) {
				$porc = ($a / $this->cantidad_alumnos) * 100;
				$porc = number_format($porc, 0, '.','');
				$porc = str_pad($porc, 5, " ", STR_PAD_LEFT);
				$porc .= ' %';
				$desc = str_pad($a, 7, " ", STR_PAD_LEFT);
				$t_acum = ($t_fin_persona - $t_inicial) / 60;
				$t_acum = number_format($t_acum,2,'.','');
				$t_acum = str_pad($t_acum, 8, " ", STR_PAD_LEFT);
				$this->aviso("LOTE $lote | $t_acum min | $porc | $desc legajos | ultimo alumno: $t_persona secs");
			}
			$a++;
		}
		$t_final = time();
		$t_total = (($t_final - $t_inicial) / 60);
		$t_total = number_format($t_total,2,'.','');
		$prom_t_persona = array_sum($this->tiempo_alumnos) / count($this->tiempo_alumnos);
		$prom_t_persona = number_format($prom_t_persona,2,'.','');
		$momento = date('Y/m/d h:i:s A');
		$this->aviso("LOTE $lote | OK - $momento | minutos[$t_total min] | prom_legajo[$prom_t_persona secs] ");
	}

	function aviso($txt)
	{
		if ($this->log) {
			file_put_contents($this->log_file,$txt."\n",FILE_APPEND);
		} else {
			echo $txt . "\n";
		}
	}
}
?>