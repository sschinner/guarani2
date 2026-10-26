kernel.renderer.registrar_pagelet('info_plan', function(info) {
	var id = '#' + info.id;
	var mensajes = info.mensajes;

	return {
		onload: function() {
			function delegate_correlativas($link,$id_destino) {
			if (! $link.attr('completo')){
					kernel.ajax.call(info.url_correlativas, {
						type: 'post',
						data: {id: $link.data("materia")},
						success: function(paquete) {
							$link.attr('completo', true);
							$('#'+$id_destino).html(paquete.cont);
						},
						error: function() {
							$('#'+$id_destino).html(paquete.cont);
						}
					})
				}
				$('#'+$id_destino).toggle('slow', cambiar_texto($link));
			}

			$(id).on('click', 'a.ver_correlatividades',function (){
				var $link = $(this);
				var $id_destino = $link.attr('linea');
				delegate_correlativas($link,$id_destino);
			});

			$(id).on('keypress', 'a.ver_correlatividades',function (e){
				if (e.keyCode == 13) {
                                    $(this).trigger('click'); }
			});

			$(id).on('click', 'a.ver_materias',function (){
				$link = $(this);
				$('.'+$link.attr('linea')).toggle('slow');
			});

			$(id).on('keypress', 'a.ver_materias',function (e){
				if (e.keyCode==13) {
                                    $(this).trigger('click'); }
			});

			function cambiar_texto($id) {
				if ($('#' + $id.attr('linea')).css('display') == 'none') {
					$id.text(info.ocultar);
				} else {
					$id.text(info.ver);
				}
			}

			$().popover('show');

			$(id).on('click', '#pdf_btn',function (){
				window.open(info.url_pdf);
			});
                        
                        $(id).on('keypress', '#pdf_btn',function (e){
				if (e.keyCode==13)
                                    { $(this).trigger('click'); }
			});
			
            
			function exp_xls() {	
				window.open(info.url_xls);
			}
			
			$(id).on('click', '#xls_btn',function (){
				exp_xls()
            });
			
			$(id).on('keypress', '#xls_btn',function (e){
				if (e.which == 13) exp_xls()
            });

            $(id).on('vclick', '.verificar', function (event){
                event.preventDefault();

                var $btn_verificar = $(this);
                var materia = $btn_verificar.data('materia');
                var completo = $btn_verificar.data('completo');
                var tipo_correlativa;

                if($btn_verificar.hasClass('correlativas_cursar')){
                    tipo_correlativa = "C";
                }
                else if($btn_verificar.hasClass('correlativas_aprobar')){
                    tipo_correlativa = "A";
                }

                var $alert = $("#alert_correlativas_"+tipo_correlativa+"_materia"+materia+"_js");

                if(!completo){

                    kernel.ajax.call(info.url_verificar_correlativas, {
                        type: 'post',
                        data: {
                            materia: materia,
                            tipo: tipo_correlativa
                        },
                        success: function(paquete) {

                            if(paquete.hubo_error){
                                kernel.ui.show_mensaje(paquete.mensaje_error, {tipo: 'alert-error'});
                                return false;
                            }

                            var class_alert = "";
                            if(paquete.cumple_regla){
                                class_alert = "alert-success";
                            }
                            else{
                                class_alert = "alert-error";
                            }

                            $alert.addClass(class_alert);
                            $alert.find('h4.alert-heading').text(paquete.mensaje_usuario);
                            $btn_verificar.data('completo', true);

                            $alert.slideDown();
                        }
                    });

                }
                else{
                    $alert.slideDown();
                }

            });

            $(id).on('vclick', '.alert_verificar_correlativas .btn.ocultar', function (event){
                event.preventDefault();
                $(this).parents('.alert_verificar_correlativas').slideUp();
            });
		}
	}
})