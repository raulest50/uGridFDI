function [E,T,K,H]=uio_linear (A,B,C,Fd)
% Reference
% Chapter 3 ? Robust r e s idual generation via UIOs
% page 77.
% Robust Model?Based Faul t Diagnosis for Dynamic Syst .
% Jie Chen and R. J . Patton
% Kluwer Avademic Pu b l i s he r s
% 1999
% Algorithm
% dx(t)/dt = A x(t)+ B u(t) + Fd d(t)
% y(t) = C x(t)
% to built an UIO
% 1 a ) The number of ouputs ( row of C) must be g r eat e r
% than the number of unknown input s (Column of Fd)
% 1 b ) Check the rank condit ion for Fd and CFd
% 2 ) Compute H, T, and A1
% H = Fd ? inv [ (C Fd) ’? (C Fd ) ] ? (C Fd) ’
% T = I ? H C
% A1 = T A
% 3 ) Check the o b s e r v a b i l i t y :
% I f (C, A1) observable , a UIO e x i t s and K1 can be
% computed using pole placement
% Remark : The choice of pole placement i s f i x ed here
% wi th 0.9 ? eigen value of A1
% 4 ) Compute E, K to b u i l t the f o l l owi n g UIO
%
% dz ( t )/ dt = E z ( t ) + T B u( t ) + K y( t )
% x est ( t ) = z ( t ) + H y( t )
%
% with
% E= A1 ? K1 C
% K= K1 + E H

% 0 ) Check input cond i t ions
if nargin ~=4
error( 'Number of input arguments incorrect! type_help_uio_chen' ) , 
return
end

% 1 a ) The number of ouputs ( row of C) must be g r eat e r
% than the number of unknown input s (Column of Fd)
nb_Fd=size(Fd); 
nb_C=size(C); 
nb_row_C=nb_C(1);
nb_column_Fd=nb_Fd(2);
if ( nb_column_Fd > nb_row_C ),
error('The number o f ouputs ( row o f C) must be g r e a te r than the number o f unknown inputs ( column o f Fd)' )
return
end

% 1 b ) Check the rank condit ion for Fd and CFd
if (rank(C*Fd) ~= rank(Fd) )
error('rank(C*Fd)==rank (Fd)' ) , 
return , 
end
% 2 ) Compute H, T, and A1
nb_A=size(A); 
H=Fd*inv((C*Fd)'*(C*Fd))*(C*Fd)';
T=eye(nb_A(1))-(H*C) ; 
A1=T*A;
% 3 ) Check the observability : If (C, A1) observable ,
% a UIO exits and K1 can be computed us ing pole
% placement
if (rank(obsv(A1,C)) ~= nb_A(1) ) ,
error('(C,A1) should be observable') ,
return ,
end

pole=eig(A1); 
K1=place(A',C',[0.9* pole]) ; 
K1=K1';
% 4 ) Compute E, K to b u i l t the f o l l owi n g UIO
E=A1-K1*C; 
K=K1+E*H;

end