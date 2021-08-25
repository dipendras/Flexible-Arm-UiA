function plotMotorCurves(q_t, q_tt, tau, t0, gear, motor)
    
    [~, i] = min(abs(q_t.Time - t0));
    t = q_t.Time(i:end,:) - t0;

    % Joint side speed, acceleration and torque
    q_t = abs(q_t.Data(i:end,:)');
    q_tt = abs(q_tt.Data(i:end,:)');
    tau = abs(tau.Data(i:end,:)');
     
    % Joint Power
    P = q_t.*tau;
    
    % RPM
    rpm = q_t/(2*pi)*60;
    
    for i = 1:size(q_t, 1)
        figure('Name', ['Motor ', num2str(i)]);
        
        %% GEAR SIDE
        subplot(1, 3, 1)
        
        % Torque curves ref. output flange
        plot(rpm(i,:), tau(i,:), 'k'), hold on
        
        % Nominal torque curves ref. output flange
        x = [0, gear(i).wn, gear(i).wn]/(2*pi)*60/gear(i).i;
        y = [gear(i).Tn*ones(1,2), 0];
        plot(x, y, 'b')
        
        % Max torque curves ref. output flange
        x = [0, gear(i).wm, gear(i).wm]/(2*pi)*60/gear(i).i;
        y = [gear(i).Tm*ones(1,2), 0];
        plot(x, y, 'r')
       
        xlabel('\omega - [RPM]');
        ylabel('Torque - [Nm]');
        legend('T(t)', 'T_n(t)', 'T_m(t)')
        title('Output Flange')
        
        
        %% MOTOR SIDE
        subplot(1, 3, 2)
        plot(gear(i).i*rpm(i,:), tau(i,:)/gear(i).i, 'k'), hold on
        plot(gear(i).i*rpm(i,:), tau(i,:)/gear(i).i + q_tt(i,:)*gear(i).i*motor(i).Jm, 'r--')
        
        x = [0, motor(i).wr, motor(i).wm]/(2*pi)*60;
        y = [motor(i).Ts, motor(i).Tr, 0];
        plot(x, y, 'b')
        x = [x(1), x(2), x(2)];
        y = [y(2), y(2), 0];
        plot(x, y, 'k--')
        
        xlabel('\omega_m - [RPM]');
        ylabel('Torque - [Nm]');
        legend('T_m(t)', 'T_m(t) + J_m\alpha(t)')
        title('Motor Axis')
        
        
        R(i) = sum(tau(i,:) > gear(i).Tn)/length(tau(i,:))*100;

        subplot(1,3,3)
        plot(t, P(i,:)/motor(i).Pr*100, 'b'), hold on
        ylabel('Power Utilization [%]');
        legend('P(t)')
        title('Power')
        
        
    end

    disp('-------------------------------------');
    for i = 1:size(q_t, 1)
        disp(['Joint ', num2str(i)]);
        disp(['|MAX| Speed: ', num2str(max(rpm(i,:))), ' RPM']);
        disp(['|MAX| Torque: ', num2str(max(tau(i,:))), ' Nm']);
        disp(['|MAX| Power: ', num2str(max(P(i,:))), ' Watt']);
        disp(['Duty Cycle: ', num2str(R(i)), ' %']);
        disp('-------------------------------------');
    end
        

end
% 
% function y = rms(u)
%     N = length(u);
%     
%     y = 1/N*sqrt(u.^2);
% end
