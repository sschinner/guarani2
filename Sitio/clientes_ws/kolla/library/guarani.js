  /**
   * Elimina los caracteres en blanco 
   * a la izquierda de la cadena.
   */
  function leftTrim(sString)
  {
    while (sString.substring(0,1) == ' ')
    {
      sString = sString.substring(1, sString.length);
    }
    return sString;
   }

  /**
   * Elimina los caracteres en blanco 
   * a la derecha de la cadena.
   */
  function rightTrim(sString)
  {
    while (sString.substring(sString.length-1, sString.length) == ' ')
    {
      sString = sString.substring(0,sString.length-1);
    }
    return sString;
  }

  /**
   * Elimina los caracteres en blanco 
   * a izquierda y a derecha de la cadena.
   */
  function trimAll(sString)
  {
    while (sString.substring(0,1) == ' ')
    {
      sString = sString.substring(1, sString.length);
    }
    while (sString.substring(sString.length-1, sString.length) == ' ')
    {
      sString = sString.substring(0,sString.length-1);
    }
    return sString;
  }

  /**
   * Devuelve el valor numerico
   * del rojo de un color.
   */
  function red(color)
  {
  	if (isFinite(color))
    {
      return color / (255*255*255);
    }
    else if (color.substring(0,3).toUpperCase() == 'RGB')
    {
      coma1 = color.indexOf(',',0);
      return parseInt(color.substring(4,coma1));
    }
    else if (color.substring(0,1) == '#')
    {
      return parseInt(color.substr(1,2), 16);
    }
  }

  /**
   * Devuelve el valor numerico
   * del verde de un color.
   */
  function green(color)
  { 
    if (isFinite(color))
    {
      return color / (255*255);
    }
    else if (color.substring(0,3).toUpperCase() == 'RGB')
    {
      coma1 = color.indexOf(',',0);
      coma2 = color.indexOf(',',coma1+1);
      par = color.indexOf(')',coma2+1);

      return parseInt(color.substring(coma1+1,coma2));
    }
    else if (color.substring(0,1) == '#')
    {
      return parseInt(color.substr(3,2), 16);
    }
  }

  /**
   * Devuelve el valor numerico
   * del azul de un color.
   */
  function blue(color)
  {
    if (isFinite(color))
    {
      return color / (255);
    }
    else if (color.substring(0,3).toUpperCase() == 'RGB')
    {
      coma1 = color.indexOf(',',0);
      coma2 = color.indexOf(',',coma1+1);
      par = color.indexOf(')',coma2+1);

      return parseInt(color.substring(coma2+1,par));
    }
    else if (color.substring(0,1) == '#')
    {
      return parseInt(color.substr(5,2), 16);
    }
  }

  /**
   *  Constantes globales para fadetext.
   */
  RedFade = -1;
  GreenFade = -1; 
  BlueFade = -1;
 
  FadeArray = new Array();
  FadeIndex = 0;

  FadeTextArray = new Array();
  FadeTextIndex = 0;

  /*
  * Id: Identificador del objeto DOM a modificar
  * velocidad: Valor de decrementar o incrementar el color.
  * sentido:    -1: el color cicla del color original al negro
  *              1: el color cicla del color original al blanco
  * sentidoActual:  parametro interno, debe estar en -1 siempre que se lo invoca.
  */
  function fadetext(id, velocidad, sentido, sentidoActual)
  { 
    if (FadeTextArray.length == 0)
      return

    //_color = document.getElementById(id).style.color;
    _color = getStyle('mensajes_ua','color');
  
    if (RedFade == -1)
    {
      RedFade = red(_color);
      GreenFade = green(_color); 
      BlueFade = blue(_color);

      r = red(_color);
      g = green(_color);
      b = blue(_color);

      FadeIndex = 0;
      while (((r > 0 || g > 0 || b > 0) && sentido == -1) || ((r < 255 || g < 255 || b < 255) && sentido == 1))  
      {
        r += sentido * velocidad; if (r < 0) r = 0; if (r > 255) r = 255; 
        g += sentido * velocidad; if (g < 0) g = 0; if (g > 255) g = 255;
        b += sentido * velocidad; if (b < 0) b = 0; if (b > 255) b = 255;

        FadeArray[FadeIndex] = "rgb("+r+","+g+","+b+")";

        FadeIndex++;
      }

      FadeIndex = 0;
      FadeTextIndex = -1;

      sentidoActual *= -1;
    }


    if (FadeIndex >= 0 && FadeIndex < FadeArray.length)
      document.getElementById(id).style.color = FadeArray[FadeIndex];

    FadeIndex += sentidoActual;
       
    if (FadeIndex == FadeArray.length || FadeIndex < 0) {
      sentidoActual *= -1;
    }

    if (FadeIndex == FadeArray.length) 
    {
      FadeTextIndex++;

      if (FadeTextIndex == FadeTextArray.length)
        FadeTextIndex = 0;

      document.getElementById(id).innerHTML = FadeTextArray[FadeTextIndex];
    }

    setTimeout("fadetext('" + id + "'," + velocidad + "," + sentido + "," + sentidoActual + ")",100); 
  }

  /**
   *  Abre una ventana pero antes controla que 
   *  no se haya vencido la sesion.
   */
  function popup(mylink, ancho, alto, params)
  {
    var href;

    if (typeof(mylink) == 'string')
		  href = mylink;
	  else
		  href = mylink.href;

    ultimo = new Date(tiempoUltimoAcceso * 1000); // Agrego los milisegundos 
    var hoy = new Date(); // Hora en el equipo cliente		 
    ahora = hoy.getTime() + (diff_horaria * 1000); // Le sumo la diferencia horaria para poder comparar 
                                           // este tiempo con el del webserver.      

    minDesocupado = Math.floor((ahora - ultimo.getTime())/(60 * 1000)) ;

    if (minDesocupado >= tiempoVencimiento && NombreUsuario != '')
    { 
      window.location = '../../notificarse.php?fStatus=-1&fMsg=' + escape('Se venció el tiempo la sesión. La sesión dura ' + tiempoVencimiento + ' minutos.') +  '&fueraFrameSet=1';

      /* Para que los tags tipo link no abran tambien el link en la misma ventana actual*/
      return false;
    } 
    else 
    {
      x = (window.screen.width - ancho) / 2;
      y = (window.screen.height - alto) / 2;

      window.open(href, '_blank', 'width=' + ancho + ',height=' + alto + ',left=' + x + ',top=' + y + ',' + params);

      /* Para que los tags tipo link no abran tambien el link en la misma ventana actual*/
      return false;
    }
  }

  /**
   *  Wrapper para compatibilidad.
   */
  function popup2(mylink, ancho, alto)
  { 
    return popup(mylink, ancho, alto,'scrollbars=yes, resizable=no, status=no');
  }
 
  /**
   *  Retorna el estilo de un componente en HTML.
   */
  function getStyle(el,styleProp)
  {
    var x = document.getElementById(el);
    var str = navigator.userAgent.toLowerCase();
   
    if (str.indexOf('msie') != -1)
        return eval('x.currentStyle.' + styleProp);
    else
        return document.defaultView.getComputedStyle(x,null).getPropertyValue(styleProp);
  }

  /**
   *  Verifica que la fecha tiene el formato dd/mm/aaaa
   *  y que sus valores son correctos.
   *  Parametros:
   *               dateObj: Componente de formulario.
   *                  desc: Descripcion de ese objeto para 
   *                        incluir en el mensaje de error.
   */
  function isValidDate(dateObj,desc) 
  {
			
    var dateStr = dateObj.value;

		if (dateStr == "")
		{
		  alert("No ingresaste fecha en el campo '" + desc + "'.")
			return false;
		}

		var datePat = /^(\d{2})(\/)(\d{2})(\/)(\d{4})$/; // requires 4 digit year

		var matchArray = dateStr.match(datePat); // is the format ok?

		if (matchArray == null) 
    {
		  alert("'" + desc + "' esta mal ingresada. Por favor, verificá que el formato ingresado de la fecha sea dd/mm/aaaa, ya que '" + dateObj.value  + "' no es una fecha válida")
			return false;
		}

		day = matchArray[1];
		month = matchArray[3]; // parse date into variables
		year = matchArray[5];

  	if (month < 1 || month > 12) 
    { // check month range
		  alert("El mes debe ser un valor entre 1 y 12.");
			dateObj.focus();
			return false;
		}

		if (day < 1 || day > 31) 
    {
		  alert("El día debe ser un valor entre 1 y 31.");
			dateObj.focus();
			return false;
		}
	
		if ((month == 4 || month == 6 || month == 9 || month == 11) && day == 31) 
    {
			alert("Fecha mal ingresada: " + month + " no tiene 31 dias.")
			dateObj.focus();
			return false;
		}	
	
		if (month == 2) 
    { // check for february 29th
		  var isleap = (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0));
			if (day > 29 || (day == 29 && !isleap)) 
      {
				alert("Febrero del " + year + " no tiene " + day + " dias.");
				dateObj.focus();
				return false;
		  }
	  }
	  return true;
  }	

  /**
   *  Convierte una fecha en string 
   *  en un objeto Date.
   *
   *  Parametros:
   *               valor: Cadena con la fecha a convertir.
   */
  function armarFecha(valor)
  { 
		var datePat = /^(\d{2})(\/)(\d{2})(\/)(\d{4})$/; // requires 4 digit year

    var matchArray = valor.match(datePat); // is the format ok?

    if (matchArray == null) 
    {
		  alert('Fecha mal ingresada. ' + valor  + ' no es una fecha válida');
			return false;
		}

	  var lday = matchArray[1];
	  var lmonth = matchArray[3] - 1; // parse date into variables
	  var lyear = matchArray[5];

	  return new Date(lyear,lmonth,lday,0,0,0); 
 }

 /**
  *  Valida emails
  *
  *  Parametros:
  *               email: Email a validar.
  */
  function isValidEmail(email) 
  {
    var validchars = "abcdefghijklmnopqrstuvwxyz0123456789@.-_";

    var c;

    if (email == null) 
      return true;

    if (email.length == 0) 
      return true;

    c = 0;
    for (var i=0; i < email.length; i++) 
    {
      var letter = email.charAt(i).toLowerCase();
      if (validchars.indexOf(letter) == -1) 
        return false;

      if (letter == "@")
        c = c + 1;

      // No puede haber mas de un @
      if (c > 1)
        return false;    
    }

    // @ debe estar en la cadena y ademas no ser el primer caracter.
    if (email.indexOf("@") < 1) 
      return false;

    // @ no puede ser el ultimo caracter
    if (email.indexOf("@") == email.length) 
      return false;

    // El punto no puede ser el ultimo caracter
    if (email.lastIndexOf(".") == email.length) 
      return false;

    // El ultimo punto no puede estar despues de la @
    if (email.lastIndexOf(".") <= email.indexOf("@")) 
      return false;

    // No pueden existir dos puntos seguidos 
    if (email.indexOf("..") >= 0) 
      return false;

    return true;
  }

