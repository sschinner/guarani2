kernel.renderer.registrar_pagelet('formulario', function(info) {
    var id = '#' + info.id;

    return {
        onload: function() {

            $(id).on('click', '.vincular', function(){

                var alcance = $(this).data('alcance');
                var btn_vincular = $(this);
                $(btn_vincular).prop( "disabled", true );

                kernel.ajax.call(info.url_sincronizar, {
                    type: 'POST',
                    data: {
                        alcance: alcance
                    },
                    success: function(paquete) {
                        $("#mensaje-vincular").hide();

                        if(paquete.hubo_error){

                            $(btn_vincular).prop( "disabled", false );
                            $("#mensaje-vincular").text(paquete.mensaje).removeClass("alert-success").addClass("alert-error").fadeIn("slow");

                        }
                        else{

                            var cant_trs = $(btn_vincular).parents("tbody").find("tr").length;
                            if(cant_trs > 1){
                                $(btn_vincular).parents("tr").slideUp( "slow", function() {
                                    $(this).remove();
                                });
                            }
                            else{
                                $(btn_vincular).parents(".accordion-group").slideUp( "slow", function() {
                                    $(this).remove();
                                    var cant_accordion_group = $("#alcances .accordion-group").length;
                                    if(cant_accordion_group == 0){
                                        $("#alcances").remove();
                                        $("#no-hay-mas-alcances").fadeIn("slow");
                                    }
                                });
                            }

                            $("#mensaje-vincular").text(paquete.mensaje).removeClass("alert-error").addClass("alert-success").fadeIn("slow");

                        }
                    }
                });

            });
        }
    }
});