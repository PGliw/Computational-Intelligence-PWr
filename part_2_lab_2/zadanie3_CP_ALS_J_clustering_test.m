% Stałe
K=5; % Parametr K-krotnej walidacji przyżowej walidacji
J_values = [4, 10, 20, 30];

cp_als_iterations = 30;
images_in_row = 10;

% Zdjęcia wczytujemy jako tablicę 3D wraz z ich poprawnymi grupami
persons_count = 5;
[pictures, labels] = load_att_pictures('att_faces', persons_count * images_in_row);

% Wektor kolejnych rozmiarów tensora obrazów
I = size(pictures);
pictures_indexes = 1:I(3);

% Macierz 3-wymiarowa do przechowywania 1 obrazu wyznaczonego dla kolejnych
% wartości J (rzędu faktoryzacji)
first_recreated_pictures = zeros(I(1), I(2), size(J_values, 2));
        
% zbiór trenujący i jego prawidłowe grupowanie
Y = tensor(pictures); % tensor obserwacji treningowych

figure;
number_of_J_values = size(J_values, 2);

% akumulator wyników klastrowania dla różnych wartości J
clustering_results = zeros(persons_count * images_in_row, number_of_J_values);

% pomiar poprawności klastrowania dla każdego J
acc_measure_coeffitients = zeros(2, number_of_J_values);
acc_measure_mappings = zeros(persons_count, 2, number_of_J_values);

for i=1:number_of_J_values
    J = J_values(i);
    
    % Dekompozycja tensora treningowego wg CP ALS
    U_cp_als = CP_ALS(pictures, 2, J, cp_als_iterations, @unfold3); % faktory estymowane CP-APLS

    % Klastrowanie
    clustering_labels = kmeans(U_cp_als{3}, persons_count);
    clustering_results(:, i) = clustering_labels;
    [Acc,rand_index,match] = AccMeasure(labels, clustering_labels');    
    acc_measure_coeffitients(:, i) = [Acc,rand_index];
    match_transposed = match';
    acc_measure_mappings(:, :, i) = match_transposed;
        
    % odtworzenie obrazów
    Y_est_cp_als = ktensor(ones(J, 1), U_cp_als);
    recreated_images = double(Y_est_cp_als);
    
    images_count = size(recreated_images, 3);
    figure
    title(['J=' num2str(J)]);
    for  j=1:images_count
        % wyświetlenie obrazów
        subplot(persons_count, images_in_row, j);
        imshow(uint8(recreated_images(:, :, j)));
        clustering_label = clustering_labels(j);
        match_sorted = sortrows(match_transposed, 2);
        translated_label = match_sorted(clustering_label, 1);
        title(num2str(translated_label));
    end      
end

