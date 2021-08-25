function [gear, motor, drive] = v4()

    % Alu profiles - https://produktkatalog.norskstaal.no/
    % J   Varenr   NOBBnr     Beskrivelse           Quality   Yield
    % 1 - 313418 - 55447696 - 50 X 50 X 4.0 X 6 M - 6082-T6 - 250 MPa
    % 2 - 313416 - 55447696 - 40 X 40 X 2.5 X 6 M - 6082-T6 - 250 Mpa
    % 3 - 313395 - 55447696 - 30 X 30 X 2.0 X 6 M - 6060-T6 - 140 MPa
    
    %% Joint 1 - OK
    gear(1).name = 'AG2400-+TP110S-MF2-61';
    gear(1).price = 36500;
    gear(1).i = 61;
    gear(1).Tn = 1100;
    gear(1).Tm = 1400;
    gear(1).wn = 3200*2*pi/60;
    gear(1).wm = 4500*2*pi/60;
    gear(1).m = 34;

    motor(1).name = 'AM8061-1H21';
    motor(1).price = 14000;
    motor(1).Ts = 17.1;
    motor(1).Tr = 16.1;
    motor(1).Tm = 37.1;
    motor(1).m = 13.5;
    motor(1).wr = 1400*2*pi/60;
    motor(1).wm = 1.2*motor(1).wr;
    motor(1).Jm = 13.4*(0.01)^2;
    motor(1).Pr = 2360;
    
    drive(1).name = 'AX5106';
    drive(1).Pr = 4200;
    drive(1).price = 10200;
    

    %% Joint 2 - OK
    gear(2).name = 'AG2400-+TP025S-MF2-50';
    gear(2).price = 21700;
    gear(2).i = 50;
    gear(2).Tn = 220;
    gear(2).Tm = 380;
    gear(2).wn = 3100*2*pi/60;
    gear(2).wm = 6000*2*pi/60;
    gear(2).m = 6.7;
    
    motor(2).name = 'AM8052-1F21';
    motor(2).price = 6500;
    motor(2).Ts = 8.2;
    motor(2).Tr = 7.5;
    motor(2).Tm = 35.0;
    motor(2).m = 7.4;
    motor(2).wr = 2000*2*pi/60;
    motor(2).wm = 1.2*motor(2).wr;
    motor(2).Jm = 4.711*(0.01)^2;
    motor(2).Pr = 1570;
    
    drive(2).name = 'AX5103';
    drive(2).Pr = 2100;
    drive(2).price = 9800;

    %% Joint 3 - OK
    gear(3).name = 'AG2400-+TP004S-MF2-35';
    gear(3).price = 17000;
    gear(3).i = 35;
    gear(3).Tn = 40;
    gear(3).Tm = 55;
    gear(3).wn = 4000*2*pi/60;
    gear(3).wm = 6000*2*pi/60;
    gear(3).m = 1.5;

    motor(3).name = 'AM8031-1C21';
    motor(3).price = 5300;
    motor(3).Ts = 1.37;
    motor(3).Tr = 1.34;
    motor(3).Tm = 6.10;
    motor(3).m = 2.2;
    motor(3).wr = 3000*2*pi/60;
    motor(3).wm = 1.2*motor(3).wr;
    motor(3).Jm = 0.541*(0.01)^2;
    motor(3).Pr = 420;
    
    drive(3).name = 'AX5101';
    drive(3).Pr = 1000;
    drive(3).price = 9600;
    
    % Cost MacGregor
    cost = sum([gear.price]) + sum([motor.price]) + sum([drive.price]);
    disp('Total Cost [NOK]:')
    disp(cost)
    
    
end