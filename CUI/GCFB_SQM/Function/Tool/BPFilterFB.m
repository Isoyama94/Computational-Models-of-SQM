%
%	Bandpass filter
%
%	y=BPFilter(x,f0,bandWidth,fs,opMode)
%
%	INPUTS: x	: Input data
%		f0	: Center frequency of the BPfilter 
%		bandWidth: bandWidth of the BPfilter
%		fs	: Sampling frequency
%               opMode  : option of Mode ('normal' or 'show') of characteristics
%	OUTPUT:	y	: Output data
%
%	Author:  Masashi UNOKI
%	Created: 29 June 1995
%	Updated:  1 Dec. 2000
%
function [y]=BPFilterFB(x,f0,bandWidth,fs,opMode)

if nargin<1, help BPFilterFB, return; end;
if nargin<4, fs=20000; end;
if nargin<5, opMode='normal'; end;

N=5;                             % Filter-Order     
Delta_f=bandWidth/2;             % Band-Width(3dB)    [Hz]
delta_f=Delta_f;               % (30dB) Eliminated width  [Hz]

Wp=2*[f0-Delta_f f0+Delta_f]/fs;
Ws=2*[f0-Delta_f-delta_f f0+Delta_f+delta_f]/fs;  
Rp=3;
Rs=30;
[n,w_B]=buttord(Wp,Ws,Rp,Rs);
[bz,ap]=butter(N,w_B);
y=filtfilt(bz,ap,x);



switch opMode
 case {'show'}
   [h,w]=freqz(bz,ap,128);
   f=w*2*fs/pi;
   figure(100)
   subplot(2,1,1)
   semilogy(f,20*log10(abs(h)));
   hold on;
   subplot(2,1,2)
   plot(f,angle(h)*180/pi);
   return;
 case {'normal'}
   return;
 otherwise
   error('opMode should be "normal" or "show".');
end


