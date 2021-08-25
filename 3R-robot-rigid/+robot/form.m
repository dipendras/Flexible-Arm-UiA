function [f, J] = form()

    %     ** DH-Table 3R Robot **
    % ---------------------------------
    % theta | d     |  a      | alpha  
    % ---------------------------------
    % q1    | 0     | L1      | 0
    % ---------------------------------
    % q2    | 0     | L2      | 0
    % ---------------------------------
    % q3    | 0     | L3      | 0
    % ---------------------------------
    
    % Forward Kinmatics
    Mb = sym('Mb', [3,1], 'real'); % Mass on COG
    M = sym('M', [3,1], 'real'); % Mass on joints
    L = sym('L', [3,1], 'real');
    q = sym('q', [3,1], 'real');
    
    T1 = robot.DH(q(1), 0, L(1), 0);
    T2 = robot.DH(q(2), 0, L(2), 0);
    T3 = robot.DH(q(3), 0, L(3), 0);
    
    % End effector
    H = T1*T2*T3;
    
    % p = f(q, L1, L2, L3);
    f = simplify(H(1:2,4));
    
    % Analytical Jacobian == Geometrical Jacobian
    J = simplify(jacobian(f, q));
    
    % Energy terms
    rc(:,1) = T1*[-L(1)/2; 0; 0; 1];
    rc(:,2) = T1*T2*[-L(2)/2; 0; 0; 1];
    rc(:,3) = T1*T2*T3*[-L(2)/2; 0; 0; 1];
    
    rj(:,1) = T1*[0; 0; 0; 1];
    rj(:,2) = T1*T2*[0; 0; 0; 1];
    rj(:,3) = T1*T2*T3*[0; 0; 0; 1];
    
    g = [0; -9.81; 0];
    P = 0;
    for i = 1:3
        P = P + Mb(i)*g'*rc(1:3,i);
        P = P + M(i)*g'*rj(1:3,i);
    end
    
    P = simplify(P);
    
    G = jacobian(P, q)';
    
    % Save matlab functions
    matlabFunction(f, 'File', '+robot/f', 'Vars', {q, L});
    matlabFunction(J, 'File', '+robot/J', 'Vars', {q, L});
    matlabFunction(G, 'File', '+robot/G', 'Vars', {q, L, Mb, M});
    
    
end