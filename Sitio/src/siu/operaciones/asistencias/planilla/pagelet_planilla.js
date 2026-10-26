kernel.renderer.registrar_pagelet('planilla', function(info) {
	var id = '#' + info.id;

	function registrar_disparadores() {
	}

	function registrar_listeners() {
	}

	return {
            onload: function() {
//                    $('#boton_pdf').hide();
                    $filtro = $('form').formulario();                
                    $("#boton_pdf").on('click', function(){
                        var link = $(this).attr('href')+ '?ID=' +info.comision_hash+ '&cantidad=' +$('#formulario_filtro-cantidad').val()+ '&fecha=' +$('#formulario_filtro-fecha').val()+ '&tipo=' +$('#formulario_filtro-tipo').val()+ '&SUBCO=' + info.subcomision + '&TIPO=' + info.tipo_clase;
                        window.open(link);
			return false;
                    });
                    
                    $('#boton_buscar').on('click', function(){ 
                        $('#formulario_filtro').submit();                       
                    });
                    
                    $('#formulario_filtro').on('submit', function(){
                        var fecha_seleccionada = $filtro.find('#formulario_filtro-fecha').val();
                        //var info_clase_form;
						//info_clase_form = $("#formulario_filtro-tipo_clase").val();
						if (info.subcomision === "")
						{
							info.tipo_clase = $("#formulario_filtro-tipo_clase").val();
						}	
                        kernel.ajax.call($(this).attr('action')+ '?ID=' +info.comision_hash+ '&SUBCO=' + info.subcomision + '&TIPO=' +  info.tipo_clase, {
                            data: $filtro.serialize(),
                            type: 'POST',
                            success: function(paquete) {
				$(id).html(paquete.cont);
                                $('#formulario_filtro-fecha').datepicker("setDate", fecha_seleccionada);
			    }
                        });
                        return false;
                    });
                                                      
                    $( "#formulario_filtro-fecha" ).datepicker( "destroy" );
                    $('#formulario_filtro-fecha').datepicker({
                            changeMonth: true,
                            changeYear: true,
                    });
                    $('#formulario_filtro-fecha').datepicker("setDate", new Date());
                    
                    if (info.subcomision) {
                        $("#formulario_filtro-tipo_clase").prop("disabled", true);
						$("#formulario_filtro-tipo_clase").val(info.tipo_clase);
                    }
				
					if(info.tipo_clase && info.tipo_clase_desc)
					{
						$('#inasistencias_tclase').text('Inasist. Acum. ' + info.tipo_clase_desc);
					}
            }
        };
});