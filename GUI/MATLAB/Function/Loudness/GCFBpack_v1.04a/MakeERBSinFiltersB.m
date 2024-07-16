function [forward,feedback,cf,ERBwidth]=MakeERBSinFilters(fs,numChannels,cf,b)
%
% GammaSinTone Filter  (Sin phase)
% Usage is the same as MakeERBFiltersB.m
%
% Toshio Irino 
% 18 Nov 97
%
%

T=1/fs;
% Change the following parameters if you wish to use a different
% ERB scale.
% EarQ = 9.26449;               %  Glasberg and Moore Parameters
EarQ = 1/0.107939;              %  Glasberg and Moore Parameters
minBW = 24.7;
order = 1;

if nargin < 4, b = 1.019; end; % default by Patterson and Holdworth 
if length(cf) == 1, 
  lowFreq = cf;  
  if length(numChannels) == 0, help MakeERBSinFiltersB
                               disp('Error: Define numChannels.');
  end;
else 
  lowFreq = []; 
end;

% All of the following expressions are derived in Apple TR #35, "An
% Efficient Implementation of the Patterson-Holdsworth Cochlear
% Filter Bank."
if length(lowFreq) > 0 % If lowFreq is defined.
  cf = -(EarQ*minBW)+exp((1:numChannels)'*(-log(fs/2 + EarQ*minBW) + ...
                         log(lowFreq + EarQ*minBW))/numChannels) ...
                          *(fs/2 + EarQ*minBW);
else
  cf = cf(:);
end
  
ERBwidth = ((cf/EarQ).^order + minBW^order).^(1/order);
B=b*2*pi*ERBwidth;

gain = abs(-(exp((B + 2*1i*cf*pi)*T)*T.*  ...
    (-2*exp(4*1i*cf*pi*T)*T + ...
    (1+1i)*(1 - 1i*exp(4*1i*cf*pi*T))*T./exp(B*T)).* ...
    (-2*exp(4*1i*cf*pi*T)*T + ...
    (1+1i)*(-1i + exp(4*1i*cf*pi*T))*T./exp(B*T)).*  ...
    (-2*exp(4*1i*cf*pi*T)*T +  ...
    (1 + exp(4*1i*cf*pi*T))*T./exp(B*T)).*sin(2*cf*pi*T))./ ...
    (2*cf.*(-1 + exp(B*T) - exp(2*(B + 2*1i*cf*pi)*T) + ...
    exp((B + 4*1i*cf*pi)*T)).*  ...
    (-2./exp(2*B*T) - 2*exp(4*1i*cf*pi*T) +  ...
    2*(1 + exp(4*1i*cf*pi*T))./exp(B*T)).^3* pi));

feedback=zeros(length(cf),9);
forward=zeros(length(cf),5);
forward(:,1) = zeros(length(cf),1);
forward(:,2) = T^4*sin(2*cf*pi*T)./(2*cf.*exp(B*T)*pi)./gain;
forward(:,3) = -3*T^4*sin(4*cf*pi*T)./(4*cf.*exp(2*B*T)*pi)./gain;
forward(:,4) = T^4*sin(6*cf*pi*T)./(2*cf.*exp(3*B*T)*pi)./gain;
forward(:,5) = -(T^4*sin(8*cf*pi*T))./(8*cf.*exp(4*B*T)*pi)./gain;

feedback(:,1) = ones(length(cf),1);
feedback(:,2) = -8*cos(2*cf*pi*T)./exp(B*T);
feedback(:,3) = 4*(4 + 3*cos(4*cf*pi*T))./exp(2*B*T);
feedback(:,4) = -8*(6*cos(2*cf*pi*T) + cos(6*cf*pi*T))./exp(3*B*T);
feedback(:,5) = 2*(18 + 16*cos(4*cf*pi*T) + cos(8*cf*pi*T))./exp(4*B*T);
feedback(:,6) = -8*(6*cos(2*cf*pi*T) + cos(6*cf*pi*T))./exp(5*B*T);
feedback(:,7) = 4*(4 + 3*cos(4*cf*pi*T))./exp(6*B*T);
feedback(:,8) = -8*cos(2*cf*pi*T)./exp(7*B*T);
feedback(:,9) = exp(-8*B*T);


return


%%%% Original Fortran form %%%%%

%gain = abs(-(E**((B + (0,2)*cf*Pi)*T)*T*
% (-2*E**((0,4)*cf*Pi*T)*T + (1,1)*(1 - (0,1)*E**((0,4)*cf*Pi*T))*T/E**(B*T))*
% (-2*E**((0,4)*cf*Pi*T)*T + (1,1)*((0,-1) + E**((0,4)*cf*Pi*T))*T/E**(B*T))*
% (-2*E**((0,4)*cf*Pi*T)*T + (1 + E**((0,4)*cf*Pi*T))*T/E**(B*T))*Sin(2*cf*Pi*T))/
% (2*cf*(-1 + E**(B*T) - E**(2*(B + (0,2)*cf*Pi)*T) + E**((B + (0,4)*cf*Pi)*T))*
% (-2/E**(2*B*T) - 2*E**((0,4)*cf*Pi*T) + 2*(1 + E**((0,4)*cf*Pi*T))/E**(B*T))**3* Pi));
% forward(:,1) = 0;
% forward(:,2) = T**4*Sin(2*cf*Pi*T)/(2*cf*E**(B*T)*Pi);
% forward(:,3) = -3*T**4*Sin(4*cf*Pi*T)/(4*cf*E**(2*B*T)*Pi);
% forward(:,4) = T**4*Sin(6*cf*Pi*T)/(2*cf*E**(3*B*T)*Pi);
% forward(:,5) = -(T**4*Sin(8*cf*Pi*T))/(8*cf*E**(4*B*T)*Pi);
% feedback(:,1) = 1;
% feedback(:,2) = -8*Cos(2*cf*Pi*T)/E**(B*T);
% feedback(:,3) = 4*(4 + 3*Cos(4*cf*Pi*T))/E**(2*B*T);
% feedback(:,4) = -8*(6*Cos(2*cf*Pi*T) + Cos(6*cf*Pi*T))/E**(3*B*T);
% feedback(:,5) = 2*(18 + 16*Cos(4*cf*Pi*T) + Cos(8*cf*Pi*T))/E**(4*B*T);
% feedback(:,6) = -8*(6*Cos(2*cf*Pi*T) + Cos(6*cf*Pi*T))/E**(5*B*T);
% feedback(:,7) = 4*(4 + 3*Cos(4*cf*Pi*T))/E**(6*B*T);
% feedback(:,8) = -8*Cos(2*cf*Pi*T)/E**(7*B*T);
% feedback(:,9) = E**(-8*B*T);




