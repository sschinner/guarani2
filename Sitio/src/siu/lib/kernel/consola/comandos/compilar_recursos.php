<?php
namespace kernel\consola\comandos;

use siu\bootstrap;
use Symfony\Component\Console\Input\InputArgument,
    Symfony\Component\Console\Input\InputOption,
    Symfony\Component\Console;
use kernel\kernel;
use kernel\util\manejador_archivos;
use kernel\error_kernel;

class compilar_recursos extends comando_kernel
{
	protected $input; //Console\Input\InputInterface
    /**
     * @var Console\Output\OutputInterface    
     */
    protected $output; 
    
    protected $path_destino;

	protected function configure()
	{
		parent::configure();
        $this
        ->setName('compilar_recursos')
		->setDescription('Compila los recursos js y css a una carpeta.')
		->addArgument("path", InputArgument::OPTIONAL, "Path destino", $this->path_destino)
        ->setHelp(sprintf(
				'%sCompila los recursos js y css del sistema.%s',
				PHP_EOL, 
				PHP_EOL
		));
    }

    protected function execute(Console\Input\InputInterface $input, Console\Output\OutputInterface $output)
	{
        $this->input = $input;
        $this->output = $output;

		$this->mostrar_mensaje('borrando cache de twig');
		$this->borrar_cache_twig();
		$this->path_destino = $input->getArgument('path');
        $namespaces = $this->get_namespaces();
        $recursos = array(
            'comun' => array(),
            'pagelets' => array()
        );
		
        foreach ($namespaces as $id => $dir) {
            $path_ns = $dir."/$id";
            $recursos['www'][$id] = $this->compilar_www($path_ns);
            $recursos['comun'][$id] = $this->compilar_comun($path_ns);
            $recursos['pagelets'][$id] = $this->compilar_pagelets($path_ns);
        }
//		print_r($recursos['pagelets']);die();
//        $recursos = $this->remover_repetidos($recursos);
        $this->crear_compilacion($recursos);
        $this->mostrar_mensaje('fin de compresión');
    }
	
	protected function borrar_cache_twig()
	{
        //obtengo path directorio temporal
        $dir_temp = bootstrap::get_dir_instalacion() . "/temp/";
        //obtengo bloques de acceso
        $accesos = kernel::proyecto()->get("accesos");
        //obtengo los ids de los bloques de acceso
        $accesos_id = array_keys($accesos);
        //por cada bloque de acceso borro los archivos temporales
        foreach($accesos_id as $acceso_id){
            $dir_temp_acceso = $dir_temp . $acceso_id;
            try{
                manejador_archivos::eliminar_directorio($dir_temp_acceso, true, true);
            }
            catch (\Exception $e){
                $this->mostrar_mensaje("<comment>No se pudo borrar el directorio '{$dir_temp_acceso}', el mismo no existe o no se tiene permisos para eliminarlo.</comment>");
            }
        }
	}
	
	protected function get_namespaces()
	{
		return kernel::localizador()->get_namespaces();
	}
    
    protected function compilar_www($dir)
    {
        $dir = $dir."/www";
        $rs = array();
        $rs = array_merge($rs, $this->get_archivos_dir($dir.'/js', '/.*\.js/', $dir));
        $rs = array_merge($rs, $this->get_archivos_dir($dir.'/css', '/.*\.css/', $dir));
        $rs = array_merge($rs, $this->get_archivos_dir($dir.'/img', '/.*/', $dir));

        return $rs;
    }
    
    /**
     * Devuelve todos los archivos de un directorio que cumplen con el patron 
     * recursivamente
     * @param type $dir 
     */
    protected function get_archivos_dir($dir, $patron, $remove = null)
    {
        $archivos = array();
        
        if (is_dir($dir)) {

            try{
                $archivos = manejador_archivos::get_archivos_directorio($dir, $patron, true);
            }
            catch(error_kernel $e){
                $archivos = array();
            }

            if (isset($remove)) {
                $rs = array();
                foreach ($archivos as $archivo) {
                    $rs[$archivo]['absoluto'] = $archivo;
                    $rs[$archivo]['relativo'] = substr($archivo, strlen($remove) + 1);
                }
                return $rs;                
            }
        }
        
        return $archivos;
    }
    
    protected function crear_compilacion($recursos)
    {
        foreach ($recursos['comun'] as $ns => $archivos) {
			foreach ($archivos as $archivo) {
				$tipo = $this->get_extension($archivo);
				$nombre = basename($archivo);
				$path_nuevo = "$this->path_destino/$ns/operaciones/_comun/$tipo/$nombre";
				$this->guardar_archivo($archivo, $path_nuevo);
			}
        }
        
		foreach ($recursos['pagelets'] as $ns => $operaciones) {
			foreach ($operaciones as $nombre_op => $pagelets) {
				foreach ($pagelets as $nombre_pl => $archivos) {
					foreach ($archivos as $archivo) {
						$nombre = basename($archivo);
						$path_nuevo = "$this->path_destino/$ns/operaciones/$nombre_op/$nombre_pl/$nombre";
						$this->guardar_archivo($archivo, $path_nuevo, true, true);
					}
				}
			}
		}

        foreach ($recursos['www'] as $ns => $www) {
            foreach ($www as $key => $archivo) {
                $abs = $archivo['absoluto'];
                $rel = $archivo['relativo'];
                
                $nombre = basename($abs);
                $ext = $this->get_extension($abs);
                $path_nuevo = "$this->path_destino/$ns/$rel";
                if ($ext == 'js' || $ext == 'css') {
                    $this->guardar_archivo($abs, $path_nuevo, true, true);
                } else {
                    $this->guardar_archivo($abs, $path_nuevo, false, true);
                }
            }
        }
    }
    
