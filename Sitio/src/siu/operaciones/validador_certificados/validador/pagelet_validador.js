kernel.renderer.registrar_pagelet('validador', function (info) {
    var id = '#' + info.id;

    return {

        onload: function () {

            if (info.codigo_validacion_focus) {
                $(id + " #codigo_valid").focus();
            }

            $(id + ' #guarani_form_validar').submit(function () {

                var reg = new RegExp('^[0-9]{14}$');
                var codigo_validacion = $(id + ' #codigo_valid').val();
                $(id + " #codigo_valid_error").remove();

                if (codigo_validacion != "") {

                    if (reg.test(codigo_validacion)) {//Codigo de validacion valido
                        
                        $(id + "#control_group_codigo_valid").removeClass('error');

                    } else {//Codigo de validacion invalido

                        $(id + " #codigo_valid").after('<div id="codigo_valid_error" class="alert alert-error"><button type="button" class="close" data-dismiss="alert">&times;</button>' + info.mensajes.error_codigo_validacion_invalido + '</div>');
                        $(id + " #control_group_codigo_valid").addClass('error');
                        $(id + " #codigo_valid").prop("readonly", false);
                        $(id + " #codigo_valid").focus();
                        return false;

                    }

                } else {
                    $(id + " #codigo_valid").after('<div id="codigo_valid_error" class="alert alert-error"><button type="button" class="close" data-dismiss="alert">&times;</button>' + info.mensajes.error_debe_ingresar_codigo_validacion + '</div>');
                    $(id + " #control_group_codigo_valid").addClass('error');
                    $(id + " #codigo_valid").prop("readonly", false);
                    $(id + " #codigo_valid").focus();
                    return false;
                }

            });
        }
    }
})
