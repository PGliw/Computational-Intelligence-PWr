SH = load('Shannon_Hurley.mat');
MO = load('Music_Ozerov.mat');
[mixedData, mixingSource] = mixData(SH.S, 3);
[A, S] = AMUSE(mixedData, 3, 1);