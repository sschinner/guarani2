<?php
namespace kernel\util;

use kernel\error_kernel;

class clase_datos
{
	private $nombre;
	private $namespace;
	private $static;
	private $path = null;
	private $metodos=array();
	
	function __construct( $nombre, $path = null, $namespace=null, $static=true )
	{
		$this->nombre = $nombre;
		$this->namespace = $namespace;
		$this->static = $static;
		if ( isset( $path ) ) {
			$this->path = $path;
			if ( file_exists( $this->path ) ) {
				$this->cargar_clase();
			}
		}
	}

	function cargar_clase()
	{
		require_once( $this->path );
		$metodos = array();
		$clase = new ReflectionClass( $this->nombre );
		foreach ( $clase->getMethods() as $metodo ){
			$nombre = $metodo->getName();
			$datos = $metodo->invoke( null );
			$this->metodos[ $nombre ] = $datos;
		}
	}

	//-----------------------------------------------------------
	//	Manipulacion de la informacion de la clase
	//-----------------------------------------------------------

	function existe_metodo( $nombre )
	{
		return isset( $this->metodos[ $nombre ] );
	}

	function agregar_metodo_datos($nombre, $datos)
	{
		$this->metodos[ $nombre ] = $datos;
	}

	function eliminar_metodo_datos( $nombre )
	{
		if ( isset( $this->metodos[ $nombre ] ) ) {
			unset( $this->metodos[ $nombre ] );
		} else {
			throw new error_kernel("El metodo '$nombre' no existe");
		}
	}

	function get_datos_metodo( $nombre ) 
	{
		if ( isset( $this->metodos[ $nombre ] ) ) {
			return $this->metodos[ $nombre ];
		} else {
			throw new error_kernel("El metodo '$nombre' no existe");
		}
	}
	
	function set_datos_metodo( $nombre, $datos ) 
	{
		if ( isset( $this->metodos[ $nombre ] ) ) {
			$this->metodos[ $nombre ] = $datos;
		} else {
			throw new error_kernel("El metodo '$nombre' no existe");
		}
	}

	//-----------------------------------------------------------
	//	Generacion
	//-----------------------------------------------------------

	function guardar( $archivo = null )
	{
		if ( ! isset( $archivo ) ) {
			if ( ! isset( $this->path ) )  {
				throw new error_kernel('Es necesario especificar el PATH de la clase que se desea generar');
			} else {
				$archivo = $this->path;	
			}
		}
		return file_put_contents($archivo, $this->generar_php() );
	}

	private function generar_php()
	{
		$php = "<?php\n";
		$php .= $this->get_contenido();
		$php .= "\n?>";
		return $php;	
	}

	function get_contenido()
	{
		$s = $this->static ? 'static' : ''; 
		$php = '';
		if (isset($this->namespace)) {
			$php .= "namespace {$this->namespace};\n";
		}
		$php .= "\nclass $this->nombre\n{\n";
		foreach ( $this->metodos as $metodo => $datos ) {
			$php .= "\t{$s} function $metodo()\n\t{\n";
			$php .= "\t\treturn " . var_export( $datos, true) . ";\n";
			$php .= "\t}\n";
			$php .= "\n";
		}
		$php .= "}\n";
		return $php;
	}
}
?>