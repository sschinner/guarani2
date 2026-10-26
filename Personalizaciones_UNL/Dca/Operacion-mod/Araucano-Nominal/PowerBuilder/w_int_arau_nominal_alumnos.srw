$PBExportHeader$w_int_arau_nominal_alumnos.srw
$PBExportComments$Interfaz con Araucano - Informaciòn nominal de alumnos. Se generan 3 archivos.
forward
global type w_int_arau_nominal_alumnos from w_operacion
end type
type mle_mensaje from multilineedit within w_int_arau_nominal_alumnos
end type
type st_titulo from statictext within w_int_arau_nominal_alumnos
end type
type em_anio from editmask within w_int_arau_nominal_alumnos
end type
type st_2 from statictext within w_int_arau_nominal_alumnos
end type
type cb_generar from commandbutton within w_int_arau_nominal_alumnos
end type
type cb_1 from commandbutton within w_int_arau_nominal_alumnos
end type
type st_1 from statictext within w_int_arau_nominal_alumnos
end type
type sle_1 from singlelineedit within w_int_arau_nominal_alumnos
end type
end forward

global type w_int_arau_nominal_alumnos from w_operacion
integer width = 3035
integer height = 1724
event ue_generar_archivos ( )
event ue_error ( string as_mensaje )
event ue_ok ( string as_mensaje )
mle_mensaje mle_mensaje
st_titulo st_titulo
em_anio em_anio
st_2 st_2
cb_generar cb_generar
cb_1 cb_1
st_1 st_1
sle_1 sle_1
end type
global w_int_arau_nominal_alumnos w_int_arau_nominal_alumnos

type variables
String	is_Path = 'C:\'
String   is_archivo0, is_archivo1, is_archivo2
Long     il_anio
Boolean  ib_alumnos, ib_rendimiento, ib_oferta
uo_ds    ids_alumnos, ids_rend, ids_oferta
end variables

event ue_generar_archivos();
this.event trigger ue_preprocesar()
if not ib_grabar then return

this.event trigger ue_procesar()
if not ib_grabar then return

this.event trigger ue_posprocesar()

end event

event ue_error(string as_mensaje);mle_mensaje.TextColor = RGB(255, 0, 0)  // Rojo
mle_mensaje.text = as_mensaje

ib_grabar = false
SetPointer(Arrow!)

end event

event ue_ok(string as_mensaje);mle_mensaje.TextColor = RGB(0, 0, 255)  // AZUL
mle_mensaje.text += as_mensaje + '~r~n'
end event

on w_int_arau_nominal_alumnos.create
int iCurrent
call super::create
this.mle_mensaje=create mle_mensaje
this.st_titulo=create st_titulo
this.em_anio=create em_anio
this.st_2=create st_2
this.cb_generar=create cb_generar
this.cb_1=create cb_1
this.st_1=create st_1
this.sle_1=create sle_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.mle_mensaje
this.Control[iCurrent+2]=this.st_titulo
this.Control[iCurrent+3]=this.em_anio
this.Control[iCurrent+4]=this.st_2
this.Control[iCurrent+5]=this.cb_generar
this.Control[iCurrent+6]=this.cb_1
this.Control[iCurrent+7]=this.st_1
this.Control[iCurrent+8]=this.sle_1
end on

on w_int_arau_nominal_alumnos.destroy
call super::destroy
destroy(this.mle_mensaje)
destroy(this.st_titulo)
destroy(this.em_anio)
destroy(this.st_2)
destroy(this.cb_generar)
destroy(this.cb_1)
destroy(this.st_1)
destroy(this.sle_1)
end on

event ue_leer_parametros;call super::ue_leer_parametros;string param

/* Carga los parámetros en una variable auxiliar para no perder los originales */
param = at_op.uof_GetParametros()

/******************************************************************************
Parámetros:   1. dw de listado de alumnos (Nuevos Inscriptos y Reinscriptos por titulo araucano)
              2. dw de listado de materias aprobadas por los alumnos en el año academico.
              3. dw de listado de alumnos en ciclos comunes sin titulo araucano y que no
				     estan en carreras de grado asociadas al ciclo comun
              4. dw de listado de materias aprobadas por los alumnos que estan solo en Ciclos Comunes
******************************************************************************/



