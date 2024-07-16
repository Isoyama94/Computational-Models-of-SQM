%
%	Gammachirp : Theoretical auditory filter 
%	Toshio IRINO
%	7 Apr. 97 (additional comments)
%	20 Aug. 97 (Simplify & Carrier Selection)
%	10 Jun. 98 (SwNorm)
%	26 Nov. 98 (phase = phase + c ln fr/f0)
%
%	gc(t) = t^(n-1) exp(-2 pi b ERB(Frs)) cos(2*pi*Frs*t + c ln t + phase)
%
%	function [GC, LenGC, Fps, InstFreq ] ...
%	       = GammaChirp(Frs,SR,OrderG,CoefERBw,CoefC,Phase,SwCarr,SwNorm);
%	INPUT : Frs	: Asymptotic Frequency ( vector )
%		SR 	: Sampling Frequency
%		OrderG 	: Order of Gamma function t^(OrderG-1)        == n   
%		CoefERBw: Coeficient -> exp(-2*pi*CoefERBw*ERB(f))    == b
%		CoefC	: Coeficient -> exp(j*2*pi*Frs + CoefC*ln(t)) == c
%		Phase	: Start Phase(0 ~ 2*pi)                       
%		SwCarr  : Carrier ('cos', 'sin', 'complex')
%		SwNorm  : Normalization of peak spectrum level ('no', 'peak')
%	OUTPUT: GC 	: GammaChirp                     ( matrix )
%		LenGC 	: Length of GC for each channel  ( vector )
%               Fps     : Peak Frequency                 ( vector )
%		InstFreq: Instanteneous Frequency        ( matrix )
%
%	
function [GC, LenGC, Fps, InstFreq ] ...
    = GammaChirp(Frs,SR,OrderG,CoefERBw,CoefC,Phase,SwCarr,SwNorm)

if nargin < 2,            help GammaChirp; return; end
Frs = Frs(:);
NumCh = length(Frs);
if nargin < 3,            OrderG = [];	               end
if length(OrderG) == 0,   OrderG = 4;                  end % Default GammaTone
if length(OrderG) == 1,   OrderG = OrderG*ones(NumCh,1); end
if nargin < 4,            CoefERBw = [];	       end 
if length(CoefERBw) == 0, CoefERBw = 1.019;            end % Default GammaTone
if length(CoefERBw) == 1, CoefERBw = CoefERBw*ones(NumCh,1); end 
if nargin < 5,            CoefC  = [];                 end
if length(CoefC) == 0,    CoefC  = 0;                  end % Default GammaTone
if length(CoefC) == 1,    CoefC  = CoefC*ones(NumCh,1); end
if nargin < 6,            Phase  = [];                  end
if length(Phase) == 0,    Phase  = 0;                  end
if length(Phase) == 1,    Phase  = Phase*ones(NumCh,1); end
if nargin < 7,            SwCarr = [];                 end
if length(SwCarr) == 0,   SwCarr = 'cos';	       end
if nargin < 8,            SwNorm = [];                 end
if length(SwNorm) == 0,   SwNorm = 'no';	       end


[~, ERBw] = Freq2ERB(Frs);                             % G&M (1990)
LenGC1kHz = (40*max(OrderG)/max(CoefERBw) + 200)*SR/16000;  % 2 Aug 96 
[~, ERBw1kHz] = Freq2ERB(1000);	

if strcmp(SwCarr,'sin'), Phase = Phase - pi/2*ones(1,NumCh); end
%%% Phase compensation
Phase = Phase + CoefC.*log(Frs/1000); % relative phase to 1kHz

LenGC = fix(LenGC1kHz*ERBw1kHz./ERBw);

%%%%%  Production of GammaChirp  %%%%%
GC       = zeros(NumCh,max(LenGC));
if nargout > 2, Fps = Fr2Fpeak(OrderG,CoefERBw,CoefC,Frs); end % Peak Freq.
if nargout > 3, InstFreq = zeros(NumCh,max(LenGC));        end

Amp = ones(NumCh,1);                                  % No normalization
if strcmp(SwNorm,'peak'),  Amp = ERBw./ERBw1kHz; end % Peak spectrum==const. 

for nch = 1:NumCh
  t = (1:LenGC(nch)-1)/SR;

  GammaEnv = t.^(OrderG(nch)-1).*exp(-2*pi*CoefERBw(nch)*ERBw(nch)*t);
  GammaEnv = Amp(nch)*[ 0 GammaEnv/max(GammaEnv)];

  if strcmp(SwCarr,'complex') 
    Carrier = [ 0 exp(1i * (2*pi*Frs(nch)*t + CoefC(nch)*log(t) +Phase(nch)) )];
  else
    Carrier = [ 0 cos(2*pi*Frs(nch)*t + CoefC(nch)*log(t) +Phase(nch))];
  end
  
  GC(nch,1:LenGC(nch)) = GammaEnv.*Carrier;

  if nargout > 3
    InstFreq(nch,1:LenGC(nch)) = [0, [Frs(nch) + CoefC(nch)./(2*pi*t)]];
  end
  
end % nch = ...


return
    
%% ERBw = 0.128*Frs;     % Complete Constant Q only for check.
