function J = J(in1,in2)
%J
%    J = J(IN1,IN2)

%    This function was generated by the Symbolic Math Toolbox version 8.4.
%    23-Sep-2019 14:11:52

L1 = in2(1,:);
L2 = in2(2,:);
L3 = in2(3,:);
q1 = in1(1,:);
q2 = in1(2,:);
q3 = in1(3,:);
t2 = q1+q2;
t3 = cos(t2);
t4 = q3+t2;
t5 = sin(t2);
t6 = cos(t4);
t7 = sin(t4);
t8 = L2.*t3;
t9 = L2.*t5;
t10 = L3.*t6;
t11 = L3.*t7;
t12 = -t9;
t13 = -t11;
J = reshape([t12+t13-L1.*sin(q1),t8+t10+L1.*cos(q1),t12+t13,t8+t10,t13,t10],[2,3]);