ids_alumnos = CREATE uo_ds
ids_alumnos.uof_setdataobject(wf_ProxParam(param)) // d_int_arau_nominal_archivo0
ids_alumnos.SetTransObject(SQLCA)

ids_oferta = CREATE uo_ds
ids_oferta.uof_setdataobject(wf_ProxParam(param)) // d_int_arau_nominal_archivo1
ids_oferta.SetTransObject(SQLCA)

ids_rend = CREATE uo_ds
ids_rend.uof_setdataobject(wf_ProxParam(param)) // d_int_arau_nominal_archivo2
ids_rend.SetTransObject(SQLCA)



end event

event ue_preprocesar;call super::ue_preprocesar;String  ls_fecha
ib_grabar = true

// Valido el directorio donde se generaran los archivos
If Not(isNull(sle_1.Text)) AND sle_1.Text <> '' Then
	if Not FileExists(sle_1.Text) then
		MessageBox("Atencion!",'Debe ingresar un directorio válido para guardar los archivos a generar', StopSign!)
		sle_1.SetFocus()
		ib_grabar = false
		Return
	End If
End If

// Valido el año academico
il_anio = Long(em_anio.text)

if IsNull(il_anio) OR il_anio <= 2000 OR il_anio >= Year(f_fecha_actual()) Then
		MessageBox("Atencion!",'Debe ingresar un año académico válido', StopSign!)
		em_anio.SetFocus()
		ib_grabar = false
		Return
End If


// Mensaje de confirmacion de generaion de archivos
IF Messagebox('Atención','¿Genera archivos de información nominal de alumnos para el año académico ' + string(il_anio) + '?',Question!,YesNo!,1) = 2 then 
	ib_grabar = false
	Return
End If

// Path de los archivos a generar
is_path = sle_1.Text
If Right(is_path,1) <> "\" then
	is_path = is_path + "\"
End If


String ls_ua
ls_ua = f_unidad_academica()
ls_fecha = String(f_fecha_actual(), 'yyyy-mm-dd')

// Defino nombres de los archivos
is_archivo0   = 'archivo0_' + ls_ua + '_' + string(il_anio) + '_' + ls_fecha + '.txt'
is_archivo1   = 'archivo1_' + ls_ua + '_' + string(il_anio) + '_' + ls_fecha + '.txt'
is_archivo2   = 'archivo2_' + ls_ua + '_' + string(il_anio) + '_' + ls_fecha + '.txt'

end event

event ue_procesar;String  parametros[], ls_datos, ls_alumnos_cc, ls_mensaje, ls_rtn
Long	  ll_cant_alumnos, ll_cant_alumnos_cc, ll_fila, rtn, i, ll_rtn, ll_FileNum, ll_materias, ll_oferta, ll_rend
Boolean  ib_sin_fecha_nac  = false
SetPointer(HourGlass!)
ib_alumnos = false
ib_rendimiento = false
ib_oferta = false


This.Event trigger ue_ok('* Generando información nominal de alumnos ...')
parametros[1] = String(il_anio)

/* Declaro el stored Procedure para generar la informacion de alumnos nominales y materias aprobadas */
DECLARE sp_generar_archivos PROCEDURE FOR  sp_arau_nominal(:il_anio);

/* Ejecuto el Stored Procedure */
EXECUTE sp_generar_archivos;

/* Error al ejecutar el SP */
If SQLCA.sqlcode = -1 THEN
   This.Event trigger ue_error('Error al generar información. ' + SQLCA.SQLErrText)
	ib_grabar = false
	CLOSE sp_generar_archivos;
	Return
ElseIf SQLCA.sqlcode = 0 THEN

	FETCH NEXT sp_generar_archivos INTO :ll_rtn, :ls_rtn;
	If SQLCA.sqlcode = -1 THEN
	   This.Event trigger ue_error('Error al generar información. ' + SQLCA.SQLErrText)
		CLOSE sp_generar_archivos;
		Return
	ELSE
		// Muestro el mensaje
		This.Event trigger ue_ok(ls_rtn)
	End If
	
	/* Cierro el SP. Si sqlcode = 100 el cursor se cierra automaticamente */
	CLOSE sp_generar_archivos;
	
