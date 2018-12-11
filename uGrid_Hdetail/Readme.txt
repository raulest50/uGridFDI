La libreria de true time requiere de la creacion de unos
archivos de matlab funcitons. por lo anterior para lograr un mejor
orden de los archivos la simulacion con el mayor nivel de detalle
de la microred monofasica se hace en esta carpeta.

En esta simulacion los convertidores se modelaron con interruptores
ideales, conservando la naturaleza conmutada de los mismos a diferencia
de los modelos empleados para la generacion de codigo en las raspberry pi.

Tambien se agrega en esta simulacion el uso de un control MPC para hacer un
control de las potencias de suministradas por cada uno de los convertidores.

tambien se agregan los bloques correspondientes de programacion lineal para
determinar cuales son los valores optimos de generacion de cada una de
las fuentes de la microred.

Finalmente, esta simulacion hace uso de la libreria true time, la cual 
permite modelar y validar los algoritmos de control de acuerdo a las
restricciones de tiempo real.



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
          DESCRIPCION DE CADA UNO DE LOS ARCHIVOS DE LA CARPERTA
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


EXTENCION .m
    funciones:

    scripts:

    
EXTENSION SLX:


EXTENSION .mat :











# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
                          IMPORTANTISIMO
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

cuando el paso de simlacion esta configurado como fixed step, la funcion
ttAnalogIn(_) de la true time kernel siempre arroja 0. mientras que con
variable step funciona normalmente.

tener en cuenta que true time kernel solo funciona bien con paso variable
de simulacion.







