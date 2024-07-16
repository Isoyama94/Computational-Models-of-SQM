%
%      How to use GCFB (for GCFBpack)
%      Toshio IRINO
%      26 Mar 98
%
%
clear
% close all

%%%% Stimuli %%%%
fs = 44100;
fr = 2000;
% Amp60dBSPL: Amplitude of 60 dB SPL sinusoid according to the AIM package 
Amp60dBSPL = 200*sqrt(2); 
Tsnd = 100;
LenSnd = Tsnd*fs/1000; 

t = (0:LenSnd-1)/fs;
LenTaper = 100;
TaperWin = [sin(pi/2*(0:LenTaper-1)/LenTaper) ones(1,LenSnd-LenTaper*2) ...
	    sin(pi/2*(0:LenTaper-1)/LenTaper + pi/2)];

%%%% GCFB %%%%

n = 4;
b = 1.019;
Cam = 1.9:0.1:36.9;
LevelList =  [40 50 60];
LevelList =  80 ;

for cnt = 1:length( LevelList);
  Level = LevelList(cnt);
  Amp = Amp60dBSPL*10^((Level-60)/20);
  Snd = [zeros(1,200) Amp*TaperWin.*sin(2*pi*fr*t)];
%   Snd = [Amp*sin(2*pi*fr*t)];
%   ELCfilter = OutMidCrctFilt('ELC',fs,0);
%   Snd = filter(ELCfilter,1,Snd);
  ELCfilter = ff_design(fs,1);
  Snd = filter(ELCfilter,1,Snd);
  
  %an example using default values
%   [GcOut, Frs, cEst, aEst, PsEst, GtOut] ...
%           = GCFB(fs,Snd,NumCh,FRange,n,b,[],[],'FB','complex'); 
  [GcOut, Frs, cEst, aEst, PsEst, GtOut] ...
          = GCFB(fs,Snd,Cam,n,b,[],[],'FF','real');

  %%%% Plotting results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  figure(1)
  subplot(2,1,1)
  [v kfr] = min(abs(fr-Frs));
  tms = (0:length(GcOut(1,:))-1)/fs*1000;
  kfrqs = [10:10:length(Frs)];
  frqs = Frs(kfrqs)'
  GcOut1 = real(GcOut)+(1:length(Frs))'*ones(size(tms)); % real part
  GcEnv  = abs(GcOut) +(1:length(Frs))'*ones(size(tms)); % envelope
  plot(tms,GcOut1(kfrqs,:),tms,GcEnv(kfrqs,:));
  ax= axis;
  axis([0 ceil(max(tms)) ax(3:4)])
  grid on
  
  subplot(2,1,2)
  kfrqs = [5:5:length(Frs)];
  plot(tms,cEst(kfrqs,:))
  grid on
  axis([0 ceil(max(tms)) -4 2])
  drawnow

end; 		


plot(tms,GcOut(kfrqs(1),:)+10,tms,GcOut(kfrqs(2),:),tms,GcOut(kfrqs(3),:)-50)
legend(['fr=' int2str(frqs(1)) 'Hz'],['fr=' int2str(frqs(2)) 'Hz'], ...
   ['fr=' int2str(frqs(3)) 'Hz'])

% 
% plot(tms,cEst(kfrqs(1),:)+3,tms,cEst(kfrqs(2),:),tms,cEst(kfrqs(3),:)-3)
% plot(tms,cEst(kfrqs(1),:),tms,cEst(kfrqs(2),:),tms,cEst(kfrqs(3),:))
% legend(['fr=' int2str(frqs(1)) 'Hz'],['fr=' int2str(frqs(2)) 'Hz'], ...
%    ['fr=' int2str(frqs(3)) 'Hz'])
