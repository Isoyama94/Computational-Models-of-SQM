% This function is making band-pass noise
% [Y] = MakeNoise(Fs,T,Fc,BandWidth,StepSize,Seed)
% 
% Input:    Fs          : Sampling frequency [Hz] (Default: 44100)
%           T           : Dulation [ms] (Default: 1000)
%           Fc          : Center frequency [Hz] (Default: 1000)
%           BandWidth   : Band width [Hz] (Default: 1000)
%           StepSize    : Frequency bin [Hz] (Default: 1)
%           Seed        : Randam seed (Default: 1)
% Output    Y           : Band-pass noise
% 
% Author:  Takuto ISOYAMA
% Created: 9 Apr. 2024 
% Copyright: (c) 20024 unoki-Lab. JAIST
%
function [Y] = MakeNoise(Fs,T,Fc,BandWidth,StepSize,Seed)
if nargin<1, Fs=44100; end
if nargin<2, T=1000; end
if nargin<3, Fc=1000; end 
if nargin<4, BandWidth=1000; end
if nargin<5, StepSize=1; end 
if nargin<6, Seed=1; end

rng(Seed,'philox')
low = Fc-round(BandWidth/2);
hight = Fc+round(BandWidth/2);
t = 0:1/Fs:T/1000-1/Fs;
output = zeros(1,length(t));
for f = low:StepSize:hight
    output = sin(2*pi*f*t+(rand)*2*pi)+output;
end
Y = output/max(abs(output));
end