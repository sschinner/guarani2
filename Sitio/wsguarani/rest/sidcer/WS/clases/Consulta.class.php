<?php

require_once( dirname(__FILE__).'/../config/paths.inc.php' );
require_once( CLASE_BD );

abstract class Consulta
{
  const TODAS_UAS = 'todas';
  const SISTEMA_DEFECTO = 'guarani';
  protected $uas = array();

  protected $parametros = array();
  private $definiciones = array();
  private $definiciones_datos = array();
  private $tipos = array();
  private $opcionales = array();
  private $pedido = null;
  private $metodo_http_requerido = PedidoHTTP::METODO_GET;

  protected $uas_habilitadas = null;
  protected $consulta = '';
  protected $vitalidad_segundos = -1;
  protected $consulta_de_actualizacion = false;
  protected $parametros_por_prepare = false;
  protected $continuar_en_fallo_de_conexion = false;

  abstract protected function armarDefinicion();
  abstract protected function setConsulta();

  public function __construct($unasUas = array(), PedidoHTTP $pedido = null)
  {
    $this->setUas($unasUas);
    $this->armarDefinicion();
    if ($pedido)
    {
        $this->setPedido($pedido);
    }
  }
  
  protected function getUnaSolaFila()
  {
    return false;
  }
  
  protected function getSistemasCompatibles()
  {
      return array( static::SISTEMA_DEFECTO =>true );
  }

  public function getVitalidadSegundos()
  {
      return $this->vitalidad_segundos;
  }
  
  public function setVitalidadSegundos($vitalidad_segundos)
  {
      $this->vitalidad_segundos = $vitalidad_segundos;
  }

  protected function setConsultaDeActualizacion($consulta_de_actualizacion)
  {
      $this->consulta_de_actualizacion = $consulta_de_actualizacion;
  }
  
  protected function esConsultaDeActualizacion()
  {
      return $this->consulta_de_actualizacion;
  }
  
  protected function setParametrosPorPrepare($post_prepare)
  {
      $this->parametros_por_prepare = $post_prepare;
  }
  
  protected function tieneParametrosPorPrepare()
  {
      return $this->parametros_por_prepare;
  }  
  
  public function getMetodoHttpRequerido() {
      return $this->metodo_http_requerido;
  }

  public function setMetodoHttpRequerido($metodo) {
      return $this->metodo_http_requerido = $metodo;
  }
  
  public function getClaseRespuesta()
  {
      return 'JSONRespuesta';
  }

  public function getDefinicionParametros()
  {
      $resultado = array();
      foreach ($this->definiciones as $orden => $valor)
      {
          $tipo = (isset($this->tipos[$valor])?$this->tipos[$valor]:null);
          $resultado[] = array(
              'orden' => $orden,
              'nombre' => $valor,
              'tipo' => $tipo
          );
      }
      return $resultado;
  }

  public function getDefinicionDatosParametros()
  {
      $resultado = array();
      foreach ($this->definiciones_datos as $orden => $valor)
      {
          $tipo = (isset($this->tipos[$valor])?$this->tipos[$valor]:null);
          $resultado[] = array(
              'nombre' => $valor,
              'tipo' => $tipo
          );
      }
      return $resultado;
  }

  public function setDefinicion($orden, $valor, $tipo=null, $requerido=true) 
  {
    if ($orden === null)
    {
      $this->definiciones_datos[$valor] = $valor;	
    }
    else 
    {
      $this->definiciones[$orden] = $valor;	
    }
    if ($tipo != null) 
    {
      $this->tipos[$valor] = $tipo;
    }
    if (!$requerido) {
        $this->opcionales[] = $valor;
    }
  }
  
  protected function controlarUaValida($ua) {
    if (!in_array($ua, $this->uas_habilitadas))
    {
      throw new Exception('No tiene permisos para ver datos de esta unidad_academica');
    }
  }

