SH = load('Shannon_Hurley.mat');
MO = load('Music_Ozerov.mat');

AnalysisData = SH.S;

[mixedData, mixingSource] = mixData(AnalysisData, 10);
[A, S] = AMUSE(mixedData, 3, 1);

SIRScoreData = CalcSIR(AnalysisData', S');
SIRScoreMixing = CalcSIR(mixingSource, A);

disp('SIR dla danych: ');
disp(SIRScoreData);
disp('SIR dla macierzy mieszającej: ');
disp(SIRScoreMixing);