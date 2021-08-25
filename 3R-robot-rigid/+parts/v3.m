function [gear, motor, drive] = v3()

    %% Joint 1
    gear(1).name = 'AG2400-+TP110S-MF2-100';
    gear(1).price = 36500;
    gear(1).i = 100;
    gear(1).Tn = 800;
    gear(1).Tm = 1400;
    gear(1).wn = 3400*2*pi/60;
    gear(1).wm = 4500*2*pi/60;
    gear(1).m = 34;

    motor(1).name = 'AM8053-wGyz';
    motor(1).price = 12700;
    motor(1).Ts = 11.4;
    motor(1).Tr = 10.0;
    motor(1).Tm = 52.5;
    motor(1).m = 8.2;
    motor(1).wr = 2000*2*pi/60;
    motor(1).wm = 1.2*motor(1).wr;
    motor(1).Jm = 5.93*(0.01)^2;
    motor(1).Pr = 2090;
    
    drive(1).name = 'AX5106';
    drive(1).Pr = 4200;
    drive(1).price = 10200;
    

    %% Joint 2
    gear(2).name = 'AG2400-+TP025S-MF2-70';
    gear(2).price = 21700;
    gear(2).i = 70;
    gear(2).Tn = 200;
    gear(2).Tm = 330;
    gear(2).wn = 3500*2*pi/60;
    gear(2).wm = 6000*2*pi/60;
    gear(2).m = 6.7;
    
    motor(2).name = 'AM8043-wEyz';
    motor(2).price = 6500;
    motor(2).Ts = 5.65;
    motor(2).Tr = 5.3;
    motor(2).Tm = 28;
    motor(2).m = 5.8;
    motor(2).wr = 2500*2*pi/60;
    motor(2).wm = 1.2*motor(2).wr;
    motor(2).Jm = 3.52*(0.01)^2;
    motor(2).Pr = 1039;
    
    drive(2).name = 'AX5103';
    drive(2).Pr = 2100;
    drive(2).price = 9800;

    %% Joint 3
    gear(3).name = 'AG2400-+TP004S-MF2-70';
    gear(3).price = 17000;
    gear(3).i = 70;
    gear(3).Tn = 40;
    gear(3).Tm = 55;
    gear(3).wn = 4500*2*pi/60;
    gear(3).wm = 6000*2*pi/60;
    gear(3).m = 1.5;

    motor(3).name = 'AM8031-wCyz';
    motor(3).price = 5300;
    motor(3).Ts = 1.37;
    motor(3).Tr = 1.34;
    motor(3).Tm = 6.10;
    motor(3).m = 1.8;
    motor(3).wr = 3000*2*pi/60;
    motor(3).wm = 1.2*motor(3).wr;
    motor(3).Jm = 0.541*(0.01)^2;
    motor(3).Pr = 840;
    
    drive(3).name = 'AX5101';
    drive(3).Pr = 1000;
    drive(3).price = 9600;
    
    cost = sum([gear.price]) + sum([motor.price]) + sum([drive.price]);
    disp('Total Cost [NOK]:')
    disp(cost)
end