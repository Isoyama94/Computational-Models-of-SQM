function [QS,q]=GTSharpnessPatameters(N,Setting)
Sample = length(N);
switch Setting.Op
    case 'Ap'% Applied acoustics (stationary)
        QS = 1/439.782;

        x = [0.000728514988970418,-0.0331971821784920,0.529645464982287,-0.227401736888770];
        p1 = x(1);
        p2 = x(2);
        p3 = x(3);
        p4 = x(4);
        q = p1*Setting.ERBNnumber.^3 + p2*Setting.ERBNnumber.^2 + p3*Setting.ERBNnumber + p4;
        a1 = Setting.ERBNnumber.*q;
        a2 = log((4+20)/20)./4;
        w = a1*a2;
        q = ((w'*ones(1,Sample))./(ones(Sample,1)*Setting.ERBNnumber)').*(N./log((20+N)./20));

    case 'INTERNOISE' % InterNoise (stationary)
        QS = 1/448.008311595607;

        x = [0.000728514988970418,-0.0331971821784920,0.529645464982287,-0.227401736888770];
        p1 = x(1);
        p2 = x(2);
        p3 = x(3);
        p4 = x(4);
        q = p1*Setting.ERBNnumber.^3 + p2*Setting.ERBNnumber.^2 + p3*Setting.ERBNnumber + p4;
        a1 = Setting.ERBNnumber.*q;
        a2 = log((4+20)/20)./4;
        w = a1*a2;
        q = ((w'*ones(1,Sample))./(ones(Sample,1)*Setting.ERBNnumber)').*(N./log((20+N)./20));

    case 'N03'% TVL (No Leaky intergrator)
        if 1==strcmp(Setting.SWaight,'DIN')
            if 1==strcmp(Setting.TimeVarying,'ON')
                QS = 1/171.658479098244;
            elseif 1==strcmp(Setting.TimeVarying,'OFF')
                QS = 1/1;
            else
                msg = 'Error: Chose Setting.TimeVarying "ON" or "OFF"';
                error(msg)
            end
            x = [78.3381667864553	-32.6881856479356	59.7037979525354	-44.7934866119376];
        elseif 1==strcmp(Setting.SWaight,'Zwicker')
            if 1==strcmp(Setting.TimeVarying,'ON')
                QS = 1/165.264048772528;
            elseif 1==strcmp(Setting.TimeVarying,'OFF')
                QS = 1/163.604056896427;
            else
                msg = 'Error: Chose Setting.TimeVarying "ON" or "OFF"';
                error(msg)
            end
            x = [71.8770887337942	-33.9623242525890	57.2313352400840	-64.6170365167211];
        else
            error('Setting.SWaight: Chose "DIN" or "Zwicker"')
        end
        p1 = x(1)*10^(-5);
        p2 = x(2)*10^(-3);
        p3 = x(3)*10^(-2);
        p4 = x(4)*10^(-2);
        q = p1*Setting.ERBNnumber.^3 + p2*Setting.ERBNnumber.^2 + p3*Setting.ERBNnumber + p4;
        q = q./q(131); % 1000 Hz -> 1;
        a1 = Setting.ERBNnumber.*q;
        a2 = log((4+20)/20)./4;
        w = a1*a2;
        q = ((w'*ones(1,Sample))./(ones(Sample,1)*Setting.ERBNnumber)').*(N./log((20+N)./20));
end
end