function [forward,feedback]=MakeAsymCmpFilters(fs,fr,n,b,c)
%
% computes the filter coefficients for a bank of compensation filters to
% transform the gammatone to the gammachirp.  It requires the gammatone
% filterbank as a preprocessor. A m-file  MakeERBFiltersB.m is recommended 
% since an IIR implementation is better for efficient calculation.
% MakeERBFiltersB.m is a modified version of Malcolm Slaney's MakeERBFilters.m.
%
% gt(t) = t^(n-1) exp(-2*pi*b*ERBw(fr)) cos(2*pi*fr*t);  ---> 
% gc(t) = t^(n-1) exp(-2*pi*b*ERBw(fr)) cos(2*pi*fr*t + c ln t);
%
%  function [forward,feedback]=MakeAsymCmpFilters(fs,fr,n,b,c)
%  INPUT:    fs: Sampling frequency
%            fr: array of the carrier frequencies in the gammatone
%                 (equivalent to "cf")
%            n : scalar of order t^(n-1) % used only in normalization 
%            b : scalar of a bandwidth coefficient 
%            c : array or scalar of asymmetric parameters 
%                (When abs(c) > 3.5, the characteristics is not good enough.)
%  OUTPUT:   forward : MA coefficients 
%            feedback: AR coefficients
%
%  Toshio Irino 
%  30 Jun 97
% 

c  = c(:);
fr = fr(:);
NumCh = length(fr);
% ERBw = 24.7 + 0.107939*fr;   %  Glasberg and Moore (1990) Parameters 
[~, ERBw] = Freq2ERB(fr);

[coef_r, coef_th, coef_fn] = AsymCmpCoef(c); % default
[~, NumFilt] = size(coef_r);
a1=zeros(NumCh,3); a2=a1; a3=a1; a4=a1; b1=a1; b2=a1; b3=a1; b4=a1; 
if NumFilt > 4, error('NumFilt > 4'); end

for Nfilt = 1:NumFilt
  r  = exp(-coef_r(:,Nfilt)* 2*pi *b .*ERBw /fs); 
  th = coef_th(:,Nfilt) .*c .*b .*ERBw ./fr; 
  fn = fr + coef_fn(:,Nfilt) .*c .*b .*ERBw/n;  % n is necessary only here
  
  %% Second order filter %%
  ap = [ones(size(r)), -2*r.*cos(2*pi*(1+th).*fr/fs),  r.^2];
  bz = [ones(size(r)), -2*r.*cos(2*pi*(1-th).*fr/fs),  r.^2];

  vwr = exp(1i*2*pi*fn/fs);
  vwrs = [ones(size(vwr)), vwr, vwr.^2];
  nrm = abs( sum( (vwrs.*ap)')' ./ sum( (vwrs.*bz)')');
  bz = bz .* (nrm*ones(1,3));

  
  str = ['a' num2str(Nfilt) ' = ap;'];
  eval(str);
  str = ['b' num2str(Nfilt) ' = bz;'];
  eval(str);
end

%% 2 * second order filter %%
a12 = [ a1(:,1).*a2(:,1),  a1(:,1).*a2(:,2) + a1(:,2).*a2(:,1),   ...
	a1(:,1).*a2(:,3) + a1(:,3).*a2(:,1) + a1(:,2).*a2(:,2),   ...
	a1(:,2).*a2(:,3) + a1(:,3).*a2(:,2),  a1(:,3).*a2(:,3)];
a34 = [ a3(:,1).*a4(:,1),  a3(:,1).*a4(:,2) + a3(:,2).*a4(:,1),   ...
	a3(:,1).*a4(:,3) + a3(:,3).*a4(:,1) + a3(:,2).*a4(:,2),   ...
	a3(:,2).*a4(:,3) + a3(:,3).*a4(:,2),  a3(:,3).*a4(:,3)];
b12 = [ b1(:,1).*b2(:,1),  b1(:,1).*b2(:,2) + b1(:,2).*b2(:,1),   ...
	b1(:,1).*b2(:,3) + b1(:,3).*b2(:,1) + b1(:,2).*b2(:,2),   ...
	b1(:,2).*b2(:,3) + b1(:,3).*b2(:,2),  b1(:,3).*b2(:,3)];
b34 = [ b3(:,1).*b4(:,1),  b3(:,1).*b4(:,2) + b3(:,2).*b4(:,1),   ...
	b3(:,1).*b4(:,3) + b3(:,3).*b4(:,1) + b3(:,2).*b4(:,2),   ...
	b3(:,2).*b4(:,3) + b3(:,3).*b4(:,2),  b3(:,3).*b4(:,3)];

%% 4 * second order filter %%
feedback = [a12(:,1).*a34(:,1),  a12(:,1).*a34(:,2) + a12(:,2).*a34(:,1), ...
	    a12(:,1).*a34(:,3) + a12(:,3).*a34(:,1) + a12(:,2).*a34(:,2), ...
	    a12(:,1).*a34(:,4) + a12(:,4).*a34(:,1) + a12(:,2).*a34(:,3)  ...
          + a12(:,3).*a34(:,2),                                           ...
	    a12(:,1).*a34(:,5) + a12(:,5).*a34(:,1) + a12(:,2).*a34(:,4)  ...
	  + a12(:,4).*a34(:,2) + a12(:,3).*a34(:,3),                      ...
	    a12(:,2).*a34(:,5) + a12(:,5).*a34(:,2) + a12(:,3).*a34(:,4)  ...
	  + a12(:,4).*a34(:,3),                                           ...
	    a12(:,3).*a34(:,5) + a12(:,5).*a34(:,3) + a12(:,4).*a34(:,4), ...  
	    a12(:,4).*a34(:,5) + a12(:,5).*a34(:,4),  a12(:,5).*a34(:,5)];

forward =  [b12(:,1).*b34(:,1),  b12(:,1).*b34(:,2) + b12(:,2).*b34(:,1), ...
	    b12(:,1).*b34(:,3) + b12(:,3).*b34(:,1) + b12(:,2).*b34(:,2), ...
	    b12(:,1).*b34(:,4) + b12(:,4).*b34(:,1) + b12(:,2).*b34(:,3)  ...
          + b12(:,3).*b34(:,2),                                           ...
	    b12(:,1).*b34(:,5) + b12(:,5).*b34(:,1) + b12(:,2).*b34(:,4)  ...
	  + b12(:,4).*b34(:,2) + b12(:,3).*b34(:,3),                      ...
	    b12(:,2).*b34(:,5) + b12(:,5).*b34(:,2) + b12(:,3).*b34(:,4)  ...
	  + b12(:,4).*b34(:,3),                                           ...
	    b12(:,3).*b34(:,5) + b12(:,5).*b34(:,3) + b12(:,4).*b34(:,4), ...  
	    b12(:,4).*b34(:,5) + b12(:,5).*b34(:,4),  b12(:,5).*b34(:,5)];    


nc = NumFilt*2+1;
feedback = feedback(:,1:nc);
forward  = forward(:,1:nc);
    
return