//ElseIf SQLCA.sqlcode = 100 THEN
//	FETCH sp_generar_archivos INTO :ll_cant_alumnos;
//	If SQLCA.sqlcode = -1 THEN
//	   This.Event trigger ue_error('Error al genarar información. ' + SQLCA.SQLErrText)
//		Return
//	End If
//	/* El cursor se cierra automaticamente */
END IF



// --------------------------------------------------------------------
// 1. Recupero alumnos y genero archivo 0
// --------------------------------------------------------------------
rtn = ids_alumnos.uof_retrieve(parametros[])
if rtn < 0 THEN
	// Error
	This.Event trigger ue_error('Error al recuperar datos de alumnos. Archivo: ' + is_archivo0)
	Return

elseif rtn = 0 THEN
	// No se recuperaron alumnos..
else
	
	// ---------------------------------------------------------------------------------------------------
	// Creo el archivo de "año académico" + _alumnos_nominales.txt
	// ---------------------------------------------------------------------------------------------------
	ll_cant_alumnos = ids_alumnos.RowCount()
	IF ll_cant_alumnos > 0 THEN
		ib_alumnos = true

		This.Event trigger ue_ok('** Generando archivo de alumnos **')
		
		ll_FileNum = FileOpen(is_path + is_archivo0, LineMode!, Write!, LockWrite!, Replace!)
		if ll_FileNum <= 0 then
			// Error
			This.Event trigger ue_error('Error al crear el archivo de alumnos ' + is_archivo0)
			Return
		END IF
			
		
		FOR i = 1 to ll_cant_alumnos
		
			// Genero el registro del archivo de alumnos
			ls_datos  = String(ids_alumnos.GetitemNumber(i,'tipo_documento')) + "|" 
			ls_datos += ids_alumnos.GetitemString(i,'nro_documento') + "|" 
			if IsNull(ids_alumnos.GetitemString(i,'cuil_cuit')) THEN
				ls_datos += "|" 
			ELSE	
				ls_datos += ids_alumnos.GetitemString(i,'cuil_cuit') + "|" 
			END IF	

			ls_datos += String(ids_alumnos.GetitemNumber(i,'genero')) + "|" 
	
			if IsNull(ids_alumnos.GetitemString(i,'fecha_nacimiento')) THEN
				ib_sin_fecha_nac  = true
				ls_datos += "|" 
			ELSE	
				ls_datos += ids_alumnos.GetitemString(i,'fecha_nacimiento') + "|" 
			END IF	
			
			ls_datos += trim(ids_alumnos.GetitemString(i,'horas_trabajo')) + "|" 
			ls_datos += String(ids_alumnos.GetitemNumber(i,'nivel_inst_padre')) + "|" 
			ls_datos += String(ids_alumnos.GetitemNumber(i,'nivel_inst_madre')) + "|" 
			ls_datos += String(ids_alumnos.GetitemNumber(i,'nacimiento_pais')) + "|" 

			if IsNull(ids_alumnos.GetitemNumber(i,'nacimiento_loc')) THEN
				ls_datos += "|" 
			ELSE	
				ls_datos += String(ids_alumnos.GetitemNumber(i,'nacimiento_loc')) + "|" 
			END IF	

			// Escribo en el archivo.	
			ll_rtn = FileWrite(ll_FileNum, ls_datos)
			if ll_rtn = -1 then
				// Error
				This.Event trigger ue_error('Error al escribir en el archivo ' + is_archivo0)
				Return
			END IF
			
		Next
	
		// Cierro el Archivo
		ll_rtn = FileClose(ll_FileNum)
		if ll_rtn = -1 then
			// Error
			This.Event trigger ue_error('Error al guardar el archivo ' + is_archivo0)
			Return
		END IF
	end if // ll_cant_alumnos > 0
end if


// Error
IF ib_sin_fecha_nac then
	This.Event trigger ue_error('Atención: Existen alumnos sin fecha de nacimiento. Por favor cargue la fecha de nacimiento a estos alumnos para poder generar los archivos.')
	Return
