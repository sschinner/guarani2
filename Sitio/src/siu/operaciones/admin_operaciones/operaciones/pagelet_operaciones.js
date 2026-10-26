kernel.renderer.registrar_pagelet('operaciones', function(info) {
    var id = '#' + info.id;

    return {

        onload: function() {

            $(id+" #guardar").prop( "disabled", true );

            $(id+' input[type="radio"]').on( "change", function(){

                var hubo_cambios = false;

                $(id+' input[type="radio"][checked]').each(function(){

                    if($(this).val() != $(id+' input[name="'+$(this).attr('name')+'"]:checked').val()){
                        hubo_cambios = true;
                        return false;
                    }

                });

                if(hubo_cambios){
                    $(id+" #guardar").prop( "disabled", false );
                }
                else{
                    $(id+" #guardar").prop( "disabled", true );
                }

            });

            $(id+" #form_operaciones").on("submit", function(event){

                var $form = $(this);
                var data  = $form.serializeArray();

                kernel.ajax.call($form.attr('action'), {
                    type: 'post',
                    data: data,
                    historia: false,
                    success: function(response) {

                        if(response.info_estado.exitoso){
                            kernel.ui.show_mensaje(response.info_estado.mensaje);
                            $(id+" #guardar").prop( "disabled", true );

                            $(id+' input[type="radio"]:checked').each(function(){

                                if(!$(this).attr('checked')){
                                    $(id+' input[name="'+$(this).attr('name')+'"]').attr('checked', false);
                                    $(this).prop('checked', true);
                                    $(this).attr('checked', true);
                                }

                            });

                        }
                        else{
                            kernel.ui.show_mensaje(response.info_estado.mensaje, {tipo: 'alert-error'});
                        }

                    }
                })

                event.preventDefault();
                return false;
            });
        }
    }
});