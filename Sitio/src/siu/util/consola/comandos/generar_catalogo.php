<?php
namespace siu\util\consola\comandos;

use Symfony\Component\Console\Input\InputArgument,
    Symfony\Component\Console\Input\InputOption,
    Symfony\Component\Console;

use kernel\util\manejador_archivos;
use kernel\util\clase_datos;
use siu\guarani;
use siu\errores\error_guarani;

class generar_catalogo extends comando_guarani
{
	protected $clase_def = "_info_catalogo";
	protected $info = array();

	protected function configure()
	{
		parent::configure();
        $this
        ->setName('generar_catalogo')
		->setDescription('Compilar catalogo SQL.')
		
        ->setDefinition(array(
            new InputArgument('acceso', InputArgument::REQUIRED, 'ID del bloque de acceso a generar catálogo'),
        ))


		
        /*
		->setDefinition(array(
            new InputArgument('x', InputArgument::REQUIRED, 'First addend'),
            new InputArgument('y', InputArgument::REQUIRED, 'Second addend'),
            new InputOption('round', null, null, 'Round result')
        ))*/
        ->setHelp(sprintf(
				'%sCompila el catalogo de SQLs del sistema.%s',
				PHP_EOL, 
				PHP_EOL
		));
    }

	protected function execute(Console\Input\InputInterface $input, Console\Output\OutputInterface $output)
	{
		$punto_acceso = $input->getArgument('acceso');
		if ($punto_acceso) {
            $this->bootstrap_kernel($punto_acceso);
        }

		foreach (\kernel\kernel::localizador()->get_namespaces_pers() as $id => $dir) {
			$dir = $dir . '/' . $id . '/modelo/datos/db';
			$output->write("*****  Generar CATALOGO: $dir *****", true);
			$this->parsear_archivos($dir, $id);
			$this->generar_clase($dir . '/../' . $this->clase_def . '.php', $id . '\modelo\datos');
		}
		$output->write('OK!', true);

    }

	//----------------------------------------------------------

	function parsear_archivos($dir, $id)
	{
		$this->info = array();
		$archivos = manejador_archivos::get_archivos_directorio($dir);
		foreach($archivos as $archivo) {
			$this->parsear_archivo($archivo, $id);
		}
	}

	function parsear_archivo($archivo, $id)
	{
		echo "$archivo\n";
		$nombre_clase_corto = basename($archivo,'.php');
		$nombre_clase = "\\{$id}\\modelo\\datos\\db\\" . $nombre_clase_corto;
		$clase = new \ReflectionClass($nombre_clase);
		foreach ($clase->getMethods() as $metodo) {
			$nombre_metodo = $metodo->getName();
			if (true || (\strpos($nombre_metodo, 'c__'))!==false) {
				// PARAMETROS
				//$nombre_metodo = substr($nombre_metodo,3);
				$doc = $metodo->getDocComment();
				$doc = $this->parsear_doc_comment($doc);
				$def = $this->parsear_propiedades($doc);
				if(isset($def['parametros'])&&!is_array($def['parametros'])) {
					if($def['parametros']=='') {
						unset($def['parametros']);
					}else{
						$def['parametros'] = array($def['parametros']);
					}
				}
				// PARAMETROS: NULL y NOT NULL
				if(isset($def['param_null'])&&!is_array($def['param_null'])) {
					if($def['param_null']=='') {
						unset($def['param_null']);
					}else{
						$def['param_null'] = array($def['param_null']);
					}
				}
				// La deficion de columnas y NULLS estan correctamente macheadas?
				if(isset($def['parametros']) && isset($def['param_null'])) {
					foreach($def['param_null'] as $null) {
						if(!in_array($null, $def['parametros'])) {
							throw new error_guarani('La columna NULL: ' . $null . ' no esta en la lista de parametros. En el ARCHIVO: ' .
													$archivo . ' METODO: ' . $nombre_metodo);
						}
					}
				}
				//PARAMETROS TIPOS de DATO
				if(isset($def['param_tipo'])&&!is_array($def['param_tipo'])) {
					if($def['param_tipo']=='') {
						unset($def['param_tipo']);
					}else{
						$def['param_tipo'] = array($def['param_tipo']);
					}
				}
				// La deficion de columnas y TIPOS estan correctamente macheadas?
				if(isset($def['parametros']) && isset($def['param_tipo'])) {
					if(count($def['parametros']) != count($def['param_tipo'])) {
						throw new error_guarani('La DEF de parametros y TIPOS no coincide en el ARCHIVO: ' .
												$archivo . ' METODO: ' . $nombre_metodo);
					}
				}
				$this->info[$nombre_clase_corto][$nombre_metodo] = $def;
			}
		}
	}

	function parsear_doc_comment( $com, $sin_tags=true )
	{
	    $com = preg_replace("/(^[\\s]*\\/\\*\\*)
	                                 |(^[\\s]\\*\\/)
	                                 |(^[\\s]*\\*?\\s)
	                                 |(^[\\s]*)
	                                 |(^[\\t]*)/ixm", "", $com);
	    $com = str_replace("\r", "", $com);
	    $com = trim(preg_replace("/([\\t])+/", "\t", $com));
		$com = trim(preg_replace("/\\*\\//", "", $com));
		if ($sin_tags) {
			$com = trim(preg_replace("/@.*/", "", $com));
		}
		return $com;
	}

    function parsear_propiedades($texto)
    {
		$prop = array();
		$linea = explode("\n",$texto);
		foreach($linea as $sentencia){
			if(trim($sentencia) != ""){
				$propiedad = explode(":", trim($sentencia));
				if(count($propiedad)==2){
					$nombre = trim($propiedad[0]);
    	    	    $valor = trim($propiedad[1]);
					if ((\strpos($valor, ','))!== false) {
						$valor = explode(',',$valor);
						foreach(array_keys($valor) as $id) {
							$valor[$id] = trim($valor[$id]);
						}
					} else {
						$valor = trim($valor);
					}
					$prop[$nombre] = $valor;
				}
			}
		}
		return $prop;
    }

	//----------------------------------------------------------

	function generar_clase($path, $namespace)
	{
		$clase = new clase_datos($this->clase_def, null, $namespace);
		ksort($this->info);
		foreach($this->info as $id_clase => $metodos) {
			ksort($metodos);
			foreach($metodos as $id_metodo => $parametros) {
				$clase->agregar_metodo_datos($id_clase.'__'.$id_metodo, $parametros);
			}
		}
		$clase->guardar($path);
	}

}