END IF

// --------------------------------------------------------------------
// 2. Genero archivo 1
// --------------------------------------------------------------------
rtn = ids_oferta.uof_retrieve(parametros[])
if rtn < 0 THEN
	// Error
	This.Event trigger ue_error('Error al recuperar datos de oferta académica.')
	Return
elseif rtn = 0 THEN
	// No se recuperaron alumnos..
else
	
	// ---------------------------------------------------------------------------------------------------
	// Creo el archivo de "año académico" + _alumnos_nominales_materias.txt
	// ---------------------------------------------------------------------------------------------------
	ll_oferta = ids_oferta.RowCount()
	if ll_oferta > 0 THEN
		ib_oferta = true
		This.Event trigger ue_ok('** Generando archivo de oferta académica **')
		
		ll_FileNum = FileOpen(is_path + is_archivo1, LineMode!, Write!, LockWrite!, Replace!)
		if ll_FileNum <= 0 then
			// Error
			This.Event trigger ue_error('Error al crear el archivo ' + is_archivo1)
			Return
		END IF
			
		
		FOR i = 1 to ll_oferta
		
			// Genero el registro del archivo de alumnos
			ls_datos  = String(ids_oferta.GetitemNumber(i,'tipo_documento')) + "|" 
			ls_datos += ids_oferta.GetitemString(i,'nro_documento') + "|" 
			if IsNull(ids_oferta.GetitemString(i,'cuil_cuit')) THEN
				ls_datos += "|" 
			ELSE	
				ls_datos += ids_oferta.GetitemString(i,'cuil_cuit') + "|" 
			END IF	

			ls_datos += String(ids_oferta.GetitemNumber(i,'instituc_araucano')) + "|" 
			ls_datos += String(ids_oferta.GetitemNumber(i,'titulo_araucano')) + "|" 
			ls_datos += String(ids_oferta.GetitemNumber(i,'anio_ingreso')) + "|" 
			ls_datos += String(ids_oferta.GetitemNumber(i,'forma_ingreso')) + "|" 

			if IsNull(ids_oferta.GetitemString(i,'fecha_egreso'))  THEN
				ls_datos += "|" 
			ELSE	
				ls_datos += ids_oferta.GetitemString(i,'fecha_egreso') + "|" 
			END IF	
			
			IF isNull(String(ids_oferta.GetitemNumber(i,'procedencia'))) Then
				ls_datos += "|" 
			ELSE	
				ls_datos += String(ids_oferta.GetitemNumber(i,'procedencia')) + "|" 
			END IF	
	
			// Escribo en el archivo.	
			ll_rtn = FileWrite(ll_FileNum, ls_datos)
			if ll_rtn = -1 then
				// Error
				This.Event trigger ue_error('Error al escribir en el archivo 1: ' + is_archivo1)
				Return
			END IF
		Next
	
		// Cierro el Archivo
		ll_rtn = FileClose(ll_FileNum)
		if ll_rtn = -1 then
			// Error
			This.Event trigger ue_error('Error al guardar el archivo 1: ' + is_archivo1)
			Return
		END IF
	
   END IF // ll_materias > 0 
END IF



// --------------------------------------------------------------------
// 2. Genero archivo 2
// --------------------------------------------------------------------
rtn = ids_rend.uof_retrieve(parametros[])
if rtn < 0 THEN
	// Error
	This.Event trigger ue_error('Error al recuperar datos de rendimiento académico. Archivo 2: ' + is_archivo2)
	Return
elseif rtn = 0 THEN
	// No se recuperaron alumnos..
