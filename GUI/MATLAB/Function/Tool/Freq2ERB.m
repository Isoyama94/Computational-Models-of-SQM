%
%	Freq2ERB: Convert Frequencies to ERBrates and ERBws
%
%	function [ERBrates,ERBwidthes]=Freq2ERB(Frs)
%	INPUT:  Frs	  : Characteristic frequencies
%	OUTPUTS:ERBrates  : ERB rates
%		ERBwidthes: ERB widthes
%
%	Author:   Masashi UNOKI
%	Created:  8 Apr. 1998
%	Updated: 18 Nov. 2000
%	Copyright (c) 2000, CNBH Univ. of Cambridge / Akagi-Lab. JAIST 
%
function [ERBrates,ERBwidthes]=Freq2ERB(Frs)
if nargin < 1,  help Freq2ERB; return; end;

cfmin = 50;
cfmax = 15000;
if (min(Frs) < cfmin | max(Frs) > cfmax)
% disp(['Warning : Min or max of frequency exceeds the proper ERB range:']);
% disp(['          ' int2str(cfmin) '(Hz) <= Fc <=  ' int2str(cfmax) '(Hz).']);
end;

Fkhz=Frs/1000;
ERBrates=21.4.*log10(4.37*Fkhz+1);
ERBwidthes=24.7.*(4.37*Fkhz+1);

return;
