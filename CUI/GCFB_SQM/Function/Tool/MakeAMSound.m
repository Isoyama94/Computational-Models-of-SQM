% This function is making am-sound
% [Y] = MakeAMSound(Fs,T,Fc,Fmod,ModulationIndex,FigShow)
% 
% Input:    Fs              : Sampling frequency [Hz] (Default: 44100)
%           T               : Dulation [ms] (Default: 1000)
%           Fc              : Center frequency [Hz] (Default: 1000)
%           Fmod            : Modulation frequency [Hz] (Default: 4)
%           ModulationIndex : Modulation index 0 ~ 1 (Default: 1)
%           FigShow         : Show figure 'ON' or 'OFF' (Default: 'OFF')
% Output    Y               : AM sound
% 
% Author:  Takuto ISOYAMA
% Created: 9 Apr. 2024 
% Copyright: (c) 20024 unoki-Lab. JAIST
%
function [Y] = MakeAMSound(Fs,T,Fc,Fmod,ModulationIndex,FigShow)
if nargin<1, Fs=44100; end
if nargin<2, T=1000; end
if nargin<3, Fc=1000; end 
if nargin<4, Fmod=4; end
if nargin<5, ModulationIndex=1; end 
if nargin<6, FigShow='OFF'; end

t = 0:1/Fs:T/1000-1/Fs;
Y = -sin(2*pi*Fc.*t)-ModulationIndex/2*sin(2*pi*(Fmod-Fc).*t)+ModulationIndex/2*sin(2*pi*(Fmod+Fc).*t);

switch FigShow
    case 'ON'
        figure(100)
        plot(t,Y);
        figure(101)
        plot(0:1/10:Fs-1/10,20*log10(abs(fft(Y,Fs*10))));
    case 'OFF'
end
end