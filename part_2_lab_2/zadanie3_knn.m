function accuracy_vector = zadanie3_knn(persons_count, J_values)
    %ZADANIE3_KNN dokonuje dekompozycji na zbiorze treningowym i testuje
    % jakość klasfikacji kNN (dokładność)
    % przykład wywołania: result = zadanie3_knn(10, [4 10 20 30]);
    % param J_values - wektor stopni faktoryzacji to przetestowania
    % param persons_count - liczba osób do wczytania z pliku
    % returns accuracy_vector - wektor (tablica 1-wymiarowa) dokładności
    % klasteryzacji dla kolejnych J-values
        
    if(persons_count > 40)
        err("Maxiumum persons count is 40");
    end
      
    % Stałe
    K=5; % Parametr K-krotnej walidacji przyżowej walidacji
    images_in_row = 10;
        
    % Zdjęcia wczytujemy jako tablicę 3D wraz z ich poprawnymi grupami
    [pictures, labels] = load_att_pictures('att_faces', persons_count * images_in_row);
    
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
    
    % zbiór trenujący i jego prawidłowe grupowanie
    Y_r = tensor(pictures(:, :, trainging_indexes)); % tensor obserwacji treningowych
    Y_t = tensor(pictures(:, :, test_indexes));
    labels_r = labels(trainging_indexes);
    labels_t = labels(test_indexes);
            

    number_of_J_values = size(J_values, 2);
        
    % pomiar poprawności klasteryzacji dla każdego J
    accuracy_vector = zeros(number_of_J_values, 1);
    
   for i=1:number_of_J_values
        J = J_values(i);
           [U_r, G_r] = HOSVD(Y_r, [J J J], @unfold3); % faktory estymowane HOSVD
           
           % rzutowanie 
           G_r3 = unfold3(double(G_r), 3);
           Ur2_t_Ur1 = kron(U_r{2}, U_r{1});
           G_3 = G_r3 * Ur2_t_Ur1';
           Y_t3 = unfold3(double(Y_t), 3);
           U_t3 = Y_t3 * pinv(G_3);
           model = fitcknn(U_r{3}, labels_r);
           predictions = predict(model, U_t3);
           
           % pomiar dokładności
           accuracy = 100 * sum(predictions' == labels_t) / numel(labels_t);
           accuracy_vector(i) = accuracy;
   end     
end 
