<?php

namespace personalizacionPOSGRADO\modelo\entidades;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

class persona extends \siu\modelo\entidades\persona {

    function get_solo_nombre() {
        return $this->datos_basicos['NOMBRES'];
    }

    function get_solo_apellido() {
        return $this->datos_basicos['APELLIDO'];
    }

}
