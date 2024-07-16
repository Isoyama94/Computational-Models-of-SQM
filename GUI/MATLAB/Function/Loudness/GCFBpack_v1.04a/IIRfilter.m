function [SigOut] = IIRfilter(b,a,SigIn,SigPrev)
%
%	IIRfilter	: IIRfiltering in time slice
%	Masashi UNOKI
%	12 June 1997
%	Toshio IRINO
%	25 Dec. 1997
%
%	function [SigOut] = IIRfilter(bz,ap,SigIn,SigPrev)
%	INPUT : b	: MA coefficents   (zero)
%		a	: AR coefficents   (pole)
%		SigIn	: Input signal     (NumCh*Lb,     matrix)
%		SigPrev : Previous signal  (NumCh*(La-1), matrix)
%	OUTPUT: SigOut	: Filtered signal  (NumCh*1,      vector)
%
%       Usage : see testIIRfilter.m
%
%       Basics (as shown by "help filter"):
%       a(1)*y(n) = b(1)*x(n) + b(2)*x(n-1) + ... + b(nb+1)*x(n-nb)
%                             - a(2)*y(n-1) - ... - a(na+1)*y(n-na)
%			      
%
if nargin < 4, help IIRfilter; return; end

[NumCh,Lb] = size(b);
[~,La] = size(a);
[~,Lx] = size(SigIn);
[~,Ly] = size(SigPrev);

x = SigIn;
y = SigPrev;
if Lx < Lb,    x = [zeros(NumCh,Lb-Lx),   x]; end
if Ly < La-1,  y = [zeros(NumCh,La-Ly-1), y]; end

forward  = b.*fliplr(x);
feedback = a(:,2:La).*fliplr(y);
if Lb > 1, forward  = sum(forward')' ;  end
if La > 2, feedback = sum(feedback')';  end

SigOut = (forward - feedback)./a(:,1);

