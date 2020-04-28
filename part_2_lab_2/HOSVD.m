function [U, G] = HOSVD(Y, J, unfold)
    %HOSVD dokonuje dekomozycji N-wymiarowego tensora obserwacji Y
    % J to wektor określający poszczególne stopnie faktoryzacji - J1, ..., JN
    % unfold to funkcja matrycyzująca tensor
    % U - cell array estymowanych faktorów
    % G - tensor rdzeniowy
    
        N = size(size(Y), 2); % liczba modów
           
        U = cell(1, N);   
        Y_arr = double(Y); % konwersja tensora na tablicę wielowymiarową
           
        % przemiatanie po wszystkich (N) modach tensora obserwacji Y
        for n = 1:N
            % Matrycyzacja względem n-tego modu
            Yn = unfold(Y_arr, n);
            correlation_matrix = Yn * (Yn)';
            
            % Wyznacznienie J(n) wektorów wektorów własnych i wartości własnych
            % macierzy korelacji
            [eigen_vectors, eigen_values_matrix] = eigs(correlation_matrix, J(n));
            U{n} = eigen_vectors;
        end
        G = ttm(Y, U, 't'); % t oznacza transpozycję macierzy U
    end
    
    