<?php

namespace kernel\acceso;

use kernel\kernel;
use kernel\util\config;

class factory_perfil
{
    static protected $instancia;
    static function instancia()
    {
        if (! isset(self::$instancia)) {
            self::$instancia = new factory_perfil();
        }

        return self::$instancia;
    }

    /**
     * @param string $id id del perfil
     * @param bool|string $id_bloque_acceso id del acceso activo
     * @return interface_perfil
     */
    function construir($id, $id_bloque_acceso = false)
    {
        if (kernel::get_tipo_archivos_acceso() == kernel::$tipo_archivo_acceso_php) {
            return $this->construir_acceso_desde_php($id, $id_bloque_acceso);
        } else {
            return $this->construir_acceso_desde_xml($id);
        }
    }

    protected function construir_acceso_desde_php($id, $id_bloque_acceso)
    {
        $perfil = new perfil_php($this->get_conf_php("conf/acceso/acc_$id.php"));
        $man_op_inactivas = new manager_operaciones_inactivas($id, $id_bloque_acceso);
        $perfil->set_manager_operaciones_inactivas($man_op_inactivas);
        return $perfil;
    }

    protected function construir_acceso_desde_xml($id)
    {
        $path = $this->armar_path_absoluto_xml("conf/acceso/acc_$id.xml");
        $content = $this->get_conf_xml_contents($path);
        $xml = new \SimpleXMLElement($content);
        return new perfil_xml($xml);
    }

    protected function get_conf_php($path)
    {
        $archivos = kernel::localizador()->encontrar_archivos($path);
        $apc_enabled = extension_loaded('apc');
        $apc_key = md5(implode('__', $archivos));

        if ($apc_enabled && kernel::proyecto()->get_produccion()) {
            $content = \apc_fetch($apc_key);
        }

        if (! isset($content) || $content === false) {
            $content = array();
            foreach ($archivos as $path) {
                $conf_ns = config::load($path);
                $content = array_replace_recursive($content, $conf_ns);
            }
            if ($apc_enabled && kernel::proyecto()->get_produccion()) {
                \apc_store($apc_key, $content, 600);
            }
        }

        return $content;
    }

    protected function get_conf_xml_contents($path)
    {
        $apc_enabled = extension_loaded('apc');
        $apc_key = md5($path);

        if ($apc_enabled) {
            $content = \apc_fetch($apc_key);
        }

        if (! isset($content) || $content === false) {
            $content = file_get_contents($path);
            if ($apc_enabled && kernel::proyecto()->get_produccion()) {
                \apc_store($apc_key, $content, 600);
            }
        }

        return $content;
    }

    protected function armar_path_absoluto_xml($path_relativo)
    {
		$path_absoluto = kernel::localizador()->path_recurso($path_relativo);
        if (!is_file($path_absoluto)) {
            throw new error_kernel("FACTORY PERFIL: no existe el archivo de perfil '$path_absoluto'");
        }
        
        return $path_absoluto;
    }
}

?>
