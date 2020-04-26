function [mean_accuracy, rand_index, mean_time] = run_clustering_measurment(dataset, labels, clusters, iterations_count)
    %RUN_CLUSTERING_MEASURMENT powtarza kNN na zbiorze danych dataset
    % dataset - macierz danych
    % labels - lista poprawnych grup
    % clusters - liczba klastrów na które zostanie podzielony zbiór danych
    % iterations_count - liczba powtórzeń pętli uśredniającej wyniki
    %   Detailed explanation goes here
        results = zeros(iterations_count, 3);
        for i=1:iterations_count
            start = tic;
            kMatrix = kmeans(dataset, clusters);
            [acc, r_index, match ] = AccMeasure(kMatrix, labels);
            elapsed_time = toc(start);
            results(i, :) = [acc r_index elapsed_time];
        end
        mean_accuracy = mean(results(:, 1));
        rand_index = mean(results(:, 2));
        mean_time = mean(results(:, 3));
    end
    
    
    