function f = f(in1,in2)
%F
%    F = F(IN1,IN2)

%    This function was generated by the Symbolic Math Toolbox version 8.4.
%    23-Sep-2019 14:11:52

L1 = in2(1,:);
L2 = in2(2,:);
L3 = in2(3,:);
q1 = in1(1,:);
q2 = in1(2,:);
q3 = in1(3,:);
t2 = q1+q2;
t3 = q3+t2;
f = [L1.*cos(q1)+L2.*cos(t2)+L3.*cos(t3);L1.*sin(q1)+L2.*sin(t2)+L3.*sin(t3)];