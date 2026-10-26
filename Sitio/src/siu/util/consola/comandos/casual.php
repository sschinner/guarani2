<?php
namespace siu\util\consola\comandos;

use Symfony\Component\Console\Input\InputArgument,
    Symfony\Component\Console\Input\InputOption,
    Symfony\Component\Console;

use siu\modelo\datos\db\cursada;
use siu\modelo\datos\catalogo;
use siu\guarani;
use kernel\util\manejador_archivos;
use kernel\kernel;

//use kernel\util\db as db;

class casual extends comando_guarani
{
	protected $input; //Console\Input\InputInterface
	protected $output; //Console\Output\OutputInterface

	protected function configure()
	{
        $this
        ->setName('casual')
		->setDescription('Pruebas casuales.')
		->setDefinition(array(
			new InputArgument('acceso', InputArgument::REQUIRED, 'El punto de acceso del cu�l se quiere ejecutar el comando casual')
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
		$this->bootstrap_kernel($punto_acceso);
//		echo sha1(uniqid(rand(0,1000),true)); 
//		echo "\n";
//		exit();
		$this->input = $input;
		$this->output = $output;
		//$this->test_materias();
		//$this->test_comisiones();
		//$this->test_persona();
		//$this->test_login();

		//$this->cargar_notas_cursada();

		//$this->prepare();
		//return;
//		$this->prueba_bug_ifx(); return;
//		$this->prueba_pdf();return;
		
        print_r('aa'); echo "\n";
        print_r(\kernel\kernel::db()->quote('aa'));echo "\n";
		print_r("a'a");echo "\n";
        print_r(\kernel\kernel::db()->quote("a'a"));echo "\n";
		print_r('a"a');echo "\n";
        print_r(\kernel\kernel::db()->quote('a--a'));echo "\n";
		print_r("a�''b");echo "\n";
        print_r(\kernel\kernel::db()->quote("a�''b"));echo "\n";
		die();
//		$parametros = array('legajo'=>3625);
//		$datos = catalogo::consultar('carga_evaluaciones_parciales', 'listado_evaluaciones_parciales', $parametros);	
//		print_r($datos);
	
		return;
		
			$comando = "/home/jb/proyectos/g3w2/trunk/bin/guarani cache procesar_lote --lote=0 --aviso=1 --log &\n";
			//exec($comando);
			echo $comando;
			$stdout='';
			$stderr='';
			manejador_archivos::ejecutar($comando,$stdout,$stderr);
			file_put_contents('err.txt', $stderr);
			file_put_contents('out.txt', $stdout);
		
    }
	
	function prueba_bug_ifx()
	{
		$dsn = "informix:database=unlpam_g3w2;server=ol_virtual;host=localhost;client_locale=es_AR.UTF-8;db_locale=en_US.819;service=1526;protocol=olsoctcp;EnableScrollableCursors=1;TRANSLATIONDLL=/opt/informix/lib/esql/igo4a304.so";
		//      informix:database=unlpam_g3w2;server=ol_virtual;host=localhost;client_locale=en_us.utf8;db_locale=en_us.819;service=1526;protocol=olsoctcp;EnableScrollableCursors=1
		//$db = new \PDO($dsn, 'dba', 'dba');
		$params = array(
			"database"=>"unlpam_g3w2",
			"host"=>"localhost",
			"server"=>"ol_virtual",
			//"client_locale"=>"en_us.utf8",
			"client_locale"=>"en_us.cp1252",
			"db_locale"=>"en_us.819",
			"service"=>"1526",
			"protocol"=>"olsoctcp",
			"pdo_user"=>"dba",
			"pdo_passwd"=>"dba",
			"user"=>"dba",
			"passwd"=>"dba",
			"EnableScrollableCursors"=>"1",
			"TRANSLATIONDLL"=>"/opt/informix/lib/esql/igo4a304.so"
		);
		$conn = array('kernel\util\db\db_informix'=>array(), 'kernel\util\db\db_pdo'=>array("vendor"=>"informix"), 'kernel\util\db\db_pdo_odbc'=>array("vendor"=>"odbc"));
		foreach($conn as $k=>$v) {
			echo "\n------------------------------------\nconexion ".$k."\n";
			$db = new $k(array_merge($params, $v));
			
			try {
			
				$db->ejecutar("CREATE TABLE ticket82 ( name VARCHAR(2) );");
				$db->ejecutar("INSERT INTO ticket82 VALUES ('aa');");

				$value = $db->consultar("select name from ticket82;");
				//$value = $statement->fetchAll(\PDO::FETCH_ASSOC);
				echo "1. expected 'aa' got '{$value[0]['NAME']}'\n";

				@$db->ejecutar("update ticket82 set name='áa';");
				$value = @$db->consultar("select name from ticket82;");
				//$value = $statement->fetchAll(\PDO::FETCH_ASSOC);
				echo "2. expected 'áa' got '{$value[0]['NAME']}'\n";

				@$db->ejecutar(utf8_decode("update ticket82 set name='áa';"));
				$value = @$db->consultar("select name from ticket82;");
				//$value = $statement->fetchAll(\PDO::FETCH_ASSOC);
				echo "3. expected 'áa' got '{$value[0]['NAME']}'\n";

				@$db->ejecutar("ALTER TABLE ticket82 MODIFY (name varchar(3));");
				$value = @$db->consultar("select name from ticket82;");
				//$value = $statement->fetchAll(\PDO::FETCH_ASSOC);
				echo "4. expected 'áa' got '{$value[0]['NAME']}'\n";

				@$db->ejecutar("ALTER TABLE ticket82 MODIFY (name varchar(15));");
				@$db->ejecutar("update ticket82 set name='aP.Inglés09 aaa';");
				$value = @$db->consultar("select name from ticket82;");
				//$value = $statement->fetchAll(\PDO::FETCH_ASSOC);
				echo "5. expected 'aP.Inglés09 aaa' got '{$value[0]['NAME']}'\n";

				@$db->ejecutar(utf8_decode("update ticket82 set name='aP.Inglés09 aaa';"));
				$value = @$db->consultar("select name from ticket82;");
				//$value = $statement->fetchAll(\PDO::FETCH_ASSOC);
				echo "6. expected 'aP.Inglés09 aaa' got '{$value[0]['NAME']}'\n";

				@$db->ejecutar("DROP TABLE ticket82;");
			}catch(\Exception $e) {
				echo "ERROR: ".$e->getMessage();
				$db->ejecutar("DROP TABLE ticket82;");
			}
		}
		return;
	}
	
	function prueba_pdf()
	{
		include '/home/andres/proyectos/g3w2/trunk/src/siu/lib/ezpdf/class.ezpdf.php';
//		include 'pdf-php/class.ezpdf.php';

		$pdf = new \Cezpdf('a4','portrait');
//		$pdf->selectFont("/home/andres/proyectos/g3w2/trunk/src/siu/util/consola/comandos/pdf-php/fonts/Courier.afm");
		$pdf->selectFont("/home/andres/Downloads/fonts/pdf-php/fonts/Helvetica.afm");
		$pdf->selectFont(guarani::dir()."/lib/ezpdf/fonts/Helvetica.afm");
		$pdf->ezText(utf8_decode("hólo"),0,array('justification'=>'centre'));
		ob_start(); // Start output buffering
		$pdf->ezStream();
		$content = ob_get_contents();
		ob_end_clean();
		file_put_contents('salida.pdf', $content);
		die();
	}
	
	function prepare()
	{
		$sql = "execute procedure sp_matInscCurAlu(':ua', '".
													":carrera','".
													":legajo','".
													":nroinscripcion','".
													":plan','".
													":version','".
													":recursar','".
													":comisionesactuales')";		
		$parametros = array (
		':carrera' => '532',
		':legajo' => '6765',
		':nroinscripcion' => '5-4798',
		':plan' => '53211',
		':version' => '1',
		':recursar' => 'N',
		':comisionesactuales' => 'S',
		':ua' => 5,
		);		
			$stm = \kernel\kernel::db()->conexion()->prepare($sql);
			foreach($parametros as $id => $param) {
				$stm->bindParam($id, $param);
			}
			$stm->execute();
			var_dump($stm);
            $datos = $stm->fetchAll(\PDO::FETCH_BOTH);
			//var_dump($stm->errorInfo());
			print_r($datos);
	}
	
	function test_comisiones()
	{
		$parametros = array('carrera' => '01',
							'legajo' => '01-34375567-07',
							'materia' => '11201');
		//$datos = catalogo::consultar('inscripcion_cursada', 'lista_comisiones_abiertas', $parametros);
		$datos2 = catalogo::consultar('inscripcion_cursada', 'lista_comisiones', $parametros);
		print_r($datos2);
        $this->output->write('ok',true);
	}

    function cargar_notas_cursada()
	{
		$parametros = array('_ua' => 'VET',
							'nro_inscripcion' => 'VET-67');
		//$datos = catalogo::consultar('carga_notas_cursada', 'lista_actas_abiertas_docente', $parametros);
		//var_export($datos);
		$parametros = array('_ua' => 'VET',
							'acta' => '1768');
		$datos = catalogo::consultar('carga_notas_cursada', 'acta_cabecera', $parametros);
		var_export($datos);
//		$parametros = array('_ua' => 'VET',
//							'acta' => '1768',
//							'folio' => '5');
//		$datos = catalogo::consultar('carga_notas_cursada', 'acta_renglones_folio', $parametros);
//		var_export($datos);
        //$this->output->write('ok',true);
	}
	
	function test_materias()
	{
		$datos = guarani::cursada()->info__lista_materias();
		print_r($datos);
    	$result = 'OK!';
        $this->output->write($result,true);
	}
	
	function test_materias2()
	{
		//execute procedure sp_matInscCurAlu('01','01','01-26586758-08','N' )
		$parametros = array('ua' => '01', 
							'carrera' => '01',
							'legajo' => '01-11721038-00',
							'recursar' => 'X');
		$datos = catalogo::consultar('cursada', 'materias', $parametros);
		print_r($datos);
    	$result = 'OK!';
        $this->output->write($result,true);
	}
	
	function test_comisiones2()
	{
		$parametros = array('ua' => '01', 'materia' => '11001');
		$datos = catalogo::consultar('cursada', 'comisiones_abiertas', $parametros);
		print_r($datos);
    	$result = 'OK!';
        $this->output->write($result,true);
	}

	function test_persona()
	{
		$parametros = array('ua' => '01', 'nro_inscripcion' => '01-38');
		//$datos = catalogo::consultar('persona', 'datos_basicos', $parametros);
		//$datos = catalogo::consultar('persona', 'perfiles', $parametros);
		$datos = catalogo::consultar('persona', 'carreras', $parametros);
		print_r($datos);
    	$result = 'OK!';
        $this->output->write($result,true);
	}
	
	function test_login()
	{
		$id = '002';
		$clave = '002';
		$parametros = array('id' => $id, 'clave' => $clave);		
		$datos = catalogo::consultar('persona', 'login', $parametros);
		print_r($datos);
		$parametros = array('id' => $id);		
		$datos = catalogo::consultar('persona', 'login_usuario_nro_inscripcion', $parametros);
		print_r($datos);
	}


	function test_inscripciones()
	{
		$datos = catalogo::consultar('inscripcion_cursada','info_inscripciones',
								array('nro_inscripcion' => '﻿01-1527'));
		print_r($datos);
	}


}