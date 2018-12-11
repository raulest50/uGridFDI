
% funciones de transferencia que aproximan de manera lineal y con orden
% relativamente bajo el comportamiento de la potencia activa y reactiva
% para un solo convertidor.

% las entradas con un valor de potencia activa y reactiva p,q
% la salida es el valor medido desde el convertidor de potencia activa y
% reactiva, por lo que se le llamaran P, Q.

% Hpp = tf(tf1.Numerator{1,1}, tf1.Denominator{1,1}); % afectaction de p a P
% Hqp = tf(tf1.Numerator{1,2}, tf1.Denominator{1,2}); % afectacion de q a P
% 
% Hpq = tf(tf1.Numerator{2,1}, tf1.Denominator{2,1}); % afectacion de q a Q
% Hqq = tf(tf1.Numerator{2,2}, tf1.Denominator{2,2}); % afectacion de p a Q

% se agrupa de manera matricial las matrices que describen el
% comportamiento del sistema.
% mM = [Hpp Hqp; Hpq Hqq];

step(tf1); % se observa el comportamiento del modelo continuo
hold on;

% se discretiza el modelo continuo
mMz = c2d(tf1, 1e-3);

% se compara el modelo discreto con el continuo y se guarda la respuesta
step(mMz, .2);
Yz = step(mMz, .2);


% se construye la matriz de convolucion con las cuatro respuestas al
% escalon

Gpp = convmtx(Yz(:, 1, 1), 100);
Gqp = convmtx(Yz(:, 1, 2), 100);

Gpq = convmtx(Yz(:, 2, 1), 100);
Gqq = convmtx(Yz(:, 2, 2), 100);

Gm = [Gpp Gqp ; Gpq Gqq];

uv = ones(100, 1);

U = [uv*200 ; uv*500];

% calculo de la difference matrix. 
D = diag(ones(length(uv), 1), 0) - diag(ones(length(uv)-1, 1), -1);
z = zeros(length(uv), length(uv));
Dm = [D z; z D];

dU = Dm*U;

Yo = Gm*dU;

figure;

stairs(Yo(1:200));
hold on;
stairs(Yo(300:500));

