<?php
namespace siu;

class bootstrap_rest extends bootstrap
{

    static function cargar($ua=false)
    {
        $es_api_docs = false;
        $bloque_acceso_id = false;

        if (strpos($_SERVER["REQUEST_URI"], "rest/api-docs") !== false) {
            $es_api_docs = true;
        }

        if($ua === false){//si falta el parametro 'ua'
            if(!$es_api_docs){//si no estamos entrando a la URL 'rest/api-docs'
                throw new \Exception("El parámetro 'ua' (Código de la Unidad Académica) es requerido");
            }
        }
        else{//si tenemos el parametro 'ua'
            $config = self::cargar_config_archivo();

            $accesos = $config['accesos'];

            foreach($accesos as $acceso => $bloque){

                if($bloque['ua'] == $ua){
                    $bloque_acceso_id = $acceso;
                    break;
                }

            }

            if((!$bloque_acceso_id) && (!$es_api_docs)){
                throw new \Exception("No existe la ua '{$ua}' dentro del bloque 'accesos' en la configuración");
            }
        }


        if (!isset(self::$instancia)) {
            self::$instancia = new bootstrap();
        }
        self::$instancia->_cargar(false, $bloque_acceso_id);
    }

}