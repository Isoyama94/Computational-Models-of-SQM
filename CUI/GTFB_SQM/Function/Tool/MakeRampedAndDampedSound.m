% This function is making ramped sound
% [Sramped,Sdamped,t] = MakeRampedAndDampedSound(Fs,T,CF,Fmod,Nmod,m)
% 
% Input:    Fs              : Sampling frequency [Hz] (Default: 44100)
%           T               : Dulation [ms] (Default: 1000)
%           Fc              : Center frequency [Hz] (Default: 1000)
%           Fmod            : Modulation frequency [Hz] (Default: 4)
%           Nmod            : 
%           ModulationIndex : Modulation index 0 ~ 1 (Default: 1) 
% Output    Sramped         : Ramped signal
%           Sdamped         : Damped signal
%           t               : time [sec]
% 
% Author:  Takuto ISOYAMA
% Created: 9 Apr. 2024 
% Copyright: (c) 20024 unoki-Lab. JAIST
%
function [Sramped,Sdamped,t] = MakeRampedAndDampedSound(Fs,T,Fc,Fmod,Nmod,ModulationIndex)
if nargin<1, Fs=44100; end
if nargin<2, T=1000; end
if nargin<3, Fc=1000; end 
if nargin<4, Fmod=4; end
if nargin<5, Nmod=2; end 
if nargin<6, ModulationIndex=1; end

t = 0:1/Fs:T/1000-1/Fs;
for v = 1:Nmod
    Eramped(v,:) = -1/v*sin(2*pi*Fmod*v*t);
end
Eramped = sum(Eramped);

Sramped = -(1+ModulationIndex*(Eramped/max(abs(Eramped)))).*sin(2*pi*Fc*t);
Sdamped = flip(Sramped,2);
end