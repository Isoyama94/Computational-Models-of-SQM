%
%   GTFluctuationStrengthModel: Calculation of fluctuation strength from specific loudness
%   Function [Ft,F,Fpk,dLf,ik] = GTFluctuationStrengthModel(Npk0,Fs0,Setting)
%   Input:   Npk0:         Specific loudness [sone/ERB]
%            Fs0:          Sampling frequency [Hz]
%            Setting:      Setting.Figshow = 'ON' or 'OFF'
%                          Setting.Op = 'Ap'
%
%   Output:  Ft:           Time [sec]
%            F:            Fluctuation strength [vacil]
%            Fpk:          Specific fluctuation strength [vacil/ERB]
%            dLf:          Instant loudness [dB]
%            ik:           Corralation
%
%   Author:  Takuto ISOYAMA
%   Created: 10 Oct. 2022
%   Modified: 10 Apr. 2024
%
%   Reference [1] T. Isoyama, and S. Kidani, M. Unoki, ``Computational models 
%                 of auditory sensation important for sound quality on basis of 
%                 either gammatone or gammachirp auditory filterbank,''
%                 Applied Acoustics, Vol. 218, 2024. 
%                 DOI: https://doi.org/10.1016/j.apacoust.2024.109914
%   Copyright (c) 2022-2024, Unoki-Lab. JAIST
%
function [Ft,F,Fpk,dLf,ik] = GTFluctuationStrengthModel(Npk0,Fs0,Setting)
if nargin<1, help GTFluctuationStrengthModel, return; end
if nargin<2, Fs0=44100; end
if nargin<3, Setting.Figshow='OFF'; Setting.Op='Ap'; end

%% Initial Setup
Npk0 = abs(Npk0);
[QF,Fs,Lf,Hf,pm,pk] = GTFluctuationStrengthParameters(Setting);

%% Resample 44100 Hz -> 200 Hz
Npk = resample(Npk0,Fs,Fs0,'Dimension',2);
H0 = mean(Npk,2);
Ft = (0:length(Npk)-1)/Fs;

%% Band-Pass Filter
NBPk = BandPassFilterForFluctuationStrength(Npk,Fs,H0,Lf,Hf,Setting);

%% Calculation of Instant loudness
dLf = FluctuationStrengthOfDifferenceBetweenPeakAndDip(Npk,NBPk,Fs,H0,Setting);

%% Cross-correlation
ik = CalculationOfCrossCorrelationForFluctuationStrength(NBPk,Fs,Setting);

%% Calculation of specific fluctuation strength
Fpk = CalculationOfSpecificFluctuationStrength(QF,dLf,ik,pm,pk,Setting);

%% Calculation of fluctuation strength
Fpk(Fpk<=0) = 0;
F = sum(Fpk*0.1,'omitnan');
end