  public function setUas($unasUas) {
 
    // Si recibo una sola UA (tipo string)
    if (!is_array($unasUas) and !empty($unasUas)) {
        $unasUas = array($unasUas);
    }
    
    // Si no recibo UAs, obtengo todas las que están definidas.
    if (empty($unasUas)) {
        global $bdGuarani;
        $unasUas = array();
        foreach ($bdGuarani as $ua => $unaBase)
        {
          if ($this->esConsultaCompatible(($unaBase['sistema']?$unaBase['sistema']:static::SISTEMA_DEFECTO))) {
            $unasUas[] = $ua;
          }
        }
    }    
    
    // Controlo permisos de usuario sobre UAs
    if (!empty($this->uas_habilitadas))
    {
        foreach ($unasUas as $ua)
        {
            $this->controlarUaValida($ua);
        }  
    }

    $this->uas = $unasUas;
  }

  public function getUas() {
    return $this->uas;
  }  
  
  public function restringirSoloAUas($array_uas)
  {
    if ($array_uas and count($array_uas) > 0)
    {
      $this->uas_habilitadas = $array_uas;
    }
  }
  
  public function setPedido( PedidoHTTP $pedido )
  {
    $this->pedido = $pedido;
    $this->setParametros($this->pedido->getParametros());
    if (!$this->pedido->esMetodo( $this->getMetodoHttpRequerido() )) {
        throw new Exception('El metodo HTTP utilizado es incorrecto');
    }
    
    if ($pedido->esPost())
    {
      $this->setParametrosDatos($pedido->getPostParametros());
    }
    else
    {
      $this->setParametrosDatos($pedido->getParametrosQueryString());
    }
    
  }

  /**
   * Devuelve el objeto del pedido HTTP
   * 
   * @return PedidoHTTP
   */
  public function getPedido()
  {
    return $this->pedido;
  }

  public function esPorPost()
  {
    return !empty($this->definiciones_datos);
  }

  public function setParametros($unosParametros)
  {
    $this->setParametrosConDefinicion($this->definiciones, $unosParametros);
  }

  public function setParametrosDatos($unosParametros)
  {
    $this->setParametrosConDefinicion($this->definiciones_datos, $unosParametros, true);
  }

  private function setParametrosConDefinicion($definicion, $unosParametros, $porNombre = false)
  {
    $cantidad_definidos_maxima = count($definicion);
    $cantidad_definidos_minima = count($definicion) - count($this->opcionales);
    $cantidad_parametros_recibidos = count($unosParametros);
    if ($cantidad_parametros_recibidos <= $cantidad_definidos_maxima and $cantidad_parametros_recibidos >= $cantidad_definidos_minima)
    {
      if ($cantidad_definidos_maxima > 0)
      {
        if ($porNombre)
        {
          foreach ($definicion as $unaDefinicion)
          {
            $this->setParametro($unaDefinicion, $unosParametros[$unaDefinicion]);
          }
        }
        else
        {        	
          foreach ($definicion as $orden => $unaDefinicion)
          {
            $this->setParametro($unaDefinicion, $unosParametros[$orden]);
          }
        }
      }
    }
    else
    {
      throw new Exception('La cantidad de parametros no es correcta.');
    }
  }

  protected function tipoValido($unNombre, $unValor) 
  {
    if ( !isset($this->tipos[$unNombre]) )
    {
      return true;
    }
    else
    {
      $metodo = 'evalua'.$this->tipos[$unNombre];
      return $this->$metodo($unValor);
    }
  }

  public function setParametro($nombre, $valor) 
  {
    if ( in_array($nombre, $this->definiciones) or in_array($nombre, $this->definiciones_datos) )
    {
      if (!$valor and in_array($nombre, $this->opcionales)) {
        $this->parametros[$nombre] = $valor;
      } else {
        if ( $this->tipoValido($nombre, $valor) ) 
        {
          $this->parametros[$nombre] = $valor;
        }
        else
        {
          throw new Exception($nombre.': El valor recibido no es válido.');
        }
      }
    }
    else
    {
      throw new Exception($nombre.': El parametro no existe.');
    }
  }

  protected function getParametros()
  {
      return $this->parametros;
  }
  
  public function getParametro($nombre) 
  {
    if ( in_array($nombre, $this->definiciones) or in_array($nombre, $this->definiciones_datos) )
    {

      return $this->parametros[$nombre];
    }
    else
    {
      throw new Exception($nombre.': El parametro no existe.');
    }
  }


