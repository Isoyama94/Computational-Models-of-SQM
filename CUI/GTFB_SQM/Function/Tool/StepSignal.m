% This function is making step signal
% [Y,t] = StepSignal(Fs,T,A,StartTime)
% 
% Input:    Fs              : Sampling frequency [Hz] (Default: 44100)
%           T               : Dulation [ms] (Default: 1000)
%           A               : Amplitude (Default: 1)
%           StartTime       : Start time [ms] (Default: 0)
% Output    Y               : Step signal
%           t               : Time [sec]
% 
% Author:  Takuto ISOYAMA
% Created: 9 Apr. 2024 
% Copyright: (c) 20024 unoki-Lab. JAIST
%
function [Y,t] = StepSignal(Fs,T,A,StartTime)
if nargin<1, Fs=44100; end
if nargin<2, T=1000; end
if nargin<3, A=1; end 
if nargin<4, StartTime=0; end

t = 0:1/Fs:T/1000;
tsize = T*Fs/1000;
stsize = StartTime*Fs/1000;

Y = ones(tsize+1,1)*A;
Y(1:stsize,1) = 0.0;
end