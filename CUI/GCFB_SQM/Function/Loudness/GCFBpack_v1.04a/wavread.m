function [s Fs,Nbit] = wavread( filename );
[s Fs] = audioread( filename );
Nbit = 16;