% la implementacion del control MPC con DMC (dynamic matrix control)
% requiere del calculo de unas matrices dinamicas paera la respuesta
% forzada y la respuesta libre. Estas matrices se pueden calcular offline
% previo al inicio de funcionamiento del MPC. las matrices dinamicas se
% contruyen con el modelo de convolucion del sistema que se desea controlar
% (el DMC emplea la respuesta al impulso)


% parametros del MPC
p = 20; % horizonte de prediccion.
Nu = 20; % horizonte de control.


load('FitData'); % se caga el ws con el modelo lineal del sistema.

% se discretiza el modelo continuo
mMz = c2d(tf1, 30e-3);

% se obtiene la respuesta al escalon, la cual permite calcular las salidas
% del sistema al hacer convolucion con las diferencias de las entradas.
% contiene 4 componentes porque se trata de un sistema de 2 entradas y
% cuatro salidas.
n = 2*p; % numero de muestras.
Yz = step(mMz, n*1e-3);

% al discretizar con tiempo de muestreo de 1ms, el sistema se estabiliza en
% la muestra 81. para redondear se trabajara con 200 muestras para la
% prediccion, que es un tiempo mucho mayor al de estabilizacion.


% calculo de la matriz dinamica
Gpp = convmtx(Yz(:, 1, 1), Nu);
Gqp = convmtx(Yz(:, 1, 2), Nu);

Gpq = convmtx(Yz(:, 2, 1), Nu);
Gqq = convmtx(Yz(:, 2, 2), Nu);

% matriz dinamica para la respuesta forzada.
G = [Gpp(1:p, 1:Nu) Gqp(1:p, 1:Nu) ; Gpq(1:p, 1:Nu) Gqq(1:p, 1:Nu)];

% matriz dinamica para la respuesta libre.
GF = [free(Yz(:, 1, 1), p, Nu) free(Yz(:, 1, 2), p, Nu); ...
      free(Yz(:, 2, 1), p, Nu) free(Yz(:, 2, 2), p, Nu)];



% funcion local que calcula la matriz de respuesta libre.
function y = free(Yz, p, n)
    T = zeros(p, n);
    for j=1:1:p
        T(j,:) = Yz(j+1:n+j)-Yz(1:n);
    end
    y = T;
end





















%Nota:
% esto no tiene que ver con el algoritmo DMC, simplemente deseo anotar el
% resultado de un proceso algebraico de otra cosa en este script antes de
% que se me olvide.
% 
% resultado de adaptar el modelo de prediccion sin perturbaciones
% proveniente del state space model discreto generico al problema de
% de programacion cuadratica estandar: min: x' Q x +f' x .
% U'H'H U + (-2 r' H + 2 G' x H ) U
% Q = H'H 
% f' =  (-2 r' H + 2 G' x H )'
