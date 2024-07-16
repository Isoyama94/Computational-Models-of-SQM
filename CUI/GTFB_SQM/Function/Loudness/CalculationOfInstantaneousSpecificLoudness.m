% This function is Calculation of instantaneous specific loudness
%       [Slp,y] = CalculationOfInstantaneousSpecificLoudness(Slp,QL,TQ_power,G_power,A_data,alph,Setting)
% 
%   Input:  Slp           Excitation
%           QL            Constant for loudness
%           TQ_power
%           G_power
%           A_data
%           alph
%           Setting
%   Output: Np            Instantaneous specific loudness
%
%   Created: 5 Jun. 2023
%   Copyright: (c) 2023 Unoki-Lab. JAIST
%
function [Np] = CalculationOfInstantaneousSpecificLoudness(Slp,Fs0,QL,TQ_power,G_power,A_data,alph,Setting)
[K,n] = size(Slp);
t = (0:n-1)/Fs0;
Np = Slp;
for N_number = 1:K
    I1 = find(Slp(N_number,:) < TQ_power(1,N_number));
    I2 = find(10^10 >= Slp(N_number,:) & Slp(N_number,:) > TQ_power(1,N_number));
    I3 = find(10^10 < Slp(N_number,:));
    Np(N_number,I1) = QL.*((2.*Slp(N_number,I1))./(Slp(N_number,I1)+TQ_power(1,N_number))).^1.5.*((G_power(1,N_number).*(Slp(N_number,I1))+A_data(1,N_number)).^alph(1,N_number)-A_data(1,N_number).^alph(1,N_number));
    Np(N_number,I2) = QL.*((G_power(1,N_number).*(Slp(N_number,I2))+A_data(1,N_number)).^alph(1,N_number)-A_data(1,N_number).^alph(1,N_number));
    Np(N_number,I3) = QL.*((Slp(N_number,I3))./(0.0036)).^0.2;
end
if 1 == strcmp(Setting.Figshow,'ON')
    if 1 == strcmp(Setting.TimeVarying,'OFF')
        figure('Name','Mean specific londess','NumberTitle','off')
        plot(Setting.ERBNnumber,mean(Np(:,100:end),2),'LineWidth',3)
        ylabel('Specific Loudness [sone/ERB]')
        xlabel('ERB_N-number [Cam]')
        set(gca,'FontSize',20,'FontName','Times')
        hold on
    elseif 1 == strcmp(Setting.TimeVarying,'ON')
        figure('Name','Instantaneous Specific londess','NumberTitle','off')
        imagesc(t,Setting.ERBNnumber,Np)
        ylabel('ERB_N-numer [Cam]')
        xlabel('Time [sec]')
        axis xy
        set(gca,'FontSize',20,'FontName','Times')
    end
end
end