%	IIRGammaToneFB : IIR GammaTone FilterBank
%
%	Purpose: This function returns outputs of the filterbank based on the
%			IIRmode.
%	function [gtOutRe,centreFrs]=
%           IIRGammaToneFB(xt,NumCh,FRange,fs,bCoeff,swIIRmode,swOPmode)
%	INPUTS	: xt	: Input data
%		  NumCh : Channel number of FB
%		  FRange: Center frequency range [lower higher]
%		  fs    : Sampling frequency
%		  bCoeff: Coefficients of b
%		  swIIRmode: Mode of IIR type of gammatone filter
%		  	"Normal": 4thCascade One Zero Two Pole GammaTone [1]
%		  	"Slaney": 5Zero-9Pole GammaTone [1]
%		  	"APGT": All Pole GammaTone [2]
%		  	"OZGT": One Zelo GammaTone
%		  swOPmode: Operation (show) mode ('ON' or 'OFF')
%	OUTPUTS : gtOut	: Output vector (real part)
%		  centreFrs: Center frequencies of the FB
%
%	Author:  Masashi Unoki
%	Created: 29 Nov. 2000
%	Updated:  7 Dec. 2000
%   Modified: 12 Apr. 2024 Isoyama Takuto - Parallel
%	Copyright (c) 2000, CNBH Univ. of Cambridge / Akagi-Lab. JAIST
%
%	References:
%	[1]	Malcolm Slaney, "An Efficient Implementation of the
%		Patterson-Holdsworth Auditory Filter Bank,"
%		Apple Computer Tech. Rep. #35.
%	[2] R.F. Lyon, "All-pole medels fo auditory filtering,"
%		in "Diversity in Auditory Mechanics," Lewis et al. Eds.,
%		pp. 205-211, World Scientific 1997.
%
function [gtOut,centreFrs]=IIRGammaToneFB(xt,fs,Cam,bCoeff,swIIRmode,swOPmode,Setting)

if nargin < 1, help IIRGammaToneFB; return; end;
if nargin < 2, fs=20000; end;
if nargin < 3, Cam=1.8:0.1:38.9; end;
if nargin < 4, bCoeff=1.019; end;
if nargin < 5, swIIRmode='Normal'; end;
if nargin < 6, swOPmode='OFF'; end;

% ERBrange=Freq2ERB(FRange);
% if NumCh == 1
%    ERBrates=ERBrange;
% else
% %   ERBdiff=diff(ERBrange)/(NumCh-1);
% %   ERBrates=(ERBrange(1):ERBdiff:ERBrange(2));
%    ERBdiff=diff(ERBrange)/(NumCh);				% for DSAM
%    ERBrates=(ERBrange(1):ERBdiff:ERBrange(2));	% for DSAM
%    ERBrates=ERBrates(1:NumCh);
% end
NumCh = length(Cam);
ERBrates = Cam;
cf=ERB2Freq(ERBrates(:));
xtLen=length(xt);
NumCascade=4;
gtOut=zeros(NumCh,xtLen);

T=1/fs;
[tmp,ERBw] = Freq2ERB(cf);
B=2*pi*bCoeff*ERBw;

ap1=zeros(NumCh,3); ap2=zeros(NumCh,3);
ap3=zeros(NumCh,3); ap4=zeros(NumCh,3);
bz1=zeros(NumCh,2); bz2=zeros(NumCh,2);
bz3=zeros(NumCh,2); bz4=zeros(NumCh,2);

