% Stałe
K=5; % Parametr K-krotnej walidacji przyżowej walidacji
J_values = [4, 10, 20, 30];
Cluster_numbers = [4, 10, 20, 30, 40];
cp_als_iterations = 30;

% Tablice wynikowe
% U_cp_als_values = zeros()

% Zdjęcia wczytujemy jako tablicę 3D wraz z ich poprawnymi grupami
[pictures, labels] = load_att_pictures('att_faces', 40);

% Wektor kolejnych rozmiarów tensora obrazów
I = size(pictures);
pictures_indexes = 1:I(3);

% 5-fold-cv
cv_partitions = cvpartition(pictures_indexes, 'KFold', K);

%%for partition_index = 1:cv_partitions.NumTestSets
partition_index = 1; % TODO
training_mask = cv_partitions.training(partition_index);
test_mask = cv_partitions.test(partition_index);
trainging_indexes = pictures_indexes(training_mask);
test_indexes = pictures_indexes(test_mask);
        

Y_r = tensor(pictures(:, :, trainging_indexes)); % tensor obserwacji treningowych
labels_r = labels(trainging_indexes);
j = 5; % TODO for loop
U_r_cp_als = CP_ALS(Y_r, 2, j, cp_als_iterations, @unfold3); % faktory estymowane CP-APLS
%U_cp_als{3} % macierz czynnikowa dla 3. modu zbioru tren.
clusters = Cluster_numbers(1);
Y_t = tensor(pictures(:, :, test_indexes));
labels_t = labels(test_indexes);

[cp_als_accuracy, cp_als_rand_index, cp_als_mean_time] = run_clustering(U_r_cp_als{3}, labels_r, 4, 100);

%U_r_cp_als

% for partition_index = 1:cv_partitions.NumTestSets TODO
%     for J = J_values   
%         for group_size = Cluster_numbers
%         end
%     end
% end

%   for J = J_values
%       test_set = pictures[test]
%       U_cp = CP(test_set, J, ...)
%       U_hosvd =  HOSVD(test_set)
%       for group_size in group_sizes
%           group U3_est using kmeans
%           plot results
%           measure accuracy
%       end

%%end


loaded_image = pictures(:, :, 1);
figure
imshow(uint8(loaded_image));

function [mean_accuracy, rand_index, mean_time] = run_clustering(dataset, labels, clusters, iterations_count)
    results = zeros(iterations_count, 3);
    for i=1:iterations_count
        start = tic;
        kMatrix = kmeans(dataset, clusters);
        [acc, random_index, match ] = AccMeasure(kMatrix, labels);
        elapsed_time = toc(start);
        results(i, :) = [acc random_index elapsed_time];
    end
    mean_accuracy = mean(results(:, 1));
    rand_index = mean(results(:, 2));
    mean_time = mean(results(:, 3));
end
