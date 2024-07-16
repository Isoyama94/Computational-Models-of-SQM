function [h] = TMFilter(fs,Th,Tt)
% Th = 20/1000;
% Tt = 200/1000;
t = 0:1/fs:(Th+Tt)-1/fs;
t = t-Th;
Thsample = Th*fs;
h(1,1:Thsample) = exp(6.9*t(1,1:Thsample)/Th);
h(1,Thsample+1:length(t)) = exp(-6.9*t(1,Thsample+1:length(t))/Tt);
h = h/1404.67063897179;
end