else
	
	// ---------------------------------------------------------------------------------------------------
	// Creo el archivo de "año académico" + _alumnos_nominales_materias.txt
	// ---------------------------------------------------------------------------------------------------
	ll_rend = ids_rend.RowCount()
	if ll_rend > 0 THEN
		ib_rendimiento = true
		This.Event trigger ue_ok('** Generando archivo de rendimiento académico **')
		
		ll_FileNum = FileOpen(is_path + is_archivo2, LineMode!, Write!, LockWrite!, Replace!)
		if ll_FileNum <= 0 then
			// Error
			This.Event trigger ue_error('Error al crear el archivo 2:' + is_archivo2)
			Return
		END IF
			
		
		FOR i = 1 to ll_rend
		
			// Genero el registro del archivo de alumnos
			ls_datos  = String(ids_rend.GetitemNumber(i,'tipo_documento')) + "|" 
			ls_datos += ids_rend.GetitemString(i,'nro_documento') + "|" 
			if IsNull(ids_rend.GetitemString(i,'cuil_cuit')) THEN
				ls_datos += "|" 
			ELSE	
				ls_datos += ids_rend.GetitemString(i,'cuil_cuit') + "|" 
			END IF	

			if IsNull(ids_rend.GetitemNumber(i,'instituc_araucano')) THEN
				ls_datos += "|" 
			ELSE	
				ls_datos += String(ids_rend.GetitemNumber(i,'instituc_araucano')) + "|" 
			END IF	
			ls_datos += String(ids_rend.GetitemNumber(i,'titulo_araucano')) + "|" 
			ls_datos += ids_rend.GetitemString(i,'fecha') + "|" 
			ls_datos += String(ids_rend.GetitemNumber(i,'resultado')) + "|" 
			ls_datos += ids_rend.GetitemString(i,'materia') + "|" 
			ls_datos += ids_rend.GetitemString(i,'materia_nombre') + "|" 
			if isNull(ids_rend.GetitemNumber(i,'carga_horaria')) then
				ls_datos += "|" 
			else
				ls_datos += String(ids_rend.GetitemNumber(i,'carga_horaria')) + "|" 
			end if	
			ls_datos += ids_rend.GetitemString(i,'obligatoriedad') + "|" 
			ls_datos += String(ids_rend.GetitemNumber(i,'forma_aprobacion')) + "|" 

			if IsNull(ids_rend.GetitemString(i,'nro_libro')) THEN
				ls_datos += "|" 
			ELSE	
				ls_datos += ids_rend.GetitemString(i,'nro_libro') + "|" 
			END IF	

			if IsNull(ids_rend.GetitemString(i,'nro_acta')) THEN
				ls_datos += "|" 
			ELSE	
				ls_datos += ids_rend.GetitemString(i,'nro_acta') + "|" 
			END IF	

			if IsNull(ids_rend.GetitemNumber(i,'folio_fisico')) then
				ls_datos += "|" 
			else	
				ls_datos += String(ids_rend.GetitemNumber(i,'folio_fisico')) + "|" 
			end if	
			
			if IsNull(ids_rend.GetitemString(i,'expediente')) then
				ls_datos += "|" 
			else	
				ls_datos += ids_rend.GetitemString(i,'expediente') + "|" 
			end if	


			// Escribo en el archivo.	
			ll_rtn = FileWrite(ll_FileNum, ls_datos)
			if ll_rtn = -1 then
				// Error
				This.Event trigger ue_error('Error al escribir en el archivo 2:' + is_archivo2)
				Return
			END IF
		Next
	
		// Cierro el Archivo
		ll_rtn = FileClose(ll_FileNum)
		if ll_rtn = -1 then
			// Error
			This.Event trigger ue_error('Error al guardar el archivo 2: ' + is_archivo2)
			Return
		END IF
	
   END IF // ll_rend > 0 
END IF


// FIN
ls_mensaje = '* Proceso finalizado!!! ~r~n~r~nSe generaron los archivos: ~r~n    '
if ib_alumnos then
	ls_mensaje += is_archivo0 + '~r~n    '
end if	
if ib_oferta then
	ls_mensaje += is_archivo1 + '~r~n    '
end if	
if ib_rendimiento then
	ls_mensaje += is_archivo2 + '~r~n    '
end if	
This.Event trigger ue_ok(ls_mensaje)


SetPointer(Arrow!)

