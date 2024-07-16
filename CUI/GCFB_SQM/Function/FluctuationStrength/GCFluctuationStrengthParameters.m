function [QF,Fs,Lf,Hf,pm,pk] = GCFluctuationStrengthParameters(Setting)
switch Setting.Op
    case 'Ap'
        Fs = 200;
        Lf = 5;
        Hf = 2;
        pm = 0.65138;
        pk = 2;
        QF = 1/33.2874377306490;
    case 'INTERNOISE'
        Fs = 200;
        Lf = 5;
        Hf = 2;
        pm = 0.65138;
        pk = 2;
        QF = 0.0299052005143695;
end
end