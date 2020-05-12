SH = load('Shannon_Hurley.mat');
MO = load('Music_Ozerov.mat');

AnalysisData = SH.S;

[mixedData, mixingSource] = mixData(AnalysisData, 3);

[independentCompFICA, mixingMatFICA, ~] = fastica(mixedData);
[mixingMatAMUSE, independentCompAMUSE] = AMUSE(mixedData, 3, 1);

SIRDataAMUSE = CalcSIR(AnalysisData', independentCompAMUSE');
SIRMixingAMUSE = CalcSIR(mixingSource, mixingMatAMUSE);

SIRDataFastICA = CalcSIR(AnalysisData', independentCompFICA');
SIRMixingFastICA = CalcSIR(mixingSource, mixingMatFICA);

disp('SIR for AMUSE algorithm:');
disp('SIR for data');
disp(SIRDataAMUSE);
disp('SIR for mixing matrix');
disp(SIRMixingAMUSE);

disp('SIR for Fast ICA algorithm:');
disp('SIR for data');
disp(SIRDataFastICA);
disp('SIR for mixing matrix');
disp(SIRMixingFastICA);