end event
event ue_acomodar_objetos;call super::ue_acomodar_objetos;//Integer ancho_para_dw, largo_para_dw, lAux
//ancho_para_dw = This.Width - s_esp.ancho - 2 * s_esp.borde
//largo_para_dw = This.Height - s_esp.largo - 2 * s_esp.borde
//Integer y_path
//
//This.SetRedraw(FALSE)
//
//If isValid(dw_param) Then
//	/* Ajusta el tamaño de dw_param */
//	dw_param.Width = min(dw_param.uof_ancho(), ancho_para_dw)
//	This.wf_CentrarObjeto(dw_param)
//	dw_param.Height = dw_param.uof_largo()
//	y_path = dw_param.Y + dw_param.Height
//End If
//
//st_1.Y  = y_path
//cb_1.y  = st_1.y
//sle_1.y = st_1.y
////This.wf_CentrarObjeto(st_1)
////st_1.X = st_1.X - st_1.Width / 2 - s_esp.borde
//st_1.X = s_esp.borde
//cb_1.X = st_1.X + st_1.Width + s_esp.borde
//sle_1.X = cb_1.X + cb_1.Width + s_esp.borde
//sle_1.Width = ancho_para_dw - sle_1.X
//
//st_2.Y = st_1.Y + st_1.Height + 5 * s_esp.borde
//This.wf_CentrarObjeto(st_2)
//
//This.SetRedraw(TRUE)

end event

event close;call super::close;if isvalid(ids_alumnos) then destroy ids_alumnos
if isvalid(ids_rend) then destroy ids_rend
if isvalid(ids_oferta) then destroy ids_oferta

end event

type mle_mensaje from multilineedit within w_int_arau_nominal_alumnos
integer x = 101
integer y = 760
integer width = 2784
integer height = 740
integer taborder = 50
integer textsize = -11
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
boolean vscrollbar = true
boolean autovscroll = true
borderstyle borderstyle = stylelowered!
end type

type st_titulo from statictext within w_int_arau_nominal_alumnos
integer x = 73
integer y = 56
integer width = 2848
integer height = 96
integer textsize = -14
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = roman!
string facename = "Times New Roman"
long textcolor = 16711680
long backcolor = 12632256
string text = "Araucano -  Información nominal de alumnos"
boolean focusrectangle = false
end type

type em_anio from editmask within w_int_arau_nominal_alumnos
integer x = 713
integer y = 352
integer width = 283
integer height = 96
integer taborder = 30
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 128
alignment alignment = center!
borderstyle borderstyle = stylelowered!
string mask = "#####"
boolean usecodetable = true
end type

type st_2 from statictext within w_int_arau_nominal_alumnos
integer x = 59
integer y = 364
integer width = 622
integer height = 88
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 8388608
long backcolor = 12632256
string text = "Año Académico:"
alignment alignment = right!
boolean focusrectangle = false
end type

type cb_generar from commandbutton within w_int_arau_nominal_alumnos
integer x = 1019
integer y = 560
integer width = 873
integer height = 128
integer taborder = 40
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Generar Archivos"
end type

event clicked;Parent.Event trigger ue_generar_archivos()
end event

type cb_1 from commandbutton within w_int_arau_nominal_alumnos
integer x = 2647
integer y = 216
integer width = 96
integer height = 88
integer taborder = 20
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "..."
end type

event clicked;cat_response_string at_rep


Open(w_seleccion_directorio)

at_rep = Message.PowerObjectParm

if at_rep.retorno = 1 Then sle_1.Text = at_rep.cadena

end event

type st_1 from statictext within w_int_arau_nominal_alumnos
integer x = 64
integer y = 220
integer width = 622
integer height = 88
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 8388608
long backcolor = 12632256
string text = "Generar archivos en:"
alignment alignment = right!
boolean focusrectangle = false
end type

type sle_1 from singlelineedit within w_int_arau_nominal_alumnos
event doubleclick pbm_lbuttondblclk
integer x = 713
integer y = 212
integer width = 1906
integer height = 88
integer taborder = 10
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 128
string text = "C:\"
borderstyle borderstyle = stylelowered!
end type

event doubleclick;integer iAux
string ls_pathfile, ls_file
ls_pathfile = "Archivos.txt"

iAux = getfilesavename("Seleccione un directorio", ls_pathfile, ls_file)

If iAux = 1 Then
	this.text = Left(ls_pathfile, len(ls_pathfile) - len(ls_file))
End If

end event

