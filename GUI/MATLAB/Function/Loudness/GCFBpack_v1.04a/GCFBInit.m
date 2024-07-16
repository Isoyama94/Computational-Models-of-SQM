%
%       Gammachirp Filterbank Initialization
%       Toshio IRINO
%       14 Aug. 1997
%       9 Dec. 1997 (remove globals)
%       22 Dec. 1997 (change W etc.)
%       5 Feb. 1998  (small change at W)
%       4 Mar. 1998  (Fixed CoefPsEst, Version 0.90)
%       2 Jun  1998  
%
%

%%%%%%
global LIOut  LIOutPrev % for preserving results (as static double in c)

%%% Initial settings for Asymmetric Compensation Filterbank %%%

CoefPsEst=6.5;	 		% constant 4 Mar. 98
% TcnstLI=30; 			% Time constant of LeakyIntegrator [msec]
TcnstLI=100; 			% Tc LI (2 Jun 98)
% Cmprs = 0.3; 			% Compression when estimating aEst
Cmprs = 1;                      % Compression 1 == no compression

%%% Frequency Setting %%%%

% ERBrange = Freq2ERB(FRange);
% ERBdiff  = (ERBrange(2) - ERBrange(1))/(NumCh-1);
%   
% if length(FRange) == 2  % when specifying Frequency Range [minFreq,  maxFreq]
%   ERBrates = (ERBrange(1):ERBdiff:ERBrange(2))'; % equal erbs
%   Frs = ERB2Freq(ERBrates(:));
% 
% elseif length(FRange) == 3, % Specify clipping Freq. [minFreq, maxFreq, clipFreq]
%   FrClip = FRange(3);
%   ERBclip = Freq2ERB(FrClip);
%   ERBrates = [ fliplr( ERBclip:(-ERBdiff):ERBrange(1)-(ERBdiff/2.1) ), ...
% 	       (ERBclip+ERBdiff):ERBdiff:ERBrange(2)+(ERBdiff/2.1)];
%        
%  if length(ERBrates) ~= NumCh,
%     error(['Error : length(ERBrates) (' int2str(length(ERBrates)) ...
% 	    ') ~= NumCh (' int2str(NumCh) ')']);
%     ERBrates = ERBrates(1:NumCh);
%   end;
%   Frs = ERB2Freq(ERBrates(:));
%   [val kfr] = min(abs(Frs-FrClip));
%   disp(['Clip Fr=' int2str(FrClip) ' (Hz) @ ch#' int2str(kfr) ...
%   '.   Error= ' num2str(Frs(kfr)-FrClip) ' (Hz). -- Compensated to Zero.']);
%   Frs(kfr) = FrClip; 		% to simplify further calculation
% 
% else
%   Frs   = FRange(:);            % Specified in advance
%   NumCh = length(Frs);
% 
% end;

Frs = ERB2Freq(Cam(:));
ERBrates = Cam;
disp(['Num. Channel = ' int2str(NumCh) ',   [minFreq, maxFreq] = ['  ...
	      int2str(Frs(1)) ', '  int2str(Frs(NumCh)) '] (Hz)']);

%%% Window Setting %%%
% if SwCntl == 'FF',    WinPsEst = MakeGCWindow(Frs,n,b,cWin); end; 
% do not use any more

WinPsEst = MakeERBWin(ERBrates,3);  % 3 ERB Hamming Window Matrix

%%% Leaky Integrator Setting %%%
[bLI, aLI] = MakeLI(fs,TcnstLI*ones(size(Frs(:))));

%%% Initial settings for Asymmetric Compensation Filterbank %%%

LenSnd   = length(Snd);
cEstTmp  = zeros(NumCh,1); 
if SwCntl == 'NC',  cEstTmp = cCoef(1)*ones(NumCh,1); end
PsEstTmp = zeros(NumCh,1); 
aEstTmp  = ones(NumCh,1); 
GtOut    = zeros(NumCh,LenSnd);
GcOut    = zeros(NumCh,LenSnd);
LIOut    = zeros(NumCh,1);
cEst     = zeros(NumCh,LenSnd);
aEst     = zeros(NumCh,LenSnd); 
PsEst    = zeros(NumCh,LenSnd);

[bz2, ap2] = MakeAsymCmpFilters(fs,Frs(1),n,b,0); % dummy to determine NumCoef
[~, NumCoefap] = size(ap2);
[dummy, NumCoefbz] = size(bz2);


