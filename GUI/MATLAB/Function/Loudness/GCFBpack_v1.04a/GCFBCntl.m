%
%       Gammachirp Filterbank Controler Unit
%
%       Toshio IRINO
%       14 Aug. 1997
%       9 Dec. 1997 (remove globals other than LIOut  LIOutPrev)
%
%       function [cEst, aEst, PsEst] = GCFBCntl(FBOut)
%       INPUT  FBOut: Value of Filterbank Output @ one Time Slice 
%              Frs: fr
%              cCoef: Coef of c
%              aLI: Leaky Integrator a
%              bLI: Leaky Integrator b
%              WinPsEst: Window for PsEst
%              CoefPsEst: Propotion for PsEst
%              Cmprs: Compression
%       OUTPUT cEst : Estimated value of c
%              aEst : Estimated value of a
%              PsEst : Estimated value of Ps
%
%
function [cEst, aEst, PsEst] =  ...
   GCFBCntl(FBOut,Frs,cCoef,cLim,aLI,bLI,WinPsEst,CoefPsEst,Cmprs)

global LIOut  LIOutPrev % for preserving results (as static double in c)

%%% Estimation of control parameters
   RectOut = max(real(FBOut),0); % Half wave rectfication ( real part )
%   RectOut = ( max(real(FBOut),0) + max(-real(FBOut),0) )/2;
             % Full wave rectfication ( real part ) for stable estimation
   LIOutPrev = LIOut;
   LIOut = IIRfilter(bLI,aLI,RectOut,LIOutPrev); % Leaky Integrator

if 0  % ONLY for check
   LIOut2    = IIRfilter(bLI,aLI,RectOut,LIOutPrev); % Leaky Integrator
   error1 = mean(sqrt((LIOut-LIOut2).^2));
   if error1 > 1e-15
     error1 
     [ LIOutPrev'; RectOut'; LIOut'; LIOut2']
     error('Error! ')
     max(PsEst)
   end
end   

%%% Ps Estimation
   WinOut = WinPsEst*LIOut; % Weighting
   WinOut = max(WinOut,1.0e-10); % limit minimum value for log10
   PsEst = 20*log10(CoefPsEst*WinOut);

   if max(PsEst) > 120
     error(['Estimated Ps (' num2str(max(PsEst)) ' dB) is too large.']);
   end

%%% Shift in Location 
   % Nshift = 3;  % Similar to Moore's ExPtn no dip
   % Nshift = -3; % similar to FF
   % Nshift = -1; % Not so much difference to Nshift == 0
   Nshift = 0; 				% default: No shift
   if Nshift > 0
      PsEst = [ zeros(Nshift,1); PsEst(1:length(PsEst)-Nshift)]; 
   elseif Nshift < 0
      PsEst = [PsEst((abs(Nshift)+1):length(PsEst));  zeros(abs(Nshift),1)];
   end
   
%%% cEst Calculation 
   if length(cCoef) == 1
     cEst = cCoef(1) * ones(size(PsEst));
   elseif length(cCoef) == 2
     cEst = cCoef(1) + cCoef(2)*PsEst;
   elseif length(cCoef) == 3
     cEst = (cCoef(1) - PsEst).*(cCoef(2) + cCoef(3)*log10(Frs/250)); 
     % See DispGCsFrsp.m
   end

   
%%% Limitation of cEst
   if abs(diff(cLim)) > 1 		%%%% Hard Limit %%%%
     Ncmin = find(cEst < cLim(1)); 	%  when less than cLim(1)
     cEst(Ncmin) = cLim(1)*ones(size(Ncmin));
     Ncmax = find(cEst > cLim(2)); 	%  when exceeding cLim(2)
     cEst(Ncmax) = cLim(2)*ones(size(Ncmax));
   else 	%%%% Soft Limit, e.g., cLim = [-1.5 -1.5]; %%%%
     cEst = cLim(1) + cLim(2)*atan(-cEst + cLim(1));
   end

%%% smooth cEst
  [cEst,~] = smoothdata(cEst,'gaussian',60);
  
%%% aEst
  if Cmprs == 1
    aEst = ones(size(PsEst)); 		% Constant 
  else
%    aEst = 10.^(-PsEst/10 * Cmprs ); 	% 0.5 NG, 0.3 OK
    aEst = 10.^(-PsEst/20 * Cmprs ); 	% a is amplitude 
  end







