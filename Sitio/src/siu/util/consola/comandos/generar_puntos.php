<?php
namespace siu\util\consola\comandos;

use Symfony\Component\Console\Input\InputArgument,
    Symfony\Component\Console\Input\InputOption,
    Symfony\Component\Console;

use kernel\kernel;
use kernel\error_kernel;
use kernel\util\manejador_archivos;
use kernel\util\clase_datos;
use siu\guarani;

class generar_puntos extends comando_guarani{

	protected function configure()
	{
        $this
        ->setName('generar_puntos')
		->setDescription('Compilar puntos de control.')
				
		->setDefinition(array(
            new InputArgument('acceso', InputArgument::REQUIRED, 'ID del bloque de acceso a generar puntos de control'),
			new InputArgument('personalizacion', InputArgument::REQUIRED, 'ID de la personalización a generar puntos de control'),
        ))
        /*
		->setDefinition(array(
            new InputArgument('x', InputArgument::REQUIRED, 'First addend'),
            new InputArgument('y', InputArgument::REQUIRED, 'Second addend'),
            new InputOption('round', null, null, 'Round result')
        ))*/
        ->setHelp(sprintf(
				'%sCompila puntos de control del sistema.%s',
				PHP_EOL, 
				PHP_EOL
		));
    }

    protected function execute(Console\Input\InputInterface $input, Console\Output\OutputInterface $output)
	{
		$punto_acceso = $input->getArgument('acceso');
		$pers = $input->getArgument('personalizacion');
		if ($punto_acceso) {
            $this->bootstrap_kernel($punto_acceso);
        }
		$this->input = $input;
		$this->output = $output;
		
		$existe = false;
		foreach (\kernel\kernel::localizador()->get_namespaces_pers() as $id => $dir) {
			if ($pers === $id) {
				$dir = $dir . '/' . $id . '/modelo/controles/puntos_control';
				$output->write("*****  Generar Puntos: $dir *****", true);
				$this->compilar_puntos($id, $dir);
				$existe = true;
			} 
		}
		if (! $existe) {
			$output->write("No existe la personalización $pers en el punto de acceso $punto_acceso\n");
		}
    }
	
	function compilar_puntos($id_dir, $dir)
	{
		//Si la carpeta donde se guardan los puntos de control no existe la crea.
		if (!file_exists($dir)) {
			mkdir($dir, 0777, true);
		}
		
		if($id_dir == 'siu'){//si es el core
			$extends = "\\siu\\modelo\\controles\\punto_control";
		}
		else{//si es una personalizacion
			$extends = "\\$id_dir\\modelo\\controles\\punto_control_pers";
			$this->generar_punto_control_pers_php($dir, $id_dir);
		};
		
		$sql ="SELECT * FROM par_puntos_control;";
		$puntos = kernel::db()->consultar($sql);
		foreach($puntos as $punto) {
			$usa_ua = false;
			$this->output->write($punto['PUNTO_DE_CONTROL'] . ' - ' . $punto['NOMBRE'],true);
			$pid = $punto['PUNTO_DE_CONTROL'];
			$sql ="SELECT * FROM par_punto_desc_par 
					WHERE punto_de_control = {$pid}
					ORDER BY orden;";
			//-- Procesar parametros --
			$params = kernel::db()->consultar($sql);	
			$lista_parametros = array();
			foreach($params as $id => $param) {
				$lista_parametros[] = $param['NOMBRE'];
				// hacer tipo mas accesible
				if (strpos($param['TIPO'],'varchar')!==false) {
					$temp=array();
					preg_match("/varchar\((?<largo>.*?)\)/",$param['TIPO'],$temp);
					$params[$id]['TIPO'] = 'varchar';
					$params[$id]['LARGO'] = $temp['largo'];
				}
				if ($param['NOMBRE'] == 'unidad_academica') {
					$usa_ua = true;
				}
			}
			
			$path =  $dir."/punto_control_{$pid}.php";

			$clase = new clase_datos("punto_control_{$pid} extends $extends",
										null, "$id_dir\modelo\controles\puntos_control", false);
			$clase->agregar_metodo_datos('utiliza_unidad_academica', $usa_ua);
			$clase->agregar_metodo_datos('lista_parametros', $lista_parametros);
			$clase->agregar_metodo_datos('info', $punto);
			$clase->agregar_metodo_datos('info_parametros', $params);
			$clase->guardar($path);	
		}
	}
	
	function generar_punto_control_pers_php($dir, $id_dir){
		
		$dir_controles = realpath($dir . DIRECTORY_SEPARATOR . '..');
		$punto_control_pers_path = $dir_controles. DIRECTORY_SEPARATOR . 'punto_control_pers.php';
		if(!file_exists($punto_control_pers_path)){
			
			$punto_control_pers_content = "<?php\n";
			$punto_control_pers_content .= "namespace $id_dir\modelo\controles;\n";
			$punto_control_pers_content .= "use siu\modelo\controles\punto_control;\n";
			$punto_control_pers_content .= "abstract class punto_control_pers extends punto_control{\n";	
			$punto_control_pers_content .= "}\n";
			$punto_control_pers_content .= "?>";
			
			file_put_contents($punto_control_pers_path, $punto_control_pers_content);
		}
	} 
}