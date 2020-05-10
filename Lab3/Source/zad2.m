SH = load('Shannon_Hurley.mat');
MO = load('Music_Ozerov.mat');
[mixedData, mixingSource] = mixData(MO.S, 3);
[independentCompFICA, mixingMatFICA, sepMat] = fastica(mixedData);
[independentCompAMUSE, mixingMatAMUSE] = AMUSE(SH.S, 3, 1);
disp(mixingSource);
disp(mixingMatFICA);
disp(independentCompAMUSE);