switch swIIRmode

    case {'Normal'}  % Normal mode

        %%% Cascade #1
        bz1(:,1)=T;
        bz1(:,2)=-T*exp(-B*T).*(cos(2.0*pi*cf*T)-(1+sqrt(2))*sin(2.0*pi*cf*T));
        ap1(:,1)=1.0;
        ap1(:,2)=-2.0*exp(-B*T).*cos(2.0*pi*cf*T);
        ap1(:,3)=exp(-2.0*B*T);

        %%% Cascade #2
        bz2(:,1)=T;
        bz2(:,2)=-T*exp(-B*T).*(cos(2.0*pi*cf*T)+(1+sqrt(2))*sin(2.0*pi*cf*T));
        ap2(:,1)=1.0;
        ap2(:,2)=-2.0*exp(-B*T).*cos(2.0*pi*cf*T);
        ap2(:,3)=exp(-2.0*B*T);

        %%% Cascade #3
        bz3(:,1)=T;
        bz3(:,2)=-T*exp(-B*T).*(cos(2.0*pi*cf*T)-(1-sqrt(2))*sin(2.0*pi*cf*T));
        ap3(:,1)=1.0;
        ap3(:,2)=-2.0*exp(-B*T).*cos(2.0*pi*cf*T);
        ap3(:,3)=exp(-2.0*B*T);

        %%% Cascade #4
        bz4(:,1)=T;
        bz4(:,2)=-T*exp(-B*T).*(cos(2.0*pi*cf*T)+(1-sqrt(2))*sin(2.0*pi*cf*T));
        ap4(:,1)=1.0;
        ap4(:,2)=-2.0*exp(-B*T).*cos(2.0*pi*cf*T);
        ap4(:,3)=exp(-2.0*B*T);

    case {'OZGT'}  % One Zero All Pole GammaTone

        bz1(:,1)=1.0;
        bz1(:,2)=-exp(-B*T).*cos(2.0*pi*cf*T);
        ap1(:,1)=1.0;
        ap1(:,2)=-2.0*exp(-B*T).*cos(2.0*pi*cf*T);
        ap1(:,3)=exp(-2.0*B*T);
        bz2=bz1;
        bz3=bz1;
        bz4=bz1;
        ap2=ap1;
        ap3=ap1;
        ap4=ap1;

    case {'APGT'}  % All Pole GammaTone

        bz1(:,1)=1.0;
        bz1(:,2)=0.0;
        ap1(:,1)=1.0;
        ap1(:,2)=-2.0*exp(-B*T).*cos(2.0*pi*cf*T);
        ap1(:,3)=exp(-2.0*B*T);
        bz2=bz1;
        bz3=bz1;
        bz4=bz1;
        ap2=ap1;
        ap3=ap1;
        ap4=ap1;

    case {'Slaney'}  % Slaney's implimentation

        %%%%%%%%%% Original: M. Slaney (begin) %%%%%%%%%%

        forward = zeros(NumCh,5);
        feedback= zeros(NumCh,9);

        gain = abs( (-2*exp(j*4*cf*pi*T)*T + 2*exp(-(B*T) + j*2*pi*cf*T).*T.* ...
            (cos(2*pi*cf*T) - sqrt(3 - 2^(3/2))* sin(2*pi*cf*T))) .* ... % Hb1
            (-2*exp(j*4*cf*pi*T)*T + 2*exp(-(B*T) + j*2*cf*pi*T).*T.* ...
            (cos(2*cf*pi*T) + sqrt(3 - 2^(3/2))* sin(2*cf*pi*T))) .* ... % Hb2
            (-2*exp(j*4*cf*pi*T)*T + 2*exp(-(B*T) + j*2*cf*pi*T).*T.* ...
            (cos(2*cf*pi*T) - sqrt(3 + 2^(3/2))* sin(2*cf*pi*T))) .* ... % Hb3
            (-2*exp(j*4*cf*pi*T)*T + 2*exp(-(B*T) + j*2*cf*pi*T).*T.* ...
            (cos(2*cf*pi*T) + sqrt(3 + 2^(3/2))* sin(2*cf*pi*T))) ./ ... % Hb4
            (-2./exp(2*B*T) - 2*exp(j*4*cf*pi*T) + ...
            2*(1 + exp(j*4*cf*pi*T))./exp(B*T)).^4 ); % Han
        % gain = abs( Hb1 * Hb2 * Hb3 * Hb4 / Han^4 )

        forward(:,1) = T^4 ./ gain;
        forward(:,2) = -4*T^4*cos(2*cf*pi*T)./exp(B*T)./gain;
        forward(:,3) = 6*T^4*cos(4*cf*pi*T)./exp(2*B*T)./gain;
        forward(:,4) = -4*T^4*cos(6*cf*pi*T)./exp(3*B*T)./gain;
        forward(:,5) = T^4*cos(8*cf*pi*T)./exp(4*B*T)./gain;
        feedback(:,1) = 1.0;
        feedback(:,2) = -8*cos(2*cf*pi*T)./exp(B*T);
        feedback(:,3) = 4*(4 + 3*cos(4*cf*pi*T))./exp(2*B*T);
        feedback(:,4) = -8*(6*cos(2*cf*pi*T) + cos(6*cf*pi*T))./exp(3*B*T);
        feedback(:,5) = 2*(18 + 16*cos(4*cf*pi*T) + cos(8*cf*pi*T))./exp(4*B*T);
        feedback(:,6) = -8*(6*cos(2*cf*pi*T) + cos(6*cf*pi*T))./exp(5*B*T);
        feedback(:,7) = 4*(4 + 3*cos(4*cf*pi*T))./exp(6*B*T);
        feedback(:,8) = -8*cos(2*cf*pi*T)./exp(7*B*T);
        feedback(:,9) = exp(-8*B*T);
        %%%%%%%%%% Original: M. Slaney (end) %%%%%%%%%%

    otherwise

        error('swIIRmode should be "Normal", "Slaney", "OZGT", or "APGT".');

