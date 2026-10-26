<?php
namespace kernel\util;

use kernel\kernel;
use siu\errores\error_guarani_login;

class log
{
	const ENTRADA_ETIQUETA = 0;
	const ENTRADA_VALOR = 1;

	const EXCEPCION_CLASE = 0;
	const EXCEPCION_TRACE = 1;
	const EXCEPCION_TEXTO = 2;

	const NIVEL_ERROR = 'error';
	const NIVEL_INFO = 'info';
	const NIVEL_DEBUG = 'debug';
	
	protected $id;
	protected $dir;
	protected $guardado=false;

	protected $activo = false;
	protected $log_debug = false;
	protected $log_php_vars = false;
	protected $log_on_errors = true;

	protected $error_proximo_id = 0;
	protected $error = array();
	protected $warnings = array();

	protected $debug = array();
	protected $info = array();
	protected $debug_proximo_id = 0;

	protected $niveles_debug = array( 'error' => 0,
									'info' => 1,
									'debug' => 2);
	protected $nivel_debug_actual = 0;
	protected $fin = false;

	function  __construct($dir = false)
	{
		if (manejador_archivos::es_windows()){
			date_default_timezone_set('America/Argentina/Buenos_Aires');
		}
		$this->cronometro();
		$this->id = date("Ymd_His___" . rand(1000, 9999));
		$this->dir = $dir;
		if ($dir !== false) {
			if(!is_dir($this->dir)){
				manejador_archivos::crear_arbol_directorios($this->dir);
			}		
		}
	}

	/**
	* @return cronometro
	*/
	function cronometro()
	{
		if (!isset($this->cronometro)) {
			$this->cronometro = new cronometro();
		}
		return $this->cronometro;
	}

	function get_id()
	{
		return $this->id;
	}

	function esta_guardado()
	{
		return $this->guardado;
	}

	function esta_activo()
	{
		return $this->activo;
	}

	//-------------------------------------------------------------------------
	// Nivel
	//-------------------------------------------------------------------------

	function set_activo($activo=true)
	{
		$this->activo = $activo;
	}

	function set_nivel($nivel)
	{
		if(!isset($this->niveles_debug[$nivel])) {
			throw new error_guarani("LOGGER: El nivel de debug '$nivel' no existe");
		}
		$this->nivel_debug_actual = $this->niveles_debug[$nivel];
	}
	
	function es_nivel_activo($nivel)
	{
		return ($this->nivel_debug_actual === $this->niveles_debug[$nivel]);
	}
	
	function set_log_debug()
	{
		$this->set_nivel(log::NIVEL_DEBUG);		
	}

	function set_log_php_vars()
	{
		$this->set_nivel(log::NIVEL_DEBUG);
	}
	
	function set_log_only_on_errors()
	{
		$this->set_nivel(log::NIVEL_ERROR);		
	}
	
	//-------------------------------------------------------------------------
	// Agregar CONTENIDO
	//-------------------------------------------------------------------------

	function add_debug($etiqueta, $valor_a_dumpear, $tabla=false)
	{
        if (is_array($valor_a_dumpear)) {
            //$this->debug[] = array($etiqueta, print_r($valor_a_dumpear, true));
			if (!$tabla) {
				$this->debug[] = array($etiqueta, print_r($valor_a_dumpear,true));
			} else {
		        $this->debug[] = array($etiqueta, $this->array_txt($valor_a_dumpear));
			}
        } else {
            $this->debug[] = array($etiqueta, $valor_a_dumpear);
        }
	}

	function add_info($etiqueta, $valor_a_dumpear, $tabla=false)
	{
        if (is_array($valor_a_dumpear)) {
            //$this->debug[] = array($etiqueta, print_r($valor_a_dumpear, true));
			if (!$tabla) {
				$this->info[] = array($etiqueta, print_r($valor_a_dumpear,true));
			} else {
		        $this->info[] = array($etiqueta, $this->array_txt($valor_a_dumpear));
			}
        } else {
            $this->info[] = array($etiqueta, $valor_a_dumpear);
        }
	}

	function add_error($excepcion)
	{
		$id = $this->error_proximo_id++;
        $clase = get_class($excepcion);
        if ($excepcion instanceof \kernel\acceso\error_kernel_seguridad) {
            $texto = $excepcion->get_error_seguridad();
        } else {
            $texto = $excepcion->getMessage();    
        }		

       	if ($excepcion instanceof \Exception) {
			$traza = $this->extraer_traza($excepcion);
		} else {
			$traza = 'No hay traza (excepcion mock)';
		}
        $log = "clase: $clase\nmensaje: $texto\ntraza: $traza";
        $this->error[$id] = $log;
	}

	function add_php_warning($texto)
	{
		$this->warnings[] = $texto;
	}

	function fin()
	{
		$this->fin = true;
	}
	
	//------------------------------------------------------------------
	// Guardar
	//------------------------------------------------------------------

