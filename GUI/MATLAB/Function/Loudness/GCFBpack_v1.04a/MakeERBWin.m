%
%
%	MakeERBWin : Make ERB-Window Matrix 
%	Toshio IRINO
%	9 Feb. 98
%
%
%	function [WinMtrx] = MakeERBWin(ERBrates,NumERB);
%	INPUT : ERBrates    : ERB rate vector for GT/GC filters
%		WinSizeERB  : Window size in ERBs  ex. 3ERB
%		SwWindow    : Window selection,  'ham' or 'han'
%	OUTPUT: WinMtrx	    : Window Matrix
%
%
%
function [WinMtrx] = MakeERBWin(ERBrates,WinSizeERB,SwWindow)

if nargin < 1, help MakeERBWin; return; end
if nargin < 2, WinSizeERB = 3; end
if nargin < 3, SwWindow = 'ham'; end

NumCh = length(ERBrates);
ERBdiff = mean(diff(ERBrates));

nee = ceil(WinSizeERB/ERBdiff);
Lw = nee + 1 - rem(nee,2);      % making odd number.

if strcmp(lower(SwWindow(1:3)),'han')
  Win = hanning(Lw); StrWin = 'Hanning';
else
  Win = hamming(Lw); StrWin = 'Hamming';
end
disp(['MakeERBWin: Making ' int2str(WinSizeERB) '-ERB ' ...
		 StrWin ' Window Matrix']);

Win = Win/sum(Win);

WinMtrx = zeros(NumCh+Lw,NumCh);

Nall = 1:NumCh;
for Nch = Nall
  nn = Nch:(Nch+Lw-1);
  WinMtrx(nn,Nch)=Win;
end

WinMtrx = WinMtrx(fix(Lw/2)+Nall,Nall);  