  protected function verificaConsulta() 
  {
    $cant_max_params = (count($this->definiciones) + count($this->definiciones_datos));
    $cant_min_params = ($cant_max_params - count($this->opcionales));
    $cant_params = count($this->parametros);
    return ($cant_params >= $cant_min_params and $cant_params <= $cant_max_params);
  }

  public function esConsultaCompatible($sistema)
  {
      $sistemas_compatibles = $this->getSistemasCompatibles();
      return isset($sistemas_compatibles[$sistema]) and $sistemas_compatibles[$sistema];
  }

  protected function getFetchMode() {
      return PDO::FETCH_ASSOC;
  }

  public function consultar($desconectar_al_consultar = FALSE) 
  {
    global $bdGuarani;

    $resultados = array();
    if ( $this->verificaConsulta() )
    {
      $this->setConsulta();
    }
    else
    {
      throw new Exception('La cantidad de parametros de la consulta no es correcta.');
    }
    //$conexiones = BD::conectar( $this->uas, $this->continuar_en_fallo_de_conexion, $this->getFetchMode());
    //$sistemas_compatibles = $this->getSistemasCompatibles();

    foreach ($this->uas as $ua) 
    {
        
      $sistema = (!isset($bdGuarani[$ua]['sistema'])?static::SISTEMA_DEFECTO:$bdGuarani[$ua]['sistema']);

      if ($this->esConsultaCompatible($sistema))
      {
          $var_consulta = ($sistema == static::SISTEMA_DEFECTO?'consulta':'consulta_'. $sistema);
          
          if (!isset($this->$var_consulta))
          {
              throw new Exception('No hay una consulta definida');
          }
          
          if ($this->$var_consulta != '')
          {
            $consulta = $this->$var_consulta;

                    $res = array();
            try {
                $conexiones = BD::conectar( $ua, $this->getFetchMode());
                $res = $conexiones[$ua]->consultar( $consulta , ($this->tieneParametrosPorPrepare()?$this->getParametros():null) , $this->esConsultaDeActualizacion() ); 
            } catch (PDOConexionException $e) {
                if (!$this->continuar_en_fallo_de_conexion) {
                    throw $e;
                }
            } catch (PDOException $e) {
                throw new PDOConsultaException($e, $ua);
            }
            
            if ($desconectar_al_consultar) {
                $conexiones[$ua]->desconectar();
            }            

            if ($this->esConsultaDeActualizacion())
            {
                $resultados = array_merge(array(array('ua'=> $ua, 'resultado' => $res)), $resultados);
            }
            else
            {
                if (!empty($res))
                {
                    $resultados = array_merge($res, $resultados);
                }
            }
          }
      }
    }

    return $this->filtroSalida($resultados);
  }

  protected function filtroSalida ($unosResultados)
  {

    return $unosResultados;
  }

  public function obtenerRespuesta()
  {
    if ($this->getUnaSolaFila()) {
        return reset($this->consultar());
    }
    return $this->consultar();
  }

  protected function evaluaChar1($unValor)
  {
    return ( strlen($unValor) == 1 );
  }

  protected function evaluaAnio($unValor)
  {
    $unValor = trim($unValor);
    return ctype_digit($unValor);
  }

  protected function evaluaNombreTarea($unValor)
  {
    $validos = array('_', '.', ' ', '-' );
    return ctype_alnum(str_replace($validos, '', $unValor)) and ( strlen($unValor) <= 50 );
  }

  protected function evaluaDate($unValor)
  {
    $validos = array('-');
    return ctype_digit(str_replace($validos, '', $unValor)) and ( strlen($unValor) <= 10 );
  }

  protected function evaluaDateTime($unValor)
  {

    return (false !== strtotime($unValor));
  }

  protected function evaluaInteger($unValor)
  {

    return is_numeric($unValor);
  }

