<?php
namespace siu\util\consola\comandos;
use siu\guarani;
use Symfony\Component\Console\Input\InputArgument,
    Symfony\Component\Console\Input\InputOption,
    Symfony\Component\Console;
use siu\util\generador_escalas;
use kernel\error_kernel;
use kernel\util\manejador_archivos;

class compilar_recursos extends \kernel\consola\comandos\compilar_recursos 
{
	protected $js = array(
		'js/lib/jquery-1.9.min.js',
		'js/lib/history/uncompressed/history.adapter.jquery.js',
		'js/lib/history/uncompressed/history.js',
		'js/lib/history/uncompressed/history.html4.js',
		'js/facebox.js',
		'js/lib/lazyload.js',

		'js/lib/kernel.loader.js',
		'js/lib/kernel.renderer.js',
		'js/lib/kernel.evts.js',
		'js/lib/kernel.ajax.js',
		'js/lib/kernel.historia.js',
		'js/lib/kernel.util.js',
		'js/lib/kernel.ui.js',
		'js/lib/kernel.log.js',
		
		'js/guarani.js',
		'js/jqueryui.js',
        'js/bootstrap.js',
        'js/jquery.mobile.custom.min.js',
        'js/jquery.ui.touch-punch.min.js',
	);
	
	protected $css_browser = array(
		'css/bootstrap.css',
		array('pers'=>true, 'nombre' => 'css/guarani.css'),
		'css/facebox.css',
		'css/jqueryui.css',
	);
	
	protected $css_not_browser = array(
		'css/bootstrap.css',
		'css/bootstrap-responsive.css',
		array('pers'=>true, 'nombre' => 'css/guarani.css'),
		'css/guarani-responsive.css',
		'css/facebox.css',
		'css/jqueryui.css',
	);
	
	function __construct()
	{
		$this->path_destino = guarani::dir().'/www/_comp';
		parent::__construct();
	}
	
	protected function get_namespaces()
	{
		$rs = array(
			'siu' => realpath(guarani::dir().'/..')
		);
		$base_pers_dir = realpath(guarani::dir().'/../pers');
		$pers = array_filter(glob("$base_pers_dir/*"), 'is_dir');
		foreach ($pers as $path) {
			$nombre = basename($path);
			$rs[$nombre] = dirname($path);
		}
		
		return $rs;
	}
	
	protected function execute(Console\Input\InputInterface $input, Console\Output\OutputInterface $output)
	{
		\siu\bootstrap::cargar(true);
		parent::execute($input, $output);
		$this->mostrar_mensaje('Masheando archivos');
		$this->mash($this->js, 'guarani_mash.js');
		$this->mash($this->css_browser, 'guarani_mash.css');
		$this->mash($this->css_not_browser, 'guarani_mash_not_browser.css');
	}
	
	protected function mash($files, $filename)
	{
		$type = pathinfo($filename, \PATHINFO_EXTENSION);
		$siu_files = array();
		$archivos_por_pers = array();
		$personalizaciones = $this->get_namespaces();
		
		foreach ($files as $key => $file) {
			if (is_array($file)) {
				$siu_files[$key] = $this->path_destino.'/siu/'.$file['nombre'];
				$buscar_pers = isset($file['pers']) && $file['pers'];
				if ($buscar_pers) {
					foreach (array_keys($personalizaciones) as $id) {
						if ($id == 'siu') continue;
						$pers_file = "$this->path_destino/$id/{$file['nombre']}";
						if (file_exists($pers_file)) {
							$archivos_por_pers[$id][] = $pers_file;
						}
					}					
				}
			} else {
				$siu_files[$key] = $this->path_destino.'/siu/'.$file;
			}
		}
		
		$file_list = implode(' ', $siu_files);
		$salida = "$this->path_destino/siu/$type/$filename";
		$cmd = "cat $file_list > $salida";
		exec($cmd);

		if (!empty($archivos_por_pers)) {
			foreach ($archivos_por_pers as $pers => $archivos_pers) {
				$file_list = implode(' ', $archivos_pers);
				$salida = "$this->path_destino/$pers/$type/$filename";
				$cmd = "cat $file_list > $salida";
				exec($cmd);
			}
		}
	}
}

?>
