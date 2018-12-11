function [ V ] = M2V( M )
%M2V Organiza los elementos de una matriz  en forma de vector 
%   Debido a que simulink is signal based, las matrices se deben pasar en
%   forma de vectores para pasarlas entre bloques como una señal. Para
%   poder hacer uso de la implementacion de optimizacion cuadratica en
%   simulink se hace uso de esta ffuncion para poder pasar las matrices H y
%   F cono vectores al bloque qpsolver.


sz = size(M);

v = zeros(1, sz(1)*sz(2));

for k =1:1:sz(1) % se concatena cada fila de la matriz en un vector v
    v((k-1)*sz(2)+1 : k*sz(2)) = M(k, 1:end);
end

V = v; % output