	function guardar()
	{
		if (($this->nivel_debug_actual === 0) && empty($this->error) && empty($this->warnings)) {
			$this->guardado = true;
			return;
		}
		if (($this->nivel_debug_actual === 1) && empty($this->error) 
					&& empty($this->warnings) && empty($this->info)) {
			$this->guardado = true;
			return;
		}
		if ($this->activo && !$this->guardado) {
			$path_log = kernel::proyecto()->get_dir_log() ."/". $this->id . '.log';
			try{
                $salida = '';

				if ($this->error) {
					$salida .= $this->titulo_seccion('ERRORES');
					$i = 0;
					foreach($this->error as $error) {
						$salida .= $error . "\n\n";
						if ($i<1) $salida .= str_repeat('#', 120) . "\n";
						$i++;
					}
				}
				
				if ($this->warnings) {
					$salida .= $this->titulo_seccion('WARNINGS');
					foreach($this->warnings as $w) {
						$salida .= $w . "\n\n";
					}
				}
				$total = 0;
				$memoria = 0;
				if ($this->nivel_debug_actual >= 1) {
					$salida .= $this->titulo_seccion('INFO basica');

					$memoria = number_format((memory_get_peak_usage()/(1024*1024)), 2);
					$m = str_pad($memoria, 8, " ", STR_PAD_LEFT);
					$salida .= " MEMORIA                   $m Mb\n";
					$salida .= "\n";
					//- CRONOMETRO
					$salida .= "--------------------------------------\n";
					$salida .= " CRONOMETRO\n";
					$salida .= "--------------------------------------\n";
					
					foreach($this->cronometro()->get_marcas() as $id => $marca) {
						if($id === 0) continue;
						$tiempo = str_pad($marca['tiempo'], 8, " ", STR_PAD_LEFT);
						$texto = str_pad($marca['texto'], 25, " ");
						$salida .= "$texto $tiempo seg\n";
						$total += $tiempo;
					}
					$total = number_format($total,3);
					$t = str_pad($total, 8, " ", STR_PAD_LEFT);
					$salida .= "--------------------------------------\n";
					$salida .= " TOTAL                    $t seg\n";
					$salida .= "--------------------------------------\n";
					
					$salida .= $this->titulo_seccion('nivel INFO');
					foreach($this->info as $info) {
						$salida .= $this->titulo_bloque($info[0]);
						$salida .= $info[1] . "\n";
					}
				}

				if($this->nivel_debug_actual === 2) {
					$salida .= $this->titulo_seccion('DEBUG');
					foreach($this->debug as $debug) {
						$salida .= $this->titulo_bloque($debug[0]);
						$salida .= $debug[1] . "\n";
					}
					if ($this->log_php_vars) {
						$salida .= $this->titulo_seccion('PHP VARS');
						$salida .= print_r($this->get_info_php_vars(), true);
					}
				}
                
				//Resumen
				$error = count($this->error);
				$warning = count($this->warnings);
				$fin = ($this->fin) ? 1 : 0;
				$salida .= "\n--F<$fin>:E<$error>:W<$warning>:T<$total s>:M<$memoria Mb>--\n";
				$salida .= $this->generar_resumen_extendido();
				//FIN
				if($this->fin){
					$salida .= "\n== FIN =============================================\n";
				}
                file_put_contents($path_log, $salida);
				
				$this->guardado = true;
			} catch (Exception $e) {
				log_core::msg("Error generando el archivo de log: $path_log. " . $e->getMessage());
			}
		}
	}
	
	function generar_resumen_extendido()
	{
		return "";
	}
	
	static function get_resumen($id)
	{
		$path = kernel::proyecto()->get_dir_log() . '/' . $id . '.log';
		//$log = mb_convert_encoding(file_get_contents($this->path), 'UTF-8');
		$log = file_get_contents($path);
		$match = array();
		$ereg = "/F<(.*?)>:E<(.*?)>:W<(.*?)>:T<(.*?)>:M<(.*?)>/";
		preg_match_all($ereg, $log, $match,PREG_SET_ORDER);
		if(isset($match[0]) && is_array($match[0]) && isset($match[0][0])) {
			$data = array(	'parse' => true,
							'end'=>$match[0][1],
							'exception'=>$match[0][2],
							'warning'=>$match[0][3],
							'time'=>$match[0][4],
							'memory'=>$match[0][5],
					);
		} else {
			$data = array(	'parse'=>false );
		}
		return $data;		
	}

	protected function titulo_seccion($titulo)
	{
		$out = "\n";
		$out .= str_repeat('=',80)."\n";
		$out .= str_pad("   " . $titulo . "   ", 80, "=", STR_PAD_BOTH) . "\n";
		$out .= str_repeat('=',80)."\n";
		$out .= "\n";
		return $out;
	}
	
