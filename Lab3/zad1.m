SH = load('Shannon_Hurley.mat');
MO = load('Music_Ozerov.mat');
mixedData = mixData(SH.S, 10);
AMUSE(SH.S, 3, 1);
disp(SH.S(:,1:10));