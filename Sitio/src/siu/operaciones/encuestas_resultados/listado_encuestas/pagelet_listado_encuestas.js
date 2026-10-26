kernel.renderer.registrar_pagelet('listado_encuestas', function (info) {
    var id = '#' + info.id;

    return {
        onload: function () {

            $('#tipo_encuesta').tooltip();

        }
    }

});