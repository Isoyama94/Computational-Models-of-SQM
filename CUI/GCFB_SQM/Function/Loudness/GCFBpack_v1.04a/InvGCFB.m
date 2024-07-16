%
%
%       Synthesis procedure for the Gammachirp Filterbank 
%       Toshio IRINO
%       5 June 1998
%
% function [SynSnd, RcvGtOut, SynGtOut ] 
%                  = InvGCFB(fs,n,b,Frs,cEst,aEst,GcOut)
%      INPUT:  fs:     Sampling rate
%              n:      GammaChirp n (n==4 only)
%              b:      GammaChirp b
%              Frs:    Fr vector
%              cEst:   Estimated c
%              aEst:   Estimated a
%              GcOut:  GammaChirp Filter Output
%
%      OUTPUT: SynSnd: Synthesic Sound
%              RcvGtOut: Recovered GammaTone Output
%              SynGtOut: Output of Synthesis Gammatone filter 
%
% References: 
%  IRINO, T. and UNOKI, M.:  ATR Technical Report, TR-H-225 (14 July 97)
%  IRINO, T. and UNOKI, M.:  IEEE ICASSP'98 paper (12-15, May 98)
%
function [SynSnd, RcvGtOut, SynGtOut ]  = InvGCFB(fs,n,b,Frs,cEst,aEst,GcOut)

%%%% Handling Input Parameters %%%%%
if nargin < 2, help InvGCFB; end;   
if nargin < 3, n = [];    end;
if length(n) == 0, n = 4; end; 		% Order n
if nargin < 4, b = []; end;          
if length(b) == 0, b = 1.019; end; 	% b

if isreal(GcOut) ~= 1, 
  disp('GcOut should be real. Setting GcOut to real(GcOut).');
  GcOut = real(GcOut);
end;

[NumCh LenSnd] = size(GcOut);

%%% Compensation of aEst %%%
kk = find(aEst == 0);
if length(kk) > 0
  aEst(kk) = ones(size(kk)); % to avoid 1/0 == NaN
  disp('Avoiding aEst is zeros');
end;
GcOut = GcOut./aEst; 

%%% Inverse AC-filtering %%%

if length( find(cEst ~= 0) ) == 0,  % Skip Inverse AC-filter if cEst is zeros.
  RcvGtOut = GcOut;
  
else
  
%%%% Initialization %%%%%
[bz2 ap2] = MakeAsymCmpFilters(fs,Frs(1),n,b,0); % dummy to determine NumCoef
[dummy NumCoefap] = size(ap2);
[dummy NumCoefbz] = size(bz2);

%%% Calculation Inverse Asymmetric Compensation for every time slice %%%
RcvGtOut = zeros(NumCh,LenSnd); % Recovered GtOut from GcOut

nDisp = 10*fs/1000; % display every 10 ms

Tstart = clock;
for nsmpl=1:LenSnd
  if rem(nsmpl,nDisp)==0, 
     str = ['Inverse Compensation: Time = ' num2str(nsmpl/fs*1000) ' (ms)'...
           ' / ' num2str(LenSnd/fs*1000) ' (ms)     elapsed time = ' ...
           num2str(fix(etime(clock,Tstart)*10)/10) ' (sec)'];
       disp(str);
   end;
   % Filtering Asym. Comp. Filter
   [bAC aAC] = MakeAsymCmpFilters(fs,Frs,n,b,cEst(:,nsmpl)); 
                          % Producing the same coefficents as used in analysis
   Na = max(nsmpl-NumCoefbz+1,1) : nsmpl;
   Nb = max(nsmpl-NumCoefap+1,1) : nsmpl-1;
   RcvGtOut(:,nsmpl) = IIRfilter(aAC,bAC,GcOut(:,Na),RcvGtOut(:,Nb));
 end

end; % find(cEst == 0)


%%% Time-reverse  %%%
TrGtOut = fliplr(RcvGtOut);
SynGtOut = zeros(size(TrGtOut));

%%% Gammatone filtering  %%%
Weight = ones(1,NumCh); 		% Uniform : default

SwGT = 0; % FIR GammaTone
%% SwGT = 1; % IIR GammaTone

if  SwGT == 1,

  if n ~= 4, 
    error('n should be 4 in this version because of MakeERBFiltersB.m');
  end;
  [bGT, aGT] = MakeERBFiltersB(fs,[],Frs,b); % only for n=4;

  for nch=1:NumCh
    SynGtOut(nch,:) = Weight(nch) ...
	* filter(bGT(nch,:),aGT(nch,:),TrGtOut(nch,:));
    if rem(nch,10)==0
      disp(['Time-Reversal IIR-GammaTone  ch #' num2str(nch) ' / #' ...
	    num2str(NumCh) ' : finished' ]);
    end;
  end

else % FIR
  
    [dummy ERBw] = Freq2ERB(Frs);
    [dummy ERBw1kHz] = Freq2ERB(1000);
    gt = GammaChirp(1000,fs,n,b,0);       % 1 kHz Gammatone
    [frsp freq] = freqz(gt,1,1024*4,fs);  % Spectrum
    ampgt1kHz = 1/max(abs(frsp));         % Normalization
	    
    for nch=1:NumCh    
      amp =  ampgt1kHz*(ERBw(nch)/ERBw1kHz);
      gt  =  amp * GammaChirp(Frs(nch),fs,n,b,0);   % c==0, i.e., gammatone. 

      SynGtOut(nch,:) = Weight(nch) * fftfilt(gt,TrGtOut(nch,:));
      if rem(nch,10)==0
	disp(['Time-Reversal FIR-GammaTone  ch #' num2str(nch) ' / #' ...
	      num2str(NumCh) ' : finished' ]);
      end;
    end;

end;	    

	    
%%% Sum & Time-reverse  again %%%
SynGtOut = fliplr(SynGtOut);
SynSnd = sum(SynGtOut);

%%% Normalization when n = 4, b = 1.019 - 1.7,  Error < 0.1 dB %%%
density = mean(diff(Freq2ERB(Frs)));
amp = 10^( (10.11 + 20*log10( density / b ) )/20); % ad hoc 
SynSnd = amp*SynSnd;

