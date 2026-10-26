//Asignaciones

var dias = ['Lunes', 'Martes', 'Mi&eacute;rcoles', 'Jueves', 'Viernes', 'S&aacute;bado'], horario = {}, materias_sin_horario, total_asignaciones;

horario.cursada = function(asignaciones, destino, banda_horaria) {
	this.periodo = 'cuatrimestre';
	if(destino) {
		this.set_destino(destino);
	}
	if(banda_horaria) {
		this.banda_horaria = banda_horaria;
	}
	if(asignaciones) {
		this.set(asignaciones);
	}
};

horario.cursada.prototype.reset_calculo = function() {
	this.calculo = {
			is_set: false,
			semestre: {
				a: {
					1: [], 
					2: []
				},
				trad: {
					1: 'Enero - Junio',
					2: 'Julio - Diciembre'
				},
				solo_trad: true
			}, 
			cuatrimestre: {
				a: {
					1: [], 
					2: [], 
					3: []
				},
				trad: {
					1: 'Enero - Abril',
					2: 'Mayo - Agosto',
					3: 'Septiembre - Diciembre'
				},
				solo_trad: true
			}, 
			trimestre: {
				a: {
					1: [], 
					2: [], 
					3: [], 
					4: []
				},
				trad: {
					1: 'Enero - Marzo',
					2: 'Abril - Junio',
					3: 'Julio - Septiembre',
					4: 'Octubre - Diciembre'
				},
				solo_trad: true
			}, 
			mes: {
				a: {
						1: [], 
						2: [], 
						3: [], 
						4: [], 
						5: [], 
						6: [], 
						7: [], 
						8: [], 
						9: [], 
						10: [], 
						11: [], 
						12: []
				},
				trad: {
					1: 'Enero',
					2: 'Febrero',
					3: 'Marzo',
					4: 'Abril',
					5: 'Mayo',
					6: 'Junio',
					7: 'Julio',
					8: 'Agosto',
					9: 'Septiembre',
					10: 'Octubre',
					11: 'Noviembre',
					12: 'Diciembre'
				},
				solo_trad: true
			}, 
			quincena: { 
				a: {
					1: [], 
					2: [], 
					3: [], 
					4: [], 
					5: [], 
					6: [], 
					7: [], 
					8: [], 
					9: [], 
					10: [], 
					11: [],
					12: [], 
					13: [], 
					14: [], 
					15: [], 
					16: [], 
					17: [], 
					18: [], 
					19: [], 
					20: [], 
					21: [], 
					22: [], 
					23: [],
					24: []
				},
				trad: horario.terminaciones.fem
			}
	};
};

horario.cursada.prototype.set = function (asignaciones) {
	this.asignaciones = asignaciones;
	this.calcular();
};

horario.cursada.prototype.set_destino = function(destino) {
	this.destino = destino;
	this.dibujar();
};

