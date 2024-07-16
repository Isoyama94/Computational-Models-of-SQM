%
%     Coefficients of Leaky Inegrator
%     Toshio Irino
%     8 July 97
%
%      function [b, a] = MakeLI(fs,Tcnst);
%      INPUT : fs       : Sampling Rate
%              Tcnst 	: Time Constant (vector) (ms)
%      OUTPUT: a        : AR coef 
%              b        : MA coef
%
function [b, a] = MakeLI(fs,Tcnst);

if nargin < 2, help MakeLI; end;

LenT = length(Tcnst);
a = [ones(LenT,1) -exp(-1./(fs*Tcnst(:)/1000))];
b = sum(a')';





