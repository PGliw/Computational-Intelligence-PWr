% Stałe
J_values = [4, 10, 20, 30];
cp_als_iterations = 30;

% Zdjęcia wczytujemy jako tablicę 3D wraz z ich poprawnymi grupami
[pictures, labels] = load_att_pictures('att_faces', 50);

% Wektor kolejnych rozmiarów tensora obrazów
I = size(pictures);
pictures_indexes = 1:I(3);

% Macierz 3-wymiarowa do przechowywania 1 obrazu wyznaczonego dla kolejnych
% wartości J (rzędu faktoryzacji)
first_recreated_pictures = zeros(I(1), I(2), size(J_values, 2));
        
% zbiór trenujący i jego prawidłowe grupowanie
Y = tensor(pictures); % tensor obserwacji treningowych

% dla PCA trzeba zmienić macierz 3D na 2D
Y_pca = unfold3(pictures, 3); 

figure;
number_of_J_values = size(J_values, 2);
for i=1:number_of_J_values
    J = J_values(i);
    
    % Dekompozycja tensora treningowego wg różnych algorytmów
    U_cp_als = CP_ALS(Y, 2, J, cp_als_iterations, @unfold3); % faktory estymowane CP-APLS
    [U_hosvd, G] = HOSVD(Y, [J J J], @unfold3); % faktory estymowane HOVD
    [U_pca, Z] = PCA(Y_pca, J); % wektory cech estymowane PCA
    
    % odtworzenie obrazów PCA
    Y_est_pca = U_pca * Z';
    pca_rec_im = reshape(Y_est_pca(1, :), [I(1),  I(2)]);
    pca_rec_im = 255 * normalize(pca_rec_im, 'range');
    
    % odtworzenie obrazów CP ALS
    Y_est_cp_als = ktensor(ones(J, 1), U_cp_als);
    cp_als_recreated_images = double(Y_est_cp_als);
    
    % odtworzenie obrazów CP HSV
    Y_est_hosvd = ttensor(G, U_hosvd);
    hosvd_recreated_images = double(Y_est_hosvd);
    
    % wyświetlenie obrazu PCA
    subplot(3, number_of_J_values, i);
    imshow(uint8(pca_rec_im));
    title(['J=' num2str(J)]);
    
    % wyświetlenie obrazu CP ALS
    subplot(3, number_of_J_values, number_of_J_values + i);
    imshow(uint8(cp_als_recreated_images(:, :, 1)));
    title(['J=' num2str(J)]);
    
    % wyświetlenie obrazu HOSVD
    subplot(3, number_of_J_values, 2 * number_of_J_values + i);
    imshow(uint8(hosvd_recreated_images(:, :, 1)));
    title(['J=' num2str(J)]);
      
end