horario.cursada.prototype.calcular = function() {
	this.reset_calculo();
	materias_sin_horario = [];
	// dinit 1 de enero (año actual)
	total_asignaciones = this.asignaciones.length;
	var dinit;
	var dobh = false;
	if(!this.banda_horaria) {
		this.banda_horaria = {min: false, max: false};
		dobh=true;
	}
	for(var i = 0; i < this.asignaciones.length; i++) {
		var asignacion = this.asignaciones[i];
		var asig_start = asignacion.FECHA_ASIGN_DESDE.split('-');
		var asig_end   = asignacion.FECHA_ASIGN_HASTA.split('-');
		if(dobh) {
			var c = parseInt(asignacion.HS_COMIENZO_CLASE.split(':')[0],10);
			var f = asignacion.HS_FINALIZ_CLASE.split(':');
			f = parseInt(f[1],10) > 0?parseInt(f[0],10):parseInt(f[0],10)+1;
			if(this.banda_horaria.min === false || c < this.banda_horaria.min) {
				this.banda_horaria.min = c;
			}
			if(this.banda_horaria.max === false || f < this.banda_horaria.max) {
				this.banda_horaria.max = f;
			}
		}
		asig_start = new Date(asig_start[0], parseInt(asig_start[1])-1, asig_start[2]);
		asig_end   = new Date(asig_end[0],   parseInt(asig_end[1])-1,   asig_end[2]);
		if (! isValidDate(asig_start) || ! isValidDate(asig_end)) {
			materias_sin_horario.push(asignacion);
			continue;
		}
		
		// Se setea la fecha de inicio a partir del año de la asignacion
		dinit = new Date();
		dinit.setMonth(0,1);
		dinit.setYear(asig_start.getFullYear());
		
		// variables auxiliares para hacer el calculo por período
		var desde, hasta, periodo;

		//Semestre
		for(periodo in this.calculo.semestre.a) {
			desde = new Date(dinit.getTime());
			// setea el mes al primero de cada periodo
			desde.setMonth(desde.getMonth() + ((periodo - 1) * 6));
			
			// se setea a partir de desde y se le suman 6 meses
			hasta = new Date(desde.getTime());
			hasta.setMonth(hasta.getMonth() + 6);
			if(	   (asig_start.getTime() >= desde.getTime() && asig_start.getTime() < hasta.getTime()) 
				|| (asig_end.getTime()   >= desde.getTime() && asig_end.getTime()   < hasta.getTime()) 
				// empieza antes y termina después, engloba todo el período
				|| (asig_start.getTime() <  desde.getTime() && asig_end.getTime()   > hasta.getTime())
			) {
				var s = this.calculo.semestre.a[periodo];
				s[s.length] = asignacion;
			}
		}
		
		//Cuatrimestre
		for(periodo in this.calculo.cuatrimestre.a) {
			desde = new Date(dinit.getTime());
			desde.setMonth(desde.getMonth()+((periodo-1)*4));
			hasta = new Date(desde.getTime());
			hasta.setMonth(hasta.getMonth()+4);
			if((asig_start.getTime() >= desde.getTime() && asig_start.getTime() < hasta.getTime()) || (asig_end.getTime() >= desde.getTime() && asig_end.getTime() < hasta.getTime()) || (asig_start.getTime() < desde.getTime() && asig_end.getTime() > hasta.getTime())) {
				var s = this.calculo.cuatrimestre.a[periodo];
				s[s.length] = asignacion;
			}
		}
		
		//Trimestre
		for(periodo in this.calculo.trimestre.a) {
			desde = new Date(dinit.getTime());
			desde.setMonth(desde.getMonth()+((periodo-1)*3));
			hasta = new Date(desde.getTime());
			hasta.setMonth(hasta.getMonth()+3);
			if((asig_start.getTime() >= desde.getTime() && asig_start.getTime() < hasta.getTime()) || (asig_end.getTime() >= desde.getTime() && asig_end.getTime() < hasta.getTime()) || (asig_start.getTime() < desde.getTime() && asig_end.getTime() > hasta.getTime())) {
				var s = this.calculo.trimestre.a[periodo];
				s[s.length] = asignacion;
			}
		}
		
		//Mes
		for(periodo in this.calculo.mes.a) {
			desde = new Date(dinit.getTime());
			desde.setMonth(desde.getMonth()+(periodo-1));
			hasta = new Date(desde.getTime());
			hasta.setMonth(hasta.getMonth()+1);
			if((asig_start.getTime() >= desde.getTime() && asig_start.getTime() < hasta.getTime()) || (asig_end.getTime() >= desde.getTime() && asig_end.getTime() < hasta.getTime()) || (asig_start.getTime() < desde.getTime() && asig_end.getTime() > hasta.getTime())) {
				var s = this.calculo.mes.a[periodo];
				s[s.length] = asignacion;
			}
		}
		
		//Quincena
		for(periodo in this.calculo.quincena.a) {
			desde = new Date(dinit.getTime());
			hasta = new Date(desde.getTime());
			if(periodo % 2 == 0) {
				var u = (parseInt(periodo)/2)-1;
				desde.setMonth(desde.getMonth()+u, 16);
				hasta.setMonth(desde.getMonth()+1, 1);
			} else {
				var u = ((parseInt(periodo)+1)/2)-1;
				desde.setMonth(desde.getMonth()+u,1);
				hasta.setMonth(desde.getMonth(), 16);
			}
			if((asig_start.getTime() >= desde.getTime() && asig_start.getTime() < hasta.getTime()) || (asig_end.getTime() >= desde.getTime() && asig_end.getTime() < hasta.getTime()) || (asig_start.getTime() < desde.getTime() && asig_end.getTime() > hasta.getTime())) {
				var s = this.calculo.quincena.a[periodo];
				s[s.length] = asignacion;
			}
		}
	}
	
	this.calculo.is_set = true;
	this.dibujar();
};

