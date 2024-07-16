% This function is taper process used cos function
% [y] = CosWindow(xt,fs,T)
% 
% Input:    xt              : Input signal
%           Fs              : Sampling frequency [Hz] (Default: 44100)
%           T               : Dulation of window [ms] (Default: 500)
% Output    Y               : Taperd signal
% 
% Author:  Takuto ISOYAMA
% Created: 9 Apr. 2024 
% Copyright: (c) 20024 unoki-Lab. JAIST
%
function [Y] = CosWindow(xt,Fs,T)
if nargin<1, help CosWindow; return; end 
if nargin<2, Fs=44100; end
if nargin<3, T=500; end

[m,n] = size(xt);
xt = reshape(xt,[m*n,1]);

t = 0:1/Fs:T/1000-1/Fs;
fc = 1/(T/1000)/2;
lenx = length(xt);
lenW = length(t)*2;

% cos window
DownWind = 0.5+0.5*cos(2*pi*fc*t);
UpWind = DownWind(end:-1:1);
Window = [UpWind ones(1,lenx-lenW) DownWind];

Y = xt.*Window';
end