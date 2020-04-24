% Parametr K-krotnej walidacji przyżowej walidacji
K=5;

pictures = load_att_pictures('att_faces', 40);

% Wektor kolejnych rozmiarów tensora obrazów
I = size(pictures);
pirctures_indexes = 1:I(3);

% 5-fold-cv
cv_partitions = cvpartition(pirctures_indexes, 'KFold', K);

loaded_image = pictures(:, :, 1);
figure
imshow(uint8(loaded_image));