horario.cursada.prototype.semestre = function() {
	this.periodo = 'semestre';
	this.dibujar();
};

horario.cursada.prototype.cuatrimestre = function() {
	this.periodo = 'cuatrimestre';
	this.dibujar();
};

horario.cursada.prototype.trimestre = function() {
	this.periodo = 'trimestre';
	this.dibujar();
};

horario.cursada.prototype.mes = function() {
	this.periodo = 'mes';
	this.dibujar();
};

horario.cursada.prototype.quincena = function() {
	this.periodo = 'quincena';
	this.dibujar();
};

horario.cursada.prototype.dibujar = function() {
	if(this.calculo && this.calculo.is_set && this.destino) {
		horario.dibujar(this.calculo[this.periodo], this.destino, this.periodo, this.banda_horaria);
	}
};

horario.detalle = function(titulo, e, banda_horaria) {
    
    console.log(e);
	var colores = ['#FF8080','#8099B2', '#66C285', '#FFB870', '#E0E066', '#E08566', '#A3E0FF', '#99CC99'];
	var cabecera = '<div class="celda tit-lateral"></div><div>';
	var min = parseInt(banda_horaria.min.split(':')[0],10);
	var max = parseInt(banda_horaria.max.split(':')[0],10);
	var htwidth = 1000;
	var tl = 60;
	var width = htwidth-tl;
	var w = width / (max-min);
	var tm = (max-min)*60;
	var materias = {cuenta: 0};
	for(var i = min; i<max; i++) {
		cabecera += '<div class="celda" style="width: '+w+'px; left: '+(tl+(w*(i-min)))+'px">'+(i<10?'0':'')+i+':00</div>';
	}
	cabecera += '</div>';
	var tabla = '<div class="tabla"><div class="fila cabecera">'+cabecera+'</div>';
	for(var j=0; j<dias.length; j++) {
		tabla += '<div class="fila"><div class="celda tit-lateral"><span>'+dias[j]+'</span></div><div>';
		for(var i = min; i<max; i++) {
			tabla += '<div class="celda" style="width: '+w+'px; left: '+(tl+(w*(i-min)))+'px"></div>';
		}
		tabla += '</div>';
		for(var k in e) {
			var a = e[k];
            
			if(a.DIA_SEMANA == j+2) {
				var c = ((parseInt(a.HS_COMIENZO_CLASE.split(':')[0],10)-min)*60)+parseInt(a.HS_COMIENZO_CLASE.split(':')[1],10);
				c = width*c/tm;
				var f = tm-((parseInt(a.HS_FINALIZ_CLASE.split(':')[0],10)-min)*60)-parseInt(a.HS_FINALIZ_CLASE.split(':')[1],10);
				f = width*f/tm;
				if(!materias[a.NOMBRE_MATERIA]) {
					materias[a.NOMBRE_MATERIA] = {color: colores[materias.cuenta]};
					materias.cuenta++;
					if(materias.cuenta > colores.length) {
						materias.cuenta = 0;
					}
				}
				var hc = a.HS_COMIENZO_CLASE.split(':');
				var hf = a.HS_FINALIZ_CLASE.split(':');
				tabla += '<div class="materia" data-toggle="tooltip" title="<b>Aula:</b> '+a.NOMBRE_AULA+'<br><b>Horario:</b> de '+hc[0]+':'+hc[1]+' a '+hf[0]+':'+hf[1]+'" data-content="Sede: '+a.SEDE+'" style="background-color: '+materias[a.NOMBRE_MATERIA].color+'; left: '+(tl+c)+'px; right: '+f+'px">'+a.NOMBRE_MATERIA+'</div>';
			}
		}
		tabla += '</div>';
	}
	tabla += '</div>';
	$.facebox('<div class="horario_tabla"><h2>'+titulo+'</h2>'+tabla+'</div>');
	$('.horario_tabla .materia').each(function(){
       var t = this;
       var ajustar_txt = function() {
           if(t.scrollHeight > t.clientHeight || t.scrollWidth > t.clientWidth) {
               var fs = $(t).css('font-size').match(/([\d.]+) *(\D+)/);
               //t.style.fontSize = (parseFloat(fs[1])-1)+fs[2];
               $(t).css('font-size', (parseFloat(fs[1])-1)+fs[2]);
               ajustar_txt();
           }
       }
       ajustar_txt();
       /*$(t).popover({placement: 'top', container: 'body'}).mouseout(function(){
    	   $(this).popover('hide');
       });*/
       $(t).tooltip({html: true});
   }).css('cursor', 'pointer');

};

