%
%       Gammachirp Filterbank 
%	Version 1.04 	
%       Toshio IRINO
%       14 June 1998   (FIR gammatone version, little mod.)
%
% function [GcOut, Frs, cEst, aEst, PsEst, GtOut] ...
%             = GCFB(fs,Snd, NumCh,FRange,n,b,cCoef,cLim,SwCntl,SwCmplx)
%      INPUT:  fs:     Sampling rate
%              Snd:    Input Sound
%              NumCh:  Number of Channels
%              FRange: Frequency Range. Specification in 3 types:
%                      [fmin fmax] / [fmin fmax fclip] / All channel freqs.
%              n:      GammaChirp n (n==4 only in this version)
%              b:      GammaChirp b
%              cCoef:  coefficient of c, c= cCoef(1)+cCoef(2)*Ps;
%              cLim:   Limit of coefficient c. 2 value. 
%                      Hard Limit of Estimated c value (diff(cLim) >1)
%                      Soft Limit of Estimated c value (diff(cLim) <1)
%					[-1.4 -1.5]
%              SwCntl: FeedBack ('FB') / FeedForward ('FF') : Calculat
%                      No Control ('NC'): all c is fixed to cCoef(1)
%                      Explicit Control ('EC'):  c <- cCoef(NumCh*LenSnd)
%              SwCmplx: Output 'real' (default) / 'complex'
%        
%      OUTPUT: GcOut:  GammaChirp Filter Output
%              Frs:    Fr vector
%              cEst:   Estimated c
%              aEst:   Estimated a
%              PsEst:  Estimated Ps
%              GtOut:  GammaTone Filter Output
%
% Note: 
%  No ELC filtering in this program. Apply an ELC filter 
%  (e.g. OutMidCrctFilt.m) to signals before fed into GCFB.m.
%
% References: 
%  IRINO, T. and UNOKI, M.:  ATR Technical Report, TR-H-225 (14 July 97)
%  IRINO, T. and UNOKI, M.:  IEEE ICASSP'98 paper, AE4.4 (12-15, May 98)
%
%
function [GcOut, Frs, cEst, aEst, PsEst, GtOut] ...
          = GCFB(fs,Snd,Cam,n,b,cCoef,cLim,SwCntl,SwCmplx)

%%%% Handling Input Parameters %%%%%
if nargin < 2,         help GCFB;           end;    
if nargin < 3,         Cam = [];            end;
if length(Cam)== 0,    Cam = 1.8:0.1:38.9;  end;
if nargin < 4,         n = [];              end;  % Order n
if length(n) == 0,     n = 4;               end;
if nargin < 5,         b = [];              end;  % b = 1.019   cf. 1.68;
if length(b) == 0,     b = 1.019;           end;
if nargin < 6,         cCoef = [];          end;
if length(cCoef)==0,   cCoef=[3.38 -0.107]; end;  % c = cCoef(1) + cCoef(2)*Ps
if nargin < 7,         cLim  = [];          end;
if length(cLim)==0,    cLim  = [-3.5 0];    end;     
if nargin < 8,         SwCntl = [];         end;
if length(SwCntl)==0,  SwCntl = 'FB';       end;
if nargin < 9,         SwCmplx = 'real';    end;

disp('*** Gammachirp Filterbank ***');

NumCh = length(Cam);

%%%%  Initialization %%%%%
GCFBInit 

%%%% Start calculation %%%%%

%%% Gammatone filtering  %%%
SwGT = 0; % FIR GammaTone
%% SwGT = 1; % IIR GammaTone 

%% The output of an IIR filter (MakeERBFiltersB.m) diverges when using
%% combination of high sampling rate (fs >= 24000 Hz) and low center
%% frequency ( fr < ~100 Hz) because of numerical stability problem of 
%% the ARMA model. An FIR gammatone is good to avoid this problem
%% but with slightly slow speed (about 1/3). Another merit of using 
%% the FIR gammatone is that "n" value is not restricted to 4 
%% although "n=4" is still recommended.


Tstart = clock;
if SwGT == 1 %% when IIR gammatone
  if n ~= 4 
    error('n should be 4 in this version because of MakeERBFiltersB.m');
  end
  [bGT, aGT] = MakeERBFiltersB(fs,[],Frs,b); % only for n=4;
  if strcmp(SwCmplx,'complex') == 1
    [bGTi, aGTi] = MakeERBSinFiltersB(fs,[],Frs,b); % only for n=4;
    bGT = bGT + 1i * bGTi;
    aGT = aGT + 1i * aGTi;
  end

  ns = 1:length(Snd);
  for nch=1:NumCh
    GtOut(nch,ns)=filter(bGT(nch,:),aGT(nch,:),Snd);
    if rem(nch,10)==0
      disp(['IIR-GammaTone  ch #' num2str(nch) ...
	    ' / #' num2str(NumCh) '.    elapsed time = ' ...
	    num2str(fix(etime(clock,Tstart)*10)/10) ' (sec)']);
    end
  end

