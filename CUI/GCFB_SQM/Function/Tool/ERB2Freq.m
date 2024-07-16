%
%	ERB2Freq: Convert ERBrates to Frequencies and ERBws
%
%	function [Frs,ERBwidthes]=ERB2Freq(ERBrates)
%
%	INPUT:	ERBrates  : ERB rates
%	OUTPUTS:Frs	  : Characteristic frequencies
%               ERBwidthes: ERB widthes
%
%	Author:  Masashi UNOKI
%	Created:  8 Apr. 1998
%	Updated: 18 Nov. 2000
%	Copyright (c) 2000, CNBH Univ. of Cambridge / Akagi-Lab. JAIST
%
function [Frs,ERBwidthes]=ERB2Freq(ERBrates)
if nargin < 1,  help ERB2Freq; return; end;

Fkhz=(10.^(ERBrates./21.4)-1)./4.37;
ERBwidthes=24.7.*(4.37*Fkhz+1);
Frs=Fkhz*1000;

return
