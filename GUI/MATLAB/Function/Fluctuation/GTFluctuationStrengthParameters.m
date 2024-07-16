function [QF,Fs,Lf,Hf,pm,pk] = GTFluctuationStrengthParameters(Setting)
switch Setting.Op
    case 'Ap'
        Fs = 200;
        Lf = 5;
        Hf = 2;
        pm = 0.65138;
        pk = 2;
        QF = 0.0299052005143695;
    case 'INTERNOISE'
        Fs = 200;
        Lf = 5;
        Hf = 2;
        pm = 0.65138;
        pk = 2;
        QF = 0.0299052005143695;
end
end