else %% when FIR


  [~, ERBw] = Freq2ERB(Frs);
  [~, ERBw1kHz] = Freq2ERB(1000);
  gt = GammaChirp(1000,fs,n,b,0);       % 1 kHz Gammatone
  [frsp, ~] = freqz(gt,1,1024*4,fs);  % Spectrum
  ampgt1kHz = 1/max(abs(frsp));         % Normalization

  ns = 1:length(Snd);
  for nch=1:NumCh    
    gt = GammaChirp(Frs(nch),fs,n,b,0);   % c==0, i.e., gammatone. 
    if  strcmp(SwCmplx,'complex') == 1
      gt = gt + 1i*GammaChirp(Frs(nch),fs,n,b,0,-pi/2); % sin (90 deg phase)
    end

    amp =  ampgt1kHz*(ERBw(nch)/ERBw1kHz);
    gt  =  amp*gt;
    
    GtOut(nch,ns)=fftfilt(gt,Snd);       % fast fft based filtering 
    if rem(nch,10)==0
      disp(['FIR-GammaTone  ch #' num2str(nch) ...
	    ' / #' num2str(NumCh) '.    elapsed time = ' ...
	    num2str(fix(etime(clock,Tstart)*10)/10) ' (sec)']);
    end
  end
  
end

if SwCntl == 'NC' & length(find(cEstTmp ~= 0)) == 0
  disp(['No Asymmetric Compensation Filtering in GCFB.m']); 
  disp(['GcOut==GtOut. cEst==0.']);
  GcOut = GtOut;
  return;
end; 
       

%%% Calculation Asymmetric Compensation Filterbank for every time slice %%%
%% Please note that the asymmetric compensation filter 
%% (MakeAsymCmpFilters.m) produces unreliable (diverged) values 
%% when fs = 48000 Hz and fr < 100 Hz. It is no problem when fs = 24000 Hz.

nDisp = 10*fs/1000; % display every 10 ms

Tstart = clock;
for nsmpl=1:LenSnd
   if rem(nsmpl,nDisp)==0, 
     StrDisp = ['GammaChirp: Time = ' ...
	      num2str(round(nsmpl/fs*1000)) ' (ms)'...
           ' / ' num2str(round(LenSnd/fs*1000)) ...
	   ' (ms).     elapsed time = ' ...
           num2str(round(etime(clock,Tstart)*10)/10) ' (sec)'];
     if SwCntl == 'NC' |  SwCntl == 'EC',  disp([SwCntl '-' StrDisp]);  end;
   end;

   if SwCntl == 'EC'; cEstTmp = cCoef(:,nsmpl); end;
   if SwCntl == 'FF'
      [cEstTmp, aEstTmp, PsEstTmp] = ...
   GCFBCntl(GtOut(:,nsmpl), Frs,cCoef,cLim,aLI,bLI,WinPsEst,CoefPsEst,Cmprs); 
     if rem(nsmpl,nDisp)==0, disp(['FF-' StrDisp]); end; % for check
   end

   % Filtering Asym. Comp. Filter
   [bAC aAC] = MakeAsymCmpFilters(fs,Frs,n,b,cEstTmp);   
   Nb = max(nsmpl-NumCoefbz+1,1) : nsmpl;
   Na = max(nsmpl-NumCoefap+1,1) : nsmpl-1;
   bAC = aEstTmp*ones(1,NumCoefbz).*bAC;  % OK
   if strcmp(SwCmplx,'complex') == 1
     TmpReGcOut = IIRfilter(bAC,aAC,real(GtOut(:,Nb)),real(GcOut(:,Na))); 
     TmpImGcOut = IIRfilter(bAC,aAC,imag(GtOut(:,Nb)),imag(GcOut(:,Na)));
     GcOut(:,nsmpl) = TmpReGcOut + 1i * TmpImGcOut;
   else
     GcOut(:,nsmpl) = IIRfilter(bAC,aAC,GtOut(:,Nb),GcOut(:,Na)); 
   end
   
   PsEst(:,nsmpl) = PsEstTmp; 	% keep Ps record 
   cEst(:,nsmpl)  = cEstTmp; 	% keep c record
   aEst(:,nsmpl)  = aEstTmp; 	% keep a record

   if SwCntl == 'FB'
     [cEstTmp, aEstTmp, PsEstTmp] = ...
   GCFBCntl(GcOut(:,nsmpl),Frs,cCoef,cLim,aLI,bLI,WinPsEst,CoefPsEst,Cmprs); 
     if rem(nsmpl,nDisp)==0, disp(['FB-' StrDisp ]); end; % for check
   end

end