end

switch swIIRmode

    case {'Normal', 'OZGT', 'APGT'}

        gain1=abs( (bz1(:,1).*exp(j*4*pi*cf*T)+bz1(:,2).*exp(j*2*pi*cf*T)) ./ ...
            (ap1(:,1).*exp(j*4*pi*cf*T)+ap1(:,2).*exp(j*2*pi*cf*T)+ap1(:,3)) );
        gain2=abs( (bz2(:,1).*exp(j*4*pi*cf*T)+bz2(:,2).*exp(j*2*pi*cf*T)) ./ ...
            (ap2(:,1).*exp(j*4*pi*cf*T)+ap2(:,2).*exp(j*2*pi*cf*T)+ap2(:,3)) );
        gain3=abs( (bz3(:,1).*exp(j*4*pi*cf*T)+bz3(:,2).*exp(j*2*pi*cf*T)) ./ ...
            (ap3(:,1).*exp(j*4*pi*cf*T)+ap3(:,2).*exp(j*2*pi*cf*T)+ap3(:,3)) );
        gain4=abs( (bz4(:,1).*exp(j*4*pi*cf*T)+bz4(:,2).*exp(j*2*pi*cf*T)) ./ ...
            (ap4(:,1).*exp(j*4*pi*cf*T)+ap4(:,2).*exp(j*2*pi*cf*T)+ap4(:,3)) );

        %%% Normalization

        bz1=bz1./(gain1*ones(1,2));
        bz2=bz2./(gain2*ones(1,2));
        bz3=bz3./(gain3*ones(1,2));
        bz4=bz4./(gain4*ones(1,2));

        gtOutTmp1=zeros(1,xtLen);
        gtOutTmp2=zeros(1,xtLen);
        gtOutTmp3=zeros(1,xtLen);

        switch Setting.Parallel
            case 'ON'

                parfor nch=1:NumCh
                    if strcmp(swOPmode,'ON')==1
                        disp(['Channel number =' num2str(nch) ' / ' num2str(NumCh)]);
                    end
                    gtOutTmp1=filter(bz1(nch,:),ap1(nch,:),xt);
                    gtOutTmp2=filter(bz2(nch,:),ap2(nch,:),gtOutTmp1);
                    gtOutTmp3=filter(bz3(nch,:),ap3(nch,:),gtOutTmp2);
                    gtOut(nch,:)=filter(bz4(nch,:),ap4(nch,:),gtOutTmp3);
                end
            case 'OFF'
                for nch=1:NumCh
                    if strcmp(swOPmode,'ON')==1
                        disp(['Channel number =' num2str(nch) ' / ' num2str(NumCh)]);
                    end
                    gtOutTmp1=filter(bz1(nch,:),ap1(nch,:),xt);
                    gtOutTmp2=filter(bz2(nch,:),ap2(nch,:),gtOutTmp1);
                    gtOutTmp3=filter(bz3(nch,:),ap3(nch,:),gtOutTmp2);
                    gtOut(nch,:)=filter(bz4(nch,:),ap4(nch,:),gtOutTmp3);
                end
        end

    case {'Slaney'}
        switch Setting.Parallel
            case 'ON'

                parfor nch=1:NumCh
                    if strcmp(swOPmode,'ON')==1
                        disp(['Channel number =' num2str(nch) ' / ' num2str(NumCh)]);
                    end
                    gtOut(nch,:)=filter(forward(nch,:),feedback(nch,:),xt);
                end
            case 'OFF'
                for nch=1:NumCh
                    if strcmp(swOPmode,'ON')==1
                        disp(['Channel number =' num2str(nch) ' / ' num2str(NumCh)]);
                    end
                    gtOut(nch,:)=filter(forward(nch,:),feedback(nch,:),xt);
                end
        end

    otherwise

        error('swIIRmode should be "Normal", "Slaney", "OZGT", or "APGT".');

end

centreFrs=cf;

return;



