clear
close all
clc

load('reference_level.mat')
Te=1;
%maximum and minimum flow rate
q_min=0;
q_max=1.5e-4;

%maximum and minimum level
h_min=0;
h_max=0.62;

%simulation period to solve differential equation
Tsimulation=1;

%Initial level value
level_1_ini=0.4;
level_3_ini=0.3;
level_2_ini=0.2;

%Operating point for the level
level_1_ptf=0.4;
level_3_ptf=0.3;
level_2_ptf=0.2;

%Operating point for the flow rate
flow_rate_1_ptf=0.35e-4;
flow_rate_2_ptf=0.375e-4;

%simulation period to solve differential equation
Tsimulation=1;

% Parameters value of three?tank system
mu13=0.5; mu20=0.675; mu32=0.5;
S=0.0154; Sn=5e-5; W=sqrt(2*9.81);
% Output operat ing Points (m)
Y10=0.400; Y20=0.200; Y30=0.300;
% Input operat ing Points (m3/s )
U10=0.350e-004; U20=0.375e-004;
% Matrix A
A11=-(mu13*Sn*W)/(2*S*sqrt(Y10-Y30)); 
A12=0;
A13=-A11 ;
A21=0;A23=(mu32*Sn*W)/(2*S*sqrt(Y30-Y20));
A22=-A23-((mu20*Sn*W)/(2*S*sqrt(Y20)));
A31=-A11;
A32=A23; 
A33=-A32-A31;
A=[A11 A12 A13 ; A21 A22 A23 ; A31 A32 A33 ] ;
% Matrix B
B11=1/S ; B12=0;
B21=0;B22=1/S ;
B31=0;B32=0;
B=[B11 B12 ; B21 B22 ;B31 B32 ] ;
% Continuous to discret state space transformat ion
[Ad, Bd] = c2d (A,B,1.0) ;
C=eye(3);

% Gain matrices for closed loop para controlador por realimentacion de estados 
K1=[21.6 3 -5;2.9 19 -4]*10e-4;
K2=[-0.95 -0.32;-0.3 -0.91]*10e-4;

%For instance for a fault on Pump 1
Fd=Bd(:,1) ;
% Fd=[zeros(3,2) [1 0 0; zeros(2,3)]];
%produce a complete singular value decomposition
[T,R,M]=svd(Fd) ;
Abar=inv(T)*Ad*T; 
A11bar=Abar(1,1);
A12bar=Abar(1,2:3);
Bbar=inv(T)*Bd; 
B1bar=[Bbar(1,:)];
Mat_associated_to_x1=M*inv(R(1,1));
Mat_associated_to_A11=-M*inv(R(1,1))*A11bar;
Mat_associated_to_A12=-M*inv(R(1,1))*A12bar;
Mat_associated_to_B1=-M*inv(R(1,1))*B1bar ;


%Matrices para el control tolerante a fallos

% Fx=[B zeros(3,3)];
% Fy=[zeros(3,2) eye(3)];
% Fd=[]
% [E,T,K,H]=uio_linear(Ad,Bd,C,Fd)