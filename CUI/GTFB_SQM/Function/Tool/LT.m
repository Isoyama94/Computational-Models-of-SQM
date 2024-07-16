function [phon] = LT(sone)
load 'sone2Phon.mat' xv;
phon = interp1(xv(1,:),xv(2,:),sone,'pchip');
    
% Values higher than 120 phon are not defined in 532-2, but we still want to produce coherent output.
% The pchip extrapolation does not increase monotonically, so use linear extrapolation instead.
phon(sone>xv(1,end)) = interp1(xv(1,:),xv(2,:),sone(sone>xv(1,end)),'linear','extrap');
        
% Sones lower than .001 should give 0 instead of a negative value.
phon(phon<0) = 0;