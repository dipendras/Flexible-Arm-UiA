function data = v2()
    
    b = 60/1000;
    h = 60/1000;
    t = 3/1000;
    A = b*h - (b-2*t)*(h-2*t);

    % Arm Parameters
    data.h = h;
    data.b = h;
    data.t = t;
    data.A = A;
    
    L1 = 1.5;
    L2 = 1.5;
    L3 = 1.5;
    
    data.L1 = L1;
    data.L2 = L2;
    data.L3 = L3;
    data.L = data.L1 + data.L2 + data.L3;
    
    % Material Parameters
    data.rho = 2700;
    data.E = 70e9;
    
    % Link Weights
    data.m1 = data.rho*L1*A;
    data.m2 = data.rho*L2*A;
    data.m3 = data.rho*L3*A;
    
    data.Izz = b*h^3/12 - (b-2*t)*(h-2*t)^3/12;
    

    %% Joint 1
    gear(1).name = 'AG2400-+TP110S-MF2-100';
    gear(1).i = 100;
    gear(1).Tn = 800;
    gear(1).Tm = 1400;
    gear(1).wn = 3400*2*pi/60;
    gear(1).wm = 4500*2*pi/60;
    gear(1).m = 34;

    motor(1).name = 'AM8053-wGyz';
    motor(1).Ts = 11.4;
    motor(1).Tr = 10.0;
    motor(1).Tm = 52.5;
    motor(1).m = 8.2;
    motor(1).wr = 2000*2*pi/60;
    motor(1).wm = 1.2*motor(1).wr;
    motor(1).Jm = 5.93*(0.01)^2;
    motor(1).Pr = 2090;

    %% Joint 2
    gear(2).name = 'AG2400-+TP025S-MF2-70';
    gear(2).i = 70;
    gear(2).Tn = 200;
    gear(2).Tm = 330;
    gear(2).wn = 3500*2*pi/60;
    gear(2).wm = 6000*2*pi/60;
    gear(2).m = 6.7;

    motor(2).name = 'AM8042-wEyz';
    motor(2).Ts = 4.1;
    motor(2).Tr = 3.9;
    motor(2).Tm = 18.5;
    motor(2).m = 4.7;
    motor(2).wr = 2500*2*pi/60;
    motor(2).wm = 1.2*motor(2).wr;
    motor(2).Jm = 1.98*(0.01)^2;
    motor(2).Pr = 1020;

    %% Joint 3
    gear(3).name = 'AG2400-+TP004S-MF2-70';
    gear(3).i = 70;
    gear(3).Tn = 40;
    gear(3).Tm = 55;
    gear(3).wn = 4500*2*pi/60;
    gear(3).wm = 6000*2*pi/60;
    gear(3).m = 1.5;

    motor(3).name = 'AM8031-wCyz';
    motor(3).Ts = 1.37;
    motor(3).Tr = 1.34;
    motor(3).Tm = 6.10;
    motor(3).m = 1.8;
    motor(3).wr = 3000*2*pi/60;
    motor(3).wm = 1.2*motor(3).wr;
    motor(3).Jm = 0.541*(0.01)^2;
    motor(3).Pr = 840;

    % Assign
    data.gear = gear;
    data.motor = motor;

end