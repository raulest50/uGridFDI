function Output = tank_system(input);

global S Sn g mu13 mu20 mu32

L1 = input(1);
L2 = input(2);
L3 = input(3);
q1 = input(4);
q2 = input(5);

q13 = mu13*Sn*sign(L1-L3)*sqrt(2*g*abs(L1-L3));

q32 = mu32*Sn*sign(L3-L2)*sqrt(2*g*abs(L3-L2));

q20 = mu20*Sn*sqrt(2*g*L2);

L1_dot = (q1 - q13)/S;

L2_dot = (q2 + q32 - q20)/S;

L3_dot = (q13-q32)/S;

Output = [L1_dot; L2_dot; L3_dot; q20];