	protected function titulo_bloque($titulo)
	{
		$out = "\n";
		$out .= str_pad("--  " . $titulo . "  ", 80, "-") . "\n";
		$out .= "\n";
		return $out;
	}
	
	protected function array_txt($rs)
	{
		if(count($rs) === 0) {
			return 'ARRAY VACIO';
		} elseif(! is_array(current($rs)) ) { // Una sola DIMENSION
			return print_r($rs,true);
		}
		// Display de una tabla en TXT
		// Determino los anchos de columna
		$anchos = array(); 
		foreach(array_keys(current($rs)) as $id) {
			$anchos[$id] = mb_strlen($id);
		}
		foreach($rs as $fila) {
			foreach(array_keys($fila) as $id) {
				if (is_array($fila[$id])) {		
					// Los datos no tienen estructura de tabla!!!
					return print_r($rs,true);
				}
				$ancho = mb_strlen($fila[$id]);
				if($anchos[$id] < $ancho) $anchos[$id] = $ancho;
			}
		}
		// Genero la salida
		$total = array_sum($anchos) + count($anchos) + 1;
		$out = '';
		$out .= str_repeat('-',$total)."\n";		
		$out .= '|';
		foreach(array_keys($anchos) as $titulo) {
			$out .= $this->mb_str_pad($titulo,$anchos[$titulo]," ",STR_PAD_BOTH) . "|";
		}
		$out .= "\n";
		$out .= str_repeat('-',$total)."\n";		
		foreach($rs as $fila) {
			$out .= '|';
			foreach(array_keys($fila) as $id) {
				$out .= $this->mb_str_pad($fila[$id],$anchos[$id]," ",STR_PAD_BOTH) . "|";
			}
			$out .= "\n";
		}
		$out .= str_repeat('-',$total)."\n";
		return $out;
	}
	
	function mb_str_pad ($input, $pad_length, $pad_string, $pad_style, $encoding="UTF-8") { 
		return str_pad($input, strlen($input)-mb_strlen($input,$encoding)+$pad_length, $pad_string, $pad_style); 
	} 	
	
    protected function aplanar_array(& $array)
    {
        $rs = array();
        foreach ($array as $key => $data) {
            $rs[$key] = print_r($data, true);
        }
        
        return $rs;
    }
    
	protected function get_info_php_vars()
	{
        $rs = array();
        if (function_exists('apache_request_headers')) {
            $rs['HEADERS'] = apache_request_headers();
        }
        
        $rs['POST']   = $this->aplanar_array($_POST);
        $rs['GET']    = $this->aplanar_array($_GET);
        $rs['FILES']  = $this->aplanar_array($_FILES);
        $rs['SERVER'] = $this->aplanar_array($_SERVER);

        return $rs;
	}

	//------------------------------------------------------------------------------
	//---- TRAZA de EXCEPCIONES ----------------------------------------------------
	//------------------------------------------------------------------------------

	protected function extraer_traza(\Exception $excepcion)
	{
		//Solo muestra parametros en modo DEBUG
		if (strpos(get_class($excepcion),'Twig') !== false){
			return '';
		}
		$traza = $excepcion->getTrace();
		$traza[0]['file'] = $excepcion->getFile();
		$traza[0]['line'] = $excepcion->getLine();
		return $this->formatear_traza($traza, $excepcion);
	}

	protected function formatear_traza(& $pasos, $excepcion)
	{
    	$html = "[TRAZA]\n";
    	foreach ($pasos as $idpaso => $paso) {
			$clase = '';
			if (isset($paso['class'])) {
				$clase .= $paso['class'];
			}
			$html .= "\n---[ $idpaso ]-----------------------------------------\n\n";
			//Se obvia los pasos por esta clase
			if ($clase !== __CLASS__) {
				if (isset($paso['type']))
					$clase .= $paso['type'];
				$html .= "- function: $clase{$paso['function']}\n";
				if (isset($paso['file'])) {
					$html .= "- file: {$paso['file']}, linea {$paso['line']}\n";
				}
				if (! empty($paso['args'])) {
                    $mostrar_parametros = true;
                    if ($excepcion instanceof error_guarani_login) {
                        $mostrar_parametros = false;
                    }
                    
                    if ($mostrar_parametros){
                        $html .= "- param: \n";
                        foreach ($paso['args'] as $idpar => $arg) {
                            $html .= "\t $idpar: ";
                            if (is_object($arg)) {
                                $html .= 'object: '.get_class($arg).'';
                            } else {
                                if (!is_array($arg)) {
                                    if (strlen($arg)> 150) {
                                        $arg = substr($arg, 0, 150);
                                        $arg .= "..... ETC";
                                    }
                                }
                                $html .= print_r($arg, true);                            
                            }
                        }
                    } else {
                        $html .= "- param: ".str_repeat("*", 4)."\n";
                    }
				}
			}
    	}
    	return $html;
	}
}

?>