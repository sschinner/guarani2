kernel.renderer.registrar_pagelet('encuesta', function(info) {
    var id = '#' + info.id;

    function registrar_listeners() {
        kernel.evts.escuchar("cargar_encuesta", cargar_encuesta);
        kernel.evts.escuchar("marcar_encuesta", marcar_encuesta);

        //http://stackoverflow.com/questions/935127/how-to-access-parent-iframe-from-javascript/15601531#15601531
        //https://developer.mozilla.org/en-US/docs/Web/API/window.postMessage
        window.addEventListener('message', function(event) {

            if(event.origin === info.domain_kolla)
            {
                if (event.data.name == 'encuesta_cargada'){
                    autoResize(event.data.height);
                }else{
                    kernel.ajax.call(info.url_accion,{
                        type:'post',
                        data: {t: event.data.t, h: event.data.h, fecha_respuesta: event.data.fecha_terminado},
                        success:function(data){

                            $('html, body').animate({ scrollTop: 0 }, 'fast', function() {
                                    document.getElementById('ifkolla').height= (500) + "px";
                                }
                            );

                            if(data.error_habilitacion){
                                $("#mensaje-error-texto").text(data.mensaje);
                                $("#mensaje-error").fadeIn("slow");
                            }

                            if($("#encuesta_seleccionada_id").val()){
                                var borrar_grupo = false;

                                //Si es un grupo de encuestas
                                if($($("#encuesta_seleccionada_id").val()).parents('ul.hide').length){

                                    var $ul_hide = $($("#encuesta_seleccionada_id").val()).parents('ul.hide');

                                    //Si es la ultima encuesta del grupo
                                    if($ul_hide.find("li").length == 1){
                                        borrar_grupo = true;
                                    }

                                }

                                if(borrar_grupo){
                                    $($("#encuesta_seleccionada_id").val()).parents('li.encuesta').hide('slow', function(){
                                        $(this).remove();
                                    });
                                }
                                else{
                                    $($("#encuesta_seleccionada_id").val()).parent('li').hide('slow', function(){
                                        $(this).remove();
                                    });
                                }

                            }
                        }
                    });
                }


            }

        }, false);

    }
	
	function cargar_encuesta(params) {
		kernel.ajax.load(params.href, id, {
			success: function() {
				kernel.evts.disparar("seleccionar_link", params);
                $("#encuesta_seleccionada_id").val('#' + params.me);
                marcar_encuesta();
            }
		});
    }

    function marcar_encuesta(){
        $("li.encuesta, li.encuesta li").removeClass("active");
        $('ul.hide').hide();
        $($("#encuesta_seleccionada_id").val()).parents('ul.hide').show();
        $($("#encuesta_seleccionada_id").val()).parent('li').addClass("active");
    }

	function autoResize(newheight){
		var id = 'ifkolla';
        document.getElementById(id).height= (newheight) + "px";
	}
	
    return {
		onload: function() {
			registrar_listeners();
		}
	};
});

