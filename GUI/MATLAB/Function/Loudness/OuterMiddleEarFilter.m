% This function is Outer and middle ear filter
%       [y] = OuterMiddleEarFilter(xt,fs0,Setting)
% 
%   Input:  xt              Input signal
%           fs0             Sampling frequency
%           Setting.Field   'Free' or 'Diffuse'
%   Output: y               Corrected signal
%
%   Created: 5 Jun. 2023
%   Copyright: (c) 2023 Unoki-Lab. JAIST
%
function [y] = OuterMiddleEarFilter(xt,fs0,Setting)
out = cat(2,xt,zeros(1,round(0.04205*fs0)));
fir_eq=ff_design(fs0,Setting);
y =filter(fir_eq,1,out);
y = y(1,round(0.04205*fs0)+1:end);

if 1 == strcmp(Setting.Figshow,'ON')
        [h,w]=freqz(fir_eq,1,fs0);
        f=w*fs0/(2*pi);
        figure('Name','Outer-middle ear filter','NumberTitle','off')
        semilogx(f,20*log10(abs(h)),'Linewidth',3);
        ylim([-40 10])
        ylabel('Filter gain [dB]')
        xlabel('Frequency [Hz]')
        set(gca,'FontSize',20,'FontName','Times');
end
end