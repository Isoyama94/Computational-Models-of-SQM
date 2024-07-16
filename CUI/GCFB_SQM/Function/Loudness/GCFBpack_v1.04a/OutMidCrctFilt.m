%
%	Produce compensation filter to simulate outer/middle ear
%	IRINO Toshio
%	29 Aug. 1996 (check on 14 May  1997 )
%
%	It is a linear phase filter for the ELC/MAF/MAP correction.
%	see OutMidCrct.m 
%
%	function [FIRCoef] = OutMidCrctFilt(StrCrct,SR);
%	INPUT	StrCrct: String for Correction ELC/MAF/MAP
%		SR: 	 Sampling Rate
%		SwPlot:  SwPlot
%	OUTPUT  FIRCoef: FIR filter coefficients 
%
function [FIRCoef] = OutMidCrctFilt(StrCrct,SR,SwPlot);

if nargin < 2, help OutMidCrctFilt; end;
if nargin < 3, SwPlot = 1; end;

if length(StrCrct)~=3, 
	error('Specifiy correction in 3 characters: ELC / MAF / MAP.'); 
end;
if ~(strcmp(upper(StrCrct(1:3)), 'ELC') | ...
	 strcmp(upper(StrCrct(1:3)),'MAF') ...
	| strcmp(upper(StrCrct(1:3)),'MAP')),
	error('Specifiy correction: ELC / MAF / MAP.'); 
end;

Nfft = 1024;
Nint = Nfft;
% Nint = 0; % No spline interpolation:  NG no convergence at remez
[crctPwr freq] = OutMidCrct(StrCrct,Nint,SR,0);
crct = sqrt(crctPwr);
FIRCoef = remez(300/16000*SR,freq/SR*2,crct);
% FIRCoef = remez(50/16000*SR,freq/SR*2,crct); NG 

if 1,
	[frsp freq2] = freqz(FIRCoef,1,Nfft,SR);
  if SwPlot
	subplot(2,1,1)
	plot(FIRCoef);
	subplot(2,1,2)
	plot(freq2,abs(frsp),freq,crct) 
	%	plot(freq2,20*log10(abs(frsp)),freq,20*log10(crct))
  end;
	if Nfft == Nint, 
	  ELCError = sum((abs(frsp) - crct).^2)/sum(crct.^2);
	  ELCErrordB = 20*log10(ELCError);
	  if ELCErrordB > -30,
	    disp(['Warning: Error in ELC correction = ' ...
		    num2str(ELCErrordB) ' dB > -30 dB'])
	  end;
	end;
end;

return;