    protected function guardar_archivo($archivo, $path_nuevo, $comprimir = true, $absoluto = false)
    {
        if (!$absoluto) {
            $archivo = kernel::localizador()->path_recurso($archivo);    
        }
        
        manejador_archivos::crear_archivo_con_datos($path_nuevo, '');        
        if ($comprimir) {
			$encoding = kernel::proyecto()->get_encoding();
            $cmd = "yui-compressor $archivo --charset $encoding -o $path_nuevo";
            exec($cmd);
        } else {
            copy($archivo, $path_nuevo);
        }
    }
    
    protected function get_extension($archivo)
    {
        $partes = pathinfo($archivo);
		
        return (isset($partes['extension'])) ? $partes['extension'] : '';
    }
    protected function remover_repetidos($recursos)
    {
        $rs = array();
        foreach ($recursos['comun'] as $archivos) {
            $rs = array_merge($rs, $archivos);
        }
        $recursos['comun'] = array_unique($rs);
        
        $rs = array();
        foreach ($recursos['pagelets'] as $namespace) { // cotiene los pagelets que hay en un namespace
            foreach ($namespace as $op => $pagelets) {
                foreach ($pagelets as $key => $archivos) {
                    if (isset($rs[$op][$key])) {
                        $rs[$op][$key] = array_unique(array_merge($rs[$op][$key], $archivos));
                    } else {
                        $rs[$op][$key] = $archivos;
                    }
                }
            }
        }
        
        $recursos['pagelets'] = $rs;
        
        return $recursos;
    }
        
    protected function compilar_comun($dir)
    {
        $tipos = array('js', 'css');
        $rs = array();
        foreach ($tipos as $tipo) {
            $relativo = "operaciones/_comun/$tipo";
            $archivos = $this->lista($dir."/$relativo", $tipo);
            foreach ($archivos as $archivo) {
                $rs[] = "$dir/$relativo/$archivo";
            }
        }
        return $rs;
    }
    
    protected function compilar_pagelets($dir)
    {
        $rs = array();
        $tipos = array('js', 'css');
        $operaciones = $this->get_operaciones($dir);
		
        foreach ($operaciones as $op) {
			if ($op == '_comun') { // los pagelets están en /pagelets
				$op = $op.'/pagelets';
			}
            $pagelets = $this->get_pagelets($dir."/operaciones/$op");
            foreach ($pagelets as $pagelet) {
                foreach ($tipos as $tipo) {
                    $relativo = "operaciones/$op/$pagelet";
                    $archivos = $this->lista($dir."/$relativo", $tipo);
                    foreach ($archivos as $archivo) {
                        $rs[$op][$pagelet][] = "$dir/$relativo/$archivo";
                    }
                }
            }
        }
        return $rs;
    }
    
    protected function get_operaciones($dir)
    {
        try{
            $paths = manejador_archivos::get_subdirectorios($dir.'/operaciones');
        }
        catch(error_kernel $e){
            $paths = array();
        }

        $rs = array();
        
        foreach ($paths as $path_op) {
            $nombre = basename($path_op);
			$rs[] = $nombre;
        }
        
        return $rs;
    }
    
    protected function get_pagelets($dir)
    {
		if (! is_dir($dir)) { // puede que no exista. por ej en el caso de pers/operaciones/_comun/pagelets
			return array();
		}

        try{
            $paths = manejador_archivos::get_subdirectorios($dir);
        }
        catch(error_kernel $e){
            $paths = array();
        }

        $rs = array();
		foreach ($paths as $path) {
			$rs[] = basename($path);
		}
		return $rs;
    }

    /**
     * Devuelve la lista de archivos js de un directorio
     * @param string $dir 
     * @param string $tipo 
     */
    protected function lista($dir, $tipo)
    {
        $rs = array();
        
        if (is_dir($dir)) {

            try{
                $archivos = manejador_archivos::get_archivos_directorio($dir, "/.*\.$tipo/");
            }
            catch(error_kernel $e){
                $archivos = array();
            }

            foreach ($archivos as $full_path) {
                $rs[] = basename($full_path);
            }
        } else {
            $this->mostrar_mensaje("-- omitiendo directorio $dir");
        }        
        
        return $rs;
    }
    
    protected function mostrar_mensaje($mensaje)
    {
        $this->output->writeln($mensaje);    
    }
}

?>
