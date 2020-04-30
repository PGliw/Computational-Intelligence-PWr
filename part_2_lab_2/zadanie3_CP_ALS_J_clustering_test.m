function acc_measure_coefficients = zadanie3_clustering_test(persons_count, method, J_values)
    %ZADANIE3_CLUSTERINT_TEST porównuje jakość klasyfikacji i drukuje
    %odtworzone obrazy 
    % param persons_count - liczba osób do wczytania z pliku, np. 5
    % param method - jedna z metod redukcji wym.: 'PCA'/'CP-ALS'/'HOSVD'
    % param J_values - wektor wartości J np.  J_values = [4, 10, 20, 30]
    % returns acc_measure_coefficients - tablica
    % side effect: drukuje na ekranie wyniki klasteryzacji
    if(persons_count > 40)
        err("Maxiumum persons count is 40");
    end
    
    if(~any(strcmp({'PCA', 'CP-ALS', 'HOSVD'}, method)))
       err(['Incorrect method name:' method]) 
    end
    
    % Stałe    
    cp_als_iterations = 30;
    images_in_row = 10;
        
    % Zdjęcia wczytujemy jako tablicę 3D wraz z ich poprawnymi grupami
    [pictures, labels] = load_att_pictures('att_faces', persons_count * images_in_row);
    
    % Wektor kolejnych rozmiarów tensora obrazów
    I = size(pictures);
    
            
    % zbiór trenujący i jego prawidłowe grupowanie
    Y = tensor(pictures); % tensor obserwacji treningowych
    
    % dla PCA trzeba zmienić macierz 3D na 2D
    Y_pca = unfold3(pictures, 3); 
    
    number_of_J_values = size(J_values, 2);
    
    % akumulator wyników klastrowania dla różnych wartości J
    clustering_results = zeros(persons_count * images_in_row, number_of_J_values);
    
    % pomiar poprawności klastrowania dla każdego J
    acc_measure_coefficients = zeros(2, number_of_J_values);
    acc_measure_mappings = zeros(persons_count, 2, number_of_J_values);
    
    for i=1:number_of_J_values
        J = J_values(i);
        
        % W zależności od metody kroki wyglądają inaczej
        % 1. Dekompozycja tensora treningowego
        % 2. Odtworzenie (aproksymacja) tensora obserwacji
        % 3. Klastrowanie
        % 4. Odtworzenie obrazu
        switch method
            case 'PCA'
                [U_pca, Z] = PCA(Y_pca, J); % składowe główne dla PCA
                Y_est = U_pca * Z; % dla PCA
                clustering_labels = kmeans(Y_est, persons_count); % dla PCA
                Y_est_pca_3D = fold3_3(Y_est, I); % dla PCA
                recreated_images = 255 * normalize(Y_est_pca_3D, 'range'); % dla PCA 
            case 'CP-ALS'
                U_cp_als = CP_ALS(pictures, 2, J, cp_als_iterations, @unfold3); % faktory estymowane CP-APLS
                Y_est = ktensor(ones(J, 1), U_cp_als); % dla CP ALS
                clustering_labels = kmeans(U_cp_als{3}, persons_count); % dla CP ALS
                recreated_images = double(Y_est); % dla HOSVD i dla CP ALS
            case 'HOSVD'
                [U_hosvd, G] = HOSVD(Y, [J J J], @unfold3); % faktory estymowane HOSVD
                Y_est = ttensor(G, U_hosvd); % dla HOSVD
                clustering_labels = kmeans(U_hosvd{3}, persons_count); % dla HOSVD
                recreated_images = double(Y_est); % dla HOSVD i dla CP ALS
        end
        
        % Ocena jakości klasteryzacji
        [Acc,rand_index,match] = AccMeasure(labels, clustering_labels');    
        acc_measure_coefficients(:, i) = [Acc,rand_index];
        match_transposed = match';
        acc_measure_mappings(:, :, i) = match_transposed;
            
        % wyświetlenie obrazów
        images_count = size(recreated_images, 3);         
        figure(i);    
        title(['Obrazy dla J=' num2str(J)]);    
        for  j=1:images_count
            subplot(persons_count, images_in_row, j);
            imshow(uint8(recreated_images(:, :, j)));
            clustering_label = clustering_labels(j);
            match_sorted = sortrows(match_transposed, 2);
            translated_label = match_sorted(clustering_label, 1);
            title(num2str(translated_label));
            
            % dodanie predykowanego numeru grupy przetłumaczonego na oryginalne
            % numery grup do akumulatora wyników
            clustering_results(j, i) = translated_label;
        end     
        
        % wyświetlenie macierzy konfuzji
        figure(i + number_of_J_values);
        title(['Macierz konfuzji dla J=' num2str(J)]);
        plotConfMat(confusionmat(labels, clustering_results(:, i)'));
        
    end
end
