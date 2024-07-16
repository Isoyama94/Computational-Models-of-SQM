function [StartPoint, EndPoint] = VADForSQMsGUI(Xt,Threshold)
XtdB = 10*log10(Xt.^2);
XtdB = XtdB-max(XtdB);
I=find(XtdB>=Threshold);
StartPoint = I(1);
EndPoint = I(end);
end