horario.dibujar = function(calculo, destino, tipo, banda_horaria) {
	var turnos, bh=true, msgs={};
	if(banda_horaria.min === false || banda_horaria.max === false) {
		turnos = ['mañana', 'tarde', 'noche'];
		bh=false;
	} else {
		var s = parseInt(banda_horaria.min.split(':')[0],10);
		var e = parseInt(banda_horaria.max.split(':')[0],10);
		var l = (e-s);
		l = l%3==1?Math.floor(l/3):Math.ceil(l/3);
		turnos = [{s: s, e:s+l}, {s: s+l, e: s+l+l}, {s: s+l+l, e: e}];
	}
	var cabecera = '<div class="tit-lateral"></div>';
	for(var i=0; i<dias.length; i++) {
		cabecera += '<div class="celda tit"><span>'+dias[i].toLowerCase().substr(0, 2)+'</span></div>';
	}
	var html ='';
	var msg = '';
	var materias = {};
	var colores = ['#FF8080','#8099B2', '#66C285', '#FFB870', '#E0E066', '#E08566', '#A3E0FF', '#99CC99'];
//	#445
//	if (total_asignaciones == 0) {
//		var mensaje_sin_materias = '<div id="notif-sin-materias" class="alert alert-warning" style="width: 190px; padding:10px 2px;margin: 0;text-align:center">';
//		mensaje_sin_materias += 'No te has inscripto a ninguna materia';
//		mensaje_sin_materias += '</div>';
//		html += mensaje_sin_materias;
//	} else 
	if (materias_sin_horario.length > 0) {
		var mensaje_materias_sin_horario = '<div id="notif-sin-materias" class="alert alert-error" style="width: 190px; padding:10px 2px;margin: 0;text-align:center">';
		mensaje_materias_sin_horario    += 'Hay materias que no aparecen en la grilla porque no tienen horario asignado';
		mensaje_materias_sin_horario    += '</div>';
		html += mensaje_materias_sin_horario;
	}
	
	var items = $('<div class="items"></div>');
	var panel, mnotif;
	for(var e in calculo.a) {
		(function(e){
			if(parseInt(e) % 2 != 0) {
				materias = {cuenta_materias: 0};
				panel = $('<div class="panel"></div>');
				mnotif = $('<div class="periodo materias-notif"><h4>Materias:</h4></div>');
				panel.append(mnotif);
				items.append(panel)
			}
			var titulo = (calculo.solo_trad)?calculo.trad[e]:(e+calculo.trad[e.charAt(e.length-1)]+' '+tipo);
			
			var periodo = $('<div class="periodo"><h4>'+titulo+'</h4></div>');
			mnotif.before(periodo);
			
			
			//html += ;
			var tabla = '<div class="tabla"><div class="fila">'+cabecera+'</div>';
			for(var i=0; i<turnos.length; i++) {
				tabla += '<div class="fila"><div class="celda tit-lateral"><span>'+($.type(turnos[i]) == 'string'?turnos[i]:turnos[i].s+' - '+turnos[i].e+' hs')+'</span></div>';
				for(var j=0; j<dias.length; j++) {
					tabla += '<div class="celda cuad hor">';
					var co = [];
					for(var k in calculo.a[e]) {
						var a = calculo.a[e][k];
						if(a.DIA_SEMANA == j+2) {
							var c = parseInt(a.HS_COMIENZO_CLASE.split(':')[0],10);
							var f = parseInt(a.HS_FINALIZ_CLASE.split(':')[0],10);
							if(
								($.type(turnos[i]) == 'string' && ((i==0 && a.TURNO == 'M') || (i==1 && a.TURNO == 'T') || (i==2 && a.TURNO == 'N'))) || 
								($.type(turnos[i]) == 'object' && ((c >= turnos[i].s && c < turnos[i].e) || (f > turnos[i].s && f <= turnos[i].e)))
							) {
								if(!materias[a.NOMBRE_MATERIA]) {
									a.color = colores[materias.cuenta_materias];
									materias[a.NOMBRE_MATERIA] = a;
									materias.cuenta_materias++;
								}
								var coe = {
									color: materias[a.NOMBRE_MATERIA].color, 
									HS_COMIENZO_CLASE: a.HS_COMIENZO_CLASE, 
									HS_FINALIZ_CLASE: a.HS_FINALIZ_CLASE,
									NOMBRE_MATERIA: a.NOMBRE_MATERIA,
									MATERIA: a.MATERIA
								}
								co.push(coe);
							}
						}
					}
	
					if(co.length > 0) {
						switch(co.length) {
							case 1:
								tabla += '<div id="mat_'+e+'_'+i+'_'+j+'_0" class="mat_cuad" style="top: 0px; left: 0px; right: 0px; bottom: 0px; background-color: '+co[0].color+'"></div>';
								break;
							case 2:
								tabla += '<div id="mat_'+e+'_'+i+'_'+j+'_0" class="mat_cuad" style="border-right: 1px solid black; border-bottom: 1px solid black; top: 0px; left: 0px; right: 7px; bottom: 7px; background-color: '+co[0].color+'"></div>';
								tabla += '<div id="mat_'+e+'_'+i+'_'+j+'_1" class="mat_cuad" style="border-left: 1px solid black; border-top: 1px solid black; top: 7px; left: 7px; right: 0px; bottom: 0px; background-color: '+co[1].color+'"></div>';
								break;
							case 3:
								tabla += '<div id="mat_'+e+'_'+i+'_'+j+'_2" class="mat_cuad" style="border-left: 1px solid black; border-bottom: 1px solid black; top: 0px; left: 11.5px; right: 0px; bottom: 11.5px; background-color: '+co[2].color+'"></div>';
								tabla += '<div id="mat_'+e+'_'+i+'_'+j+'_0" class="mat_cuad" style="border-right: 1px solid black; border-bottom: 1px solid black; top: 0px; left: 0px; right: 11.5px; bottom: 11.5px; background-color: '+co[0].color+'"></div>';
								tabla += '<div id="mat_'+e+'_'+i+'_'+j+'_1" class="mat_cuad" style="border-left: 1px solid black; border-top: 1px solid black; top: 11.5px; left: 11.5px; right: 0px; bottom: 0px; background-color: '+co[1].color+'"></div>';
	
								break;
							case 4:
								tabla += '<div id="mat_'+e+'_'+i+'_'+j+'_2" class="mat_cuad" style="border-left: 1px solid black; border-bottom: 1px solid black; top: 0px; left: 11.5px; right: 0px; bottom: 11.5px; background-color: '+co[2].color+'"></div>';
								tabla += '<div id="mat_'+e+'_'+i+'_'+j+'_3" class="mat_cuad" style="border-right: 1px solid black; border-top: 1px solid black; top: 11.5px; left: 0px; right: 11.5px; bottom: 0px; background-color: '+co[3].color+'"></div>';
								tabla += '<div id="mat_'+e+'_'+i+'_'+j+'_0" class="mat_cuad" style="border-right: 1px solid black; border-bottom: 1px solid black; top: 0px; left: 0px; right: 11.5px; bottom: 11.5px; background-color: '+co[0].color+'"></div>';
								tabla += '<div id="mat_'+e+'_'+i+'_'+j+'_1" class="mat_cuad" style="border-left: 1px solid black; border-top: 1px solid black; top: 11.5px; left: 11.5px; right: 0px; bottom: 0px; background-color: '+co[1].color+'"></div>';
								break;
							default:
								tabla += '<div id="mat_'+e+'_'+i+'_'+j+'" class="mat_cuad" style="top: 0px; left: 0px; right: 0px; bottom: 0px; background-color: lightgray">'+co.length+'</div>';
								break;
						}
					}
					tabla += '</div>';
					var key = '';
					for(var k = 0; k<co.length; k++) {
						if (co.length <= 4 || k == 0) {
							key = 'mat_'+e+'_'+i+'_'+j+(co.length <= 4?'_'+k:'');
							msgs[key] = '';
							//msg += '<div class="tip" id="msg_mat_'+e+'_'+i+'_'+j+(co.length <= 4?'_'+k:'')+'">';
						}
						msgs[key] += '<div><span class="mat_ref" style="background-color: '+co[k].color+'"></span>('+co[k].MATERIA+') '+co[k].HS_COMIENZO_CLASE+' - '+co[k].HS_FINALIZ_CLASE+'</div>';
						/*if (co.length <= 4 || k == co.length-1) {
							msg += '</div>';
						}*/
					}
				}
				tabla += '</div>';
			}
			tabla += '</div>';
			periodo.append(tabla);
			if(parseInt(e) % 2 == 0 || !calculo.a[parseInt(e)+1]) {
				var tmp=''
				for(var i in materias) {
					if(i != 'cuenta_materias')
						tmp += '<div><span class="mat_ref" style="background-color: '+materias[i].color+'"></span><span>('+materias[i].MATERIA+') '+i+'</span></div>';
				}
				mnotif.append(tmp);
			}
			
			if(bh) {
				periodo.on('click', 'h4, .celda', function() {
					horario.detalle(titulo, calculo.a[e], banda_horaria);
				}).find('h4, .celda').css('cursor', 'pointer');
			}
		})(e);
	}

	$('#'+destino).html(html).append(items);
	$('#'+destino+'_mensajes').html(msg);
	$('#'+destino).siblings().remove();
	
	var maxHeight = 0;
	$('#'+destino).find(".panel").each(function() {
		if(this.clientHeight > maxHeight) maxHeight = this.clientHeight;  
	});
	if($('#'+destino+' .panel').length > 1) {
		$('#'+destino+' .panel:first').addClass('active');
		var pager = $('<ul class="pager"><li class="previous disabled"><a href="#">&larr;</a></li><li class="next"><a href="#">&rarr;</a></li></ul>').on('click', 'a', function(evt) {
			var $t = $(this).parent();
			if(!$t.hasClass('disabled')) {
				var $a = $('#'+destino+' .panel.active').removeClass('active');
				var $d;
				if($t.hasClass('previous')) {
					$d = $a.prev();
					$('.next',pager).removeClass('disabled');
					if(!$d.prev().length) {
						$t.addClass('disabled');
					}
				} else {
					$d = $a.next();
					$('.previous',pager).removeClass('disabled');
					if(!$d.next().length) {
						$t.addClass('disabled');
					}
				}
				$('#'+destino+' .items').animate({
					left: -1 * ($d.addClass('active').prop('offsetLeft')-1)
				});
			}
			return false;
		});
		$('#'+destino).after(pager);
	}
	
	$('#'+destino).css('height', maxHeight+'px');
//	popover del calendario
//	$('.mat_cuad').each(function() {
//		$(this).popover({
//			content: msgs[this.id], 
//			trigger:'hover', 
//			html: true, 
//			placement: 'top',
//			container: 'body'
//		});
//	});

	
	$(materias_sin_horario).each(function() {
		var span = $('<span>').addClass('mat_ref');
		var div  = $('<div>').append(span);
		var cont = '(' + this.MATERIA + ') ' + this.NOMBRE_MATERIA;
		$('<span>'+cont+'</span>').insertAfter(span);
		$('.materias-notif').append(div);
		var nuevo_height = $('#'+destino).height() + div.height();
		$('#'+destino).height(nuevo_height);
	});
	
	
	$('#'+destino).height($('#'+destino).height() + ($('#notif-sin-materias').prop('clientHeight')||0));
	
};

horario.terminaciones = {
		fem: {
			1: 'ra',
			2: 'da',
			3: 'ra',
			4: 'ta',
			5: 'ta',
			6: 'ta',
			7: 'ma',
			8: 'va',
			9: 'na',
			0: 'ma'
		},
		mas: {
			1: 'er',
			2: 'do',
			3: 'er',
			4: 'to'
		}
};

function isValidDate(d) {
  if ( Object.prototype.toString.call(d) !== "[object Date]" )
    return false;
  return !isNaN(d.getTime());
}
