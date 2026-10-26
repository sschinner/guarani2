kernel.renderer.registrar_pagelet('info_plan', function(info) {
	var id = '#' + info.id;
	var mensajes = info.mensajes;

	return {
		onload: function() {
			
			info.carrera = $("#formulario_filtro-carreras").val();
			info.plan = $("#formulario_filtro-planes").val();
			info.version = $("#formulario_filtro-versiones").val();
					
			function delegate_correlativas($link,$id_destino) {
				if (! $link.attr('completo')){
					kernel.ajax.call(info.url_correlativas, {
						type: 'post',
						data: {
							carrera: info.carrera,
							plan: info.plan,
							version: info.version,
							id: $link.data('materia')
						},
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
					$(this).trigger('click');
				}
			});

			$(id).on('click', 'a.ver_materias',function (){
				$link = $(this);
				$('.'+$link.attr('linea')).toggle('slow');
			});

			$(id).on('keypress', 'a.ver_materias',function (e){
				if (e.keyCode==13) {
					$(this).trigger('click');
				}
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
				window.open(info.url_pdf+"?carrera="+info.carrera+"&plan="+info.plan+"&version="+info.version);
			});
                        
			$(id).on('keypress', '#pdf_btn',function (e){
				if (e.keyCode==13)
				{
					$(this).trigger('click');
				}
			});
                        
		}
	}
})