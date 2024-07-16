# Computational-Models-of-SQM

This is the repository of **Computational-Models-of-SQM**. The program is versatile, providing both a Graphical User Interface (GUI) and a Command Line Interface (CUI) to suit different user preferences.

## Structure

The computational models of SQM (SQMs model) have the following directories:

- `GUI`: This directory contains programs for Windows and Mac that can be run stand-alone, as well as source code to run using MATLAB.
- `CUI`: This directory contains the source code to be executed using MATLAB. These programs are divided into those using the Gammatone filterbank and those using the Gammachirp filterbank. Within each directory, there is a `HowToUse` directory that contains instructions on how to use the programs.

## How to Use

After downloading this repository, you just need to add the toolbox to the path of your MATLAB.

## SQMs [1]

- **Loudness**: The computational model was constructed based on ISO 532-2 using a time-domain auditory filterbank.
- **Sharpness**: This model was constructed based on Aures' loudness-dependent sharpness model using GTFB and GCFB.
- **Roughness**: The model was constructed based on Daniel & Weber's roughness calculation model using GTFB and GCFB.
- **Fluctuation strength**: The model was constructed based on the roughness model, with parameters set to match the fluctuation strength.

## References

[1] Isoyama, T., Kidani, S., Unoki, M., "Computational models of sound-quality metrics using method for calculating loudness with gammatone/gammachirp auditory filterbank," Applied Acoustics, v. 218, p. 109914, 2024.
