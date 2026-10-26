kernel.renderer.registrar_pagelet('encuestas', function(info) {
    var id = '#' + info.id;

    return {
        onload: function() {

            $( id ).delegate( "#cerrar_modal", "click", function() {
                $('#estructura_encuesta_kolla').modal('hide');
            });

            $(".select-encuestas").on('change', function(){

                var encuesta = $(this).data('encuesta');
                var encuesta_kolla = $(this).data('encuestaKolla');

                $(this).find("option[value='']").remove();
                //Habilito el boton de ver encuesta de Kolla.
                $("#boton-ver-encuesta-"+encuesta).prop( "disabled", false );

                if(encuesta_kolla == $(this).val()){
                    //Si selecciona la misma encuesta de Kolla que ya tenia asignada no lo dejo guardar...
                    $("#boton-vincular-encuesta-"+encuesta).prop( "disabled", true );
                }
                else{
                    //Si selecciona otra diferente lo dejo guardar...
                    $("#boton-vincular-encuesta-"+encuesta).prop( "disabled", false );
                }

            });

            $(".ver").on('click', function(){
                var encuesta = $(this).data('encuesta');
                var encuesta_kolla = $("select#select-encuesta-"+encuesta).val();

                var btn_ver = $(this);
                $(btn_ver).prop( "disabled", true );
                $("#mensaje-vincular").hide();
                $('.control-group').removeClass('error');

                kernel.ajax.call(info.url_ver, {
                    type: 'POST',
                    data: {
                        encuesta_kolla_a_ver: encuesta_kolla
                    },
                    success: function(paquete) {

                        if(paquete.hubo_error){

                            $("#mensaje-vincular").text(paquete.mensaje).removeClass("alert-success").addClass("alert-error").fadeIn("slow");
                            $("select#select-encuesta-"+encuesta).parents('.control-group').addClass('error');

                        }
                        else{

                            $("#estructura_encuesta_kolla").html(paquete.cont).modal();

                        }

                        $(btn_ver).prop( "disabled", false );
                    }
                });

            });

            $(".vincular").on('click', function(){

                var encuesta = $(this).data('encuesta');
                var encuesta_kolla_a_vincular = $("select#select-encuesta-"+encuesta).val();

                var btn_vincular = $(this);
                $(btn_vincular).prop( "disabled", true );
                $("#mensaje-vincular").hide();
                $('.control-group').removeClass('error');

                kernel.ajax.call(info.url_vincular, {
                    type: 'POST',
                    data: {
                        encuesta: encuesta,
                        encuesta_kolla_a_vincular: encuesta_kolla_a_vincular
                    },
                    success: function(paquete) {

                        if(paquete.hubo_error){

                            $("#mensaje-vincular").text(paquete.mensaje).removeClass("alert-success").addClass("alert-error").fadeIn("slow");
                            $("select#select-encuesta-"+encuesta).parents('.control-group').addClass('error');
                            $(btn_vincular).prop( "disabled", false );

                        }
                        else{

                            $("select#select-encuesta-"+encuesta).data('encuestaKolla', encuesta_kolla_a_vincular);
                            $(btn_vincular).prop( "disabled", true );
                            $("#mensaje-vincular").text(paquete.mensaje).removeClass("alert-error").addClass("alert-success").fadeIn("slow");

                        }
                    }
                });

            });

        }
    }

});