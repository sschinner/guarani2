kernel.renderer.registrar_pagelet('certificados', function(info) {
    var id = '#' + info.id;
    var menu_visible = true;

//	function registrar_listeners() {
//		var id_evento = 'seleccionar_link';
//        kernel.evts.escuchar(id_evento, seleccionar_link);
//		
//		id_evento = 'seleccionar_certificado';
//        kernel.evts.escuchar(id_evento, seleccionar_certificado);
//    }
//	
//	function registrar_eventos() {		
//		
//		$(id).on('click', 'a', function() {
//			
//			$(id+' a').removeClass('active');
//			$(id+' a').attr('aria-pressed','false');
////			kernel.evts.disparar('cargar_formulario', {
////                href: $(this).attr('href')
////            });
////			return false;
//		});
//    }
//	
//	function seleccionar_link(params){
//		$(id+' a').removeClass('active');
//		$(id+' a[href="'+params.href+'"]').addClass('active');
//		$(id+' a[href="'+params.href+'"]').attr('aria-pressed','true');
//		$('#unidad_academica').focus();
//	}
//	
//	function seleccionar_certificado(params){
//		var certificado = '<span class="icon-ok"></span>' + $(id+' #nrocert'+params.nrcert).text();
//		$(id+' #nrocert'+params.nrcert).html(certificado);
//	}
	
    return {
        onload: function() {
//			registrar_eventos();
//			registrar_listeners();

            $('#js-btn_esconder').tooltip('destroy');
            $('#js-btn_esconder').tooltip({title: info.mensajes.esconder_menu});

//            if(info.id_certificado == 100){
//                esconder_menu();
//            }

            $(id).on('click', '#js-btn_esconder', function(event){

                if (menu_visible){

                    esconder_menu();

                } else {

                    mostrar_menu();

                }

                event.preventDefault();
            });

            function esconder_menu(){

                $( "#columna_1" ).animate({
                    width: 0,
                    height: 0
                }, 2000, function() {
                    $( "#columna_2").addClass('span12');
                    $( "#columna_2").removeClass('span9');
                    $('#js-btn_esconder i').removeClass('icon-chevron-left');
                    $('#js-btn_esconder i').addClass('icon-chevron-right');
                    $('#js-btn_esconder').tooltip('destroy');
                    $('#js-btn_esconder').tooltip({title: info.mensajes.mostrar_menu});
                    menu_visible = false;
                });

                $( "#certificados .well, #certificados .referencia" ).animate({
                    opacity: 0,
                    width: 0,
                    height: 0
                }, 2000, function(){
                    $( "#certificados .well, #certificados .referencia").hide();
                });

            }

            function mostrar_menu(){

                $( "#columna_2").removeClass('span12');
                $( "#columna_2").addClass('span9');
                $('#js-btn_esconder i').removeClass('icon-chevron-right');
                $('#js-btn_esconder i').addClass('icon-chevron-left');
                $('#js-btn_esconder').tooltip('destroy');
                $('#js-btn_esconder').tooltip({title: info.mensajes.esconder_menu});
                menu_visible = true;

                $( "#columna_1, #certificados .well, #certificados .referencia" ).css('width', '');
                $( "#columna_1, #certificados .well, #certificados .referencia" ).css('height', '');
                $( "#certificados .well, #certificados .referencia").show();
                $( "#certificados .well, #certificados .referencia" ).animate({
                    opacity: 1
                }, 2000);
            }

        }
    }
})