  protected function evaluaHash($unValor)
  {
    return ctype_alnum($unValor) and ( strlen($unValor) <= 255 );
  }
  protected function evaluaAlfanumConGuiones($unValor)
  {
    $validos = array('_', '.', '-' );
    return ctype_alnum(str_replace($validos, '', $unValor)) and ( strlen($unValor) <= 255 );
  }
  protected function evaluaTexto($unValor)
  {
    if (!$this->tieneParametrosPorPrepare())
    {
        throw new Exception("No puede utilizarse el tipo de dato Texto en una consulta no preparada (tieneParametrosPorPrepare() == false).");
    }
    return ( strlen($unValor) <= 255 );
  }
  protected function evaluaTextoSimple($unValor)
  {
    $validos = array('_', '.', ' ', '-' );
    return ctype_alnum(str_replace($validos, '', $unValor)) and ( strlen($unValor) <= 255 );
  }
  
  protected function evaluaNroInscripcion($unValor)
  {

    return ctype_alnum($unValor) and ( is_numeric($unValor) );
  }

  protected function evaluaTipoDocumento($unValor)
  {

    return ( in_array($unValor, array(0, 2, 18, 19, 90, 1) ) );
  }

  protected function evaluaNroDocumento($unValor)
  {
    $validos = array('_', '.', ' ', '-', '/');

    return ctype_alnum(str_replace($validos, '', $unValor)) and ( strlen($unValor) <= 15 );
  }

  protected function evaluaCarrera($unValor)
  {

    return ctype_alnum(str_replace(" ", "", $unValor)) and ( strlen($unValor) <= 5 );
  }

  protected function evaluaTitulo($unValor)
  {

    return ctype_alnum($unValor) and ( strlen($unValor) <= 5 );
  }

  protected function evaluaUnidadAcademica($unValor)
  {
    global $bdGuarani;
    $uaValida = (isset($bdGuarani[$unValor]));
    return ctype_alnum($unValor) and ( strlen($unValor) <= 5 ) and $uaValida or ($unValor == static::TODAS_UAS);
  }
  
  protected function evaluaBase($unValor)
  {
    global $bdGuarani;
    $uaValida = ((isset($bdGuarani[$unValor])) or ($unValor == static::TODAS_UAS));
    return ctype_alnum($unValor) and $uaValida;
  }

  protected function evaluaEstadoTitulo($unValor)
  {
    $unValor = trim(strtolower($unValor));
    $states = array();
    $states['approved_by_responsible']= 'Aprobado por responsable de la oficina de alumnos';
    $states['void']= 'Anulado';
    $states['with_all_certificates']= 'Con todos los certificados';
    $states['in_diplomas_office']= 'En la oficina de tï¿½tulos';
    $states['sent_to_calligrapher']= 'Enviado al calï¿½grafo';
    $states['returned_from_calligrapher']= 'Devuelto por el calï¿½grafo (en oficina de tï¿½tulos)';
    $states['sent_to_sign']= 'Enviado a firmar (por autoridades)';
    $states['returned_from_being_signed']= 'Devuelto de ser firmado (por autoridades)';
    $states['sent_to_ministry']= 'Enviado al ministerio';
    $states['returned_from_ministry']= 'Devuelvo por el ministerio';
    $states['sent_to_signatures_keeper']= 'Enviado al guarda sellos';
    $states['returned_from_signatures_keeper']= 'Devuelto por el guarda sellos';
    $states['pending_student_signature']= 'Pendiente de la firma del alumno';
    $states['signed_by_student']= 'Firmado por el alumno';
    $states['in_faculty']= 'En la facultad';
    $states['delivered']= 'Entregado';
    $states['approved_by_personnel']  = 'Aprobado por personal de la oficina de alumnos';
    $states['new']  = 'Nuevo';
    $states['rejected_by_personnel']  = 'Rechazado por personal de la oficina de alumnos';
    $states['sent_to_sign_by_dean']  = 'Enviado a firmar por el decano de la facultad';
    $states['returned_from_being_signed_by_dean']  = 'Devuelto de ser firmado por el decano de la facultad';
    return isset($states[$unValor]);
  }

  protected function evaluaEstadoTituloOpcional($unValor)
  {
    $unValor = trim($unValor);
    return (($unValor == null) or ($unValor == '') or $this->evaluaEstadoTitulo($unValor));
  }
}
