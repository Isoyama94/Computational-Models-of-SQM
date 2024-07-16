% This function is Calculation of excitation
%       [Excitation,ExcitationLevel] = CalculationOfExcitation(InputSig,Fs0,E0,CF,Setting)
% 
%   Input:  InputSig            :Input signal
%           fs0                 :Sampling frequency
%           E0                  :Constant
%   Output: Excitation          :Excitation pattern
%           ExcitationLevel     :Excitation Level
%
%   Created: 5 Jun. 2023
%   Copyright: (c) 2023 Unoki-Lab. JAIST
%
function [Excitation,ExcitationLevel] = CalculationOfExcitation(InputSig,Fs0,E0,Setting)
[K,Sample] = size(InputSig);
t = (0:Sample-1)/Fs0;

%% Half-wave rectification
Amp = InputSig;
Amp(Amp<0) = 0;

%% Leaky integral processing
if 1 == strcmp(Setting.TimeVarying,'ON')
    Excitation = Amp;
    Excitation = Excitation.^2/E0;
elseif 1 == strcmp(Setting.TimeVarying,'OFF')
    Excitation = Amp;
    for k=1:K
        Excitation(k,:) = leakyintegrator(Amp(k,:),Fs0).^2/E0;
    end
else
    msg = 'Error: Chose Setting.TimeVarying "ON" or "OFF"';
    error(msg)
end

%% Calculation of Excitaiton level
ExcitationLevel = 10*log10(Excitation);

if 1 == strcmp(Setting.Figshow,'ON')
    if 1 == strcmp(Setting.TimeVarying,'OFF')
        figure('Name','Excitation pattern','NumberTitle','off')
        plot(Setting.ERBNnumber,10*log10(mean(Excitation(:,0.2*Fs0+1:end-0.2*Fs0),2)),'LineWidth',3)
        ylim([0 120])
        xlim([1.8 38.9])
        ylabel('Excitation level [dB]')
        xlabel('ERB_N-numer [Cam]')
        set(gca,'FontSize',20,'FontName','Times')
        hold on
    elseif 1 == strcmp(Setting.TimeVarying,'ON')
        figure('Name','Excitation pattern','NumberTitle','off')
        imagesc(t,Setting.ERBNnumber,Excitation)
        ylabel('ERB_N-number [Cam]')
        xlabel('Time [sec]')
        clim([0 1*10^5])
        axis xy
        set(gca,'FontSize',20,'FontName','Times')
    end
end
end