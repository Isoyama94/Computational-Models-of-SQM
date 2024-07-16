%
%   GTSharpnessModel: Calculation of sharpness from specific loudness
%   Function [St,S] = GTSharpnessModel(Nd,N,Fs0,Setting)
%   Input:   Nd     :   Specific loudness [sone/ERB]
%            N      :   Loudness [sone]
%            Fs0    :   Sampling frequency [Hz]
%            Setting:   Setting.Figshow = 'ON' or 'OFF'
%                       Setting.Op = 'Ap'
%
%   Output:  St:           Time [sec]
%            S:            Sharpness [acum]
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
function [St,S] = GTSharpnessModel(Nd,N,Fs0,Setting)
if nargin<2, help GTSharpnessModel, return; end
if nargin<3, Fs0=44100; end
if nargin<4, Setting.Figshow='OFF'; Setting.Op='Ap'; end

[QS,q] = GTSharpnessPatameters(N,Setting);

St = 0:1/Fs0:length(Nd)/Fs0-1/Fs0;

top = sum((Nd.*q).*(ones(length(St),1)*Setting.ERBNnumber)');
bot = N;
S = QS*(top./bot);
end