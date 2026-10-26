kernel.renderer.registrar_pagelet('info_historia', function(info) {
    var id = '#' + info.id;
    var mensajes = info.mensajes;

    return {
        onload: function() {
			$(id).on('change', '#anos,#materias',function (){
                aplicar_filtro();
            });

			$(id).on('click', '#orden_anio, #orden_materia',function (){
				$(id+' #filtro_modo').val($(this).data('valor'));
				aplicar_filtro();
				return false;
            });
			
			function exp_pdf() {
				var checkboxes = kernel.renderer.pagelet('menu_filtros').get_params_filtro();
				window.open(info.url_pdf+'/?checks='+checkboxes+'&modo='+get_modo()+'&param_modo='+get_param_modo())	
				
			}
			
									
			$(id).on('click', '#pdf_btn',function (){
				exp_pdf();
            });
            $(id).on('keypress', '#pdf_btn',function (e){
				if (e.which == 13) exp_pdf();
            });
            
			function exp_xls() {
				var checkboxes = kernel.renderer.pagelet('menu_filtros').get_params_filtro();				
				window.open(info.url_xls+'/?checks='+checkboxes+'&modo='+get_modo()+'&param_modo='+get_param_modo());
			}
			
			$(id).on('click', '#xls_btn',function (){
				exp_xls()
            });
			
			$(id).on('keypress', '#xls_btn',function (e){
				if (e.which == 13) exp_xls()
            });
			
			
			function get_param_modo(){
				if ($(id+' #filtro_modo').val()== "a"){
					if ($(id+' #anos').length > 0){
						return $(id+' #anos').val();
					}
				} else {
					if ($(id+' #materias').length > 0){
						return $(id+' #materias').val();
					}
				}
				return "";
			}
			
			function get_modo(){
				if ($(id+' #filtro_modo').val()!= "a"){
					return 'materia';
				}
				
				return 'anio';
			}
			
            kernel.evts.escuchar('filtrar', aplicar_filtro);
            
            function aplicar_filtro(){
				var checkboxes = kernel.renderer.pagelet('menu_filtros').get_params_filtro();
				var estados_filtro = kernel.renderer.pagelet('menu_filtros').get_estados_filtro();
				
				kernel.ajax.load(info.url_datos_historia_academica+'/?checks='+checkboxes+'&modo='+get_modo()+'&param_modo='+get_param_modo()+'&'+estados_filtro, id, {
					historia: true,
					type: 'get',
					show_loading: true,
					forzar_cambio_op: true
				});
			}
			
			
			// Detalles
			$(id).on('click', '.catedra_nombre a', function (){
				if ($('#mat_'+this.id).css('display') == 'none'){
                    var origen = $(this).data('origen');
                    var id_materia = $(this).attr('id');
                    var id_link = $('#'+id_materia);
                    var div_materia = '#mat_'+id_materia;
                    var div_detalle = '#info_det_'+id_materia;

					switch(origen)
                    {
                        case "Promocion":
                          url = info.url_detalle_promocion;
                          break;
                        case "Examen":
                          url = info.url_detalle_examen;
                          break;
                        case "Cursada":
                          url = info.url_detalle_cursada;
                          break;
                        case "Equivalencia":
                          url = info.url_detalle_equivalencia;
                          break;
                        case "EnCurso":
                          url = info.url_detalle_encurso;
                          break;                        
                    }
                    
					kernel.ajax.call(url, {
						type: 'post',
						data: {id: id_materia},
						success: function(paquete) {
							$(div_detalle).html(paquete.cont);
                            $(div_materia).show('2000');
							id_link.text('Cerrar')
						}
					});                
                }
                else
                {
                    $('#mat_'+this.id).hide('2000');
                    $('#'+this.id).text('Detalle');
                }
                return false;
            });
        }
    }
})
