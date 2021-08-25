close all
clear all
clc

% Install flexlib
flexlib.install();

[gear, motor, drive] = parts.v4();

% Motor masses
Mm = [motor.m]';

 % Gearbox masees
Mg = [gear.m]';

% Joint masses without bolts
Mj = [
    4.5
    3.8
    1.6
];

% https://www.ullrich.com.au/extrusions/square-tube
% Check with lab guys on where to order profiles
% Profile heights
h = [
    50
    40
    30
]/1000;

% Profile widths
b = h;

% Wall thicknesses
t = [
    4
    2.5
    2
]/1000;

% Link lengths
L = [
    1.5
    1.5
    1.5
];

% Cross section areas
A = b.*h - (b - 2*t).*(h - 2*t);

% Area moments
Izz = b.*h.^3/12 - (b - 2*t).*(h - 2*t).^3/12;
Ixx = h.*b.^3/12 - (h - 2*t).*(b - 2*t).^3/12;

% Material properties and gravity constant
g = 9.81;
rho = 2700;
E = 69e9;

% Paylod mass
Mt = 3;

% Joint forces
F = [
    (Mm + Mg + Mj)*g
    Mt*g
];

% Profile load intensities
q = rho*A*g;

% Beam segement masses
Mb = A.*L*rho;

% Reaction forces and moments for fized beam
Ry = sum(F) + sum(q.*L);
Rx = 0;
M1 = L(1)*F(2) + sum(L(1:2))*F(3) + sum(L)*F(4) + q(1)*L(1)*L(1)/2 + ...
q(2)*L(2)*(L(1) + L(2)/2) + q(3)*L(3)*(L(1) + L(2) + L(3)/2);

% Shear, bending and Von-Misses stress diagrams
dx = 0.01;
x = 0:dx:sum(L);
V = zeros(size(x));
M = zeros(size(x));
sigma = zeros(size(x));

for i = 1:length(x)
    if (x(i) <= L(1))
        V(i) = Ry - F(1) - q(1)*x(i);
        
        M(i) = Ry*x(i) - M1 - F(1)*x(i) - q(1)*x(i)*x(i)/2;
        
        n = 1;
        
    elseif (L(1) < x(i)) && (x(i) <= sum(L(1:2)))
        V(i) = Ry - F(1) - F(2) - q(1)*L(1) - q(2)*(x(i) - L(1));
        
        M(i) = Ry*x(i) - M1 - F(1)*x(i) - F(2)*(x(i) - L(1)) - ...
            q(1)*L(1)*(x(i) - L(1)/2) - q(2)*(x(i) - L(1))^2/2;
        
        n = 2;
        
    elseif (sum(L(1:2)) < x(i)) && (x(i) <= sum(L))
        V(i) = Ry - F(1) - F(2) - F(3) - q(1)*L(1) - q(2)*L(2) - ...
            q(3)*(x(i) - L(1) - L(2));
        
        M(i) = Ry*x(i) - M1 - F(1)*x(i) - F(2)*(x(i) - L(1)) - ...
            F(3)*(x(i) - L(1) - L(2)) - q(1)*L(1)*(x(i) - L(1)/2) - ...
            q(2)*L(2)*(x(i) - L(1) - L(2)/2) - q(3)*(x(i) - L(1) - L(2))^2/2;
        
        n = 3;
        
    end
    
    % Von-Misses Stres
    W(n) = Izz(n)/(h(n)/2);
    sigma_x = M(i)/W(n);
    tau_yz = V(i)/A(n);
    
    sigma(i) = sqrt(sigma_x^2 + 3*tau_yz^2);
    
end
    
figure;
subplot(3,1,1)
plot(x, V)
ylabel('V(x) - [N]')
subplot(3,1,2)
plot(x, M)
ylabel('M(x) - [Nm]')
subplot(3,1,3)
plot(x, sigma/1e6)
xlabel('x - [m]')
ylabel('\sigma_v - [MPa]')


% Deflection based on M(x)
v_x = zeros(size(x));
v = zeros(size(x));

for i = 1:length(x)
    if (x(i) <= L(1))
        v_xx = M(i)/(E*Izz(1));
        
    elseif (L(1) < x(i)) && (x(i) <= sum(L(1:2)))
        v_xx = M(i)/(E*Izz(2));
        
    elseif (sum(L(1:2)) < x(i)) && (x(i) <= sum(L))
        v_xx = M(i)/(E*Izz(3));
        
    end
    
    % Numerical integration
    if i > 1
        v_x(i) = v_x(i-1) + v_xx*dx;
        v(i) = v(i-1) + v_x(i)*dx;
    end
end

figure;
subplot(2,1,1)
plot(x, v_x/pi*180);
ylabel('Curvature - [deg]')
subplot(2,1,2)
plot(x, v*1000);
ylabel('Deflection - [mm]')


sim('simulationR2019a')
robot.plotMotorCurves(q_t, q_tt, tau, 5, gear, motor)













