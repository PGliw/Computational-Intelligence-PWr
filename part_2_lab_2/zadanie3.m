% Stałe
K=5; % Parametr K-krotnej walidacji przyżowej walidacji
J_values = [4, 10, 20, 30];
Grop_sizes = [4, 10, 20, 30, 40];

pictures = load_att_pictures('att_faces', 40);

% Wektor kolejnych rozmiarów tensora obrazów
I = size(pictures);
pirctures_indexes = 1:I(3);

% 5-fold-cv
cv_partitions = cvpartition(pirctures_indexes, 'KFold', K);

for partition_index = 1:cv_partitions.NumTestSets
        training_mask = cv_partitions.training(partition_index);
        test_mask = cv_partitions.test(partition_index);
        
        trainging_indexes = pirctures_indexes(training_mask);
        test_indexes = pictures_indexes(test_mask);
        
        for J = J_values
            training_pictures_set = pictures(trainging_indexes);
            cp_tensor = ktensor(ones(1, J), training_pictures_set);
            [U_cp, cp_err] = CP()
            
            test_pictures_set = pictures(test_indexes);
        end
%   for J = J_values
%       test_set = pictures[test]
%       U_cp = CP(test_set, J, ...)
%       U_hosvd =  HOSVD(test_set)
%       for group_size in group_sizes
%           group U3_est using kmeans
%           plot results
%           measure accuracy
%       end
end


loaded_image = pictures(:, :, 1);
figure
imshow(uint8(loaded_image));
