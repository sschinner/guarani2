kernel.renderer.registrar_pagelet('listado_encuestas', function(info) {
    var id = '#' + info.id;

    return {
        onload: function() {

            /* Botón ver */

            $( id ).on( "click", 'button.ver', function(event) {
                event.preventDefault();

                var btn_ver = $(this);
                $(btn_ver).prop( "disabled", true );

                var anonima = $(btn_ver).data('anonima');

                if(anonima){//Si la encuesta es anonima le pido el código de recuperación
                    ingresar_codigo_recuperacion($(btn_ver).data('habilitacion'), $(btn_ver).data('formulario'), $(btn_ver).data('codigoExterno'), $(btn_ver).data('password'), anonima, btn_ver);
                }
                else{//Si no es anonima directamente muestro la encuesta
                    ver_encuesta_respondida($(btn_ver).data('habilitacion'), $(btn_ver).data('formulario'), $(btn_ver).data('codigoExterno'), $(btn_ver).data('password'), anonima, '', '', btn_ver);
                }

            });

            $( id ).on( "click", 'button#js-ver-anonima', function(event) {
                event.preventDefault();

                var btn_ver = $(this);

                /* Valido el código de recuperación */
                var codigo_recuperacion = $("input[name='codigo_recuperacion']").val().trim();
                var error_codigo_recuperacion = false;
                $("#js-control-group-codigo-recuperacion").removeClass('error');
                $("#js-help-inline-codigo-recuperacion").hide();

                var regexp_cod_rec = /^[0-9]+$/;

                if(codigo_recuperacion == ""){//Si el codigo de recuperacion es vacio
                    error_codigo_recuperacion = info.mensajes.debe_ingresar_codigo_recuperacion;
                }
                else if(!regexp_cod_rec.test(codigo_recuperacion)){//Si el codigo de recuperacion no es un entero
                    error_codigo_recuperacion = info.mensajes.codigo_recuperacion_debe_ser_entero;
                }
                /*else if(codigo_recuperacion.length != 10){//El codigo de recuperacion debe tener 10 caracteres
                    error_codigo_recuperacion = info.mensajes.codigo_recuperacion_error_longitud;
                }*/

                if(error_codigo_recuperacion){
                    $("#js-control-group-codigo-recuperacion").addClass('error');
                    $("#js-help-inline-codigo-recuperacion").text(error_codigo_recuperacion).show();
                    return false;
                }

                /* Valido el hash validación */
                var hash_validacion = $("input[name='hash_validacion']").val().trim();
                var error_hash_validacion = false;
                $("#js-control-group-hash-validacion").removeClass('error');
                $("#js-help-inline-hash-validacion").hide();

                var regexp_hash_val = /^[a-zA-Z0-9]+$/;

                if(hash_validacion == ""){//Si el hash de validación es vacio
                    error_hash_validacion = info.mensajes.debe_ingresar_hash_validacion;
                }
                else if(!regexp_hash_val.test(hash_validacion)){//Si el hash de validación no es alfanumerico
                    error_hash_validacion = info.mensajes.hash_validacion_debe_ser_alfanumerico;
                }

                if(error_hash_validacion){
                    $("#js-control-group-hash-validacion").addClass('error');
                    $("#js-help-inline-hash-validacion").text(error_hash_validacion).show();
                    return false;
                }

                $(btn_ver).prop( "disabled", true );
                var habilitacion = $("input[name='habilitacion']").val();
                var formulario = $("input[name='formulario']").val();
                var codigo_externo = $("input[name='codigo_externo']").val();
                var password = $("input[name='password']").val();
                var anonima = $("input[name='anonima']").val();

                ver_encuesta_respondida(habilitacion, formulario, codigo_externo, password, anonima, codigo_recuperacion, hash_validacion, btn_ver);

            });

            function ingresar_codigo_recuperacion(p_habilitacion, p_formulario, p_codigo_externo, p_password, p_anonima, btn_ver){

                kernel.ajax.call(info.url_codigo_recuperacion, {
                    type: 'POST',
                    data: {
                        habilitacion: p_habilitacion,
                        formulario: p_formulario,
                        codigo_externo: p_codigo_externo,
                        password: p_password,
                        anonima: p_anonima
                    },
                    success: function(paquete) {

                        if(paquete.hubo_error){

                            kernel.ui.show_mensaje(paquete.mensaje, {tipo: 'alert-error'});

                        }
                        else{

                            $("#codigo_recuperacion").html(paquete.cont).modal();

                        }

                        $(btn_ver).prop( "disabled", false );
                    }
                });

            }

            function ver_encuesta_respondida(p_habilitacion, p_formulario, p_codigo_externo, p_password, p_anonima, p_codigo_recuperacion, p_hash_validacion, btn_ver){

                kernel.ajax.call(info.url_ver, {
                    type: 'POST',
                    data: {
                        habilitacion: p_habilitacion,
                        formulario: p_formulario,
                        codigo_externo: p_codigo_externo,
                        password: p_password,
                        anonima: p_anonima,
                        codigo_recuperacion: p_codigo_recuperacion,
                        hash_validacion: p_hash_validacion
                    },
                    success: function(paquete) {

                        if(paquete.hubo_error){

                            kernel.ui.show_mensaje(paquete.mensaje, {tipo: 'alert-error'});

                        }
                        else{

                            $('#codigo_recuperacion').modal('hide')
                            $("#encuesta_respondida_kolla").html(paquete.cont).modal();

                        }

                        $(btn_ver).prop( "disabled", false );
                    }
                });

            }

            /* Modal */
            $( id ).delegate( "#cerrar_modal1", "click", function() {
                $('#encuesta_respondida_kolla').modal('hide');
            });

            $( id ).delegate( "#cerrar_modal2", "click", function() {
                $('#codigo_recuperacion').modal('hide');
            });

        }
    };
});

