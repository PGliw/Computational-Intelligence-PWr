function [U] = CP_ALS(Y, p, J, iterations, unfold)
    %CP wykonuje dekompozycje tensora Y na faktory z rzędem faktoryzacji J
    % p określa normę zastosowaną do normalizacji faktorów
    % itenrations określa liczbę iteracji
    % unfold to funkcja o sygnaturze (tensor, mod) => macierz
    % przekazanie funkcji unfold jako praramter pozwala w przyszłości rozwinąć
    % ten program dla liczby modów > 3 
    % (obecnie zaimplementowaliśmy tylko unfold dla N=3 modów)
    
       % N - liczba modów
       I = size(Y);
       N = size(size(Y), 2); % liczba modów
    
       
       % losowa inicjalizacja faktorów
       U = cell(1, 3);
       for i=1:size(I, 2)
           U{i} = max(0, rand(I(i), J));
       end
       
       Y_arr = double(Y); % konwersja tensora na tablicę wielowymiarową
       
       % wyznaczanie faktorów powtórzone iterations razy
       for i = 1:iterations
           
           % przemiatanie po wszystkich (N) modach tensora obserwacji Y
           for n = 1:N
               % Matrycyzacja względem n-tego modu
               Yn = unfold(Y_arr, n);
               
               % Estymacja n-tego faktora za pomocą m. najmniejszych kwadratów
               
               % Iloczyn Hadamana faktorów poza n-tym
               indexes_without_n = copy_without_element(1:N, n);
               B = ones(J, J);
               for j = indexes_without_n
                  B = B .* (U{j}' * U{j});
               end
               
               % Iloczyn Khatri-Rao faktorów poza n-tym
               kr_indexes = flip(indexes_without_n);
               U_kr = U{kr_indexes(1)};
               for j = 2:size(kr_indexes, 2)               
                   next_index = kr_indexes(j);
                   U_kr = kr(U_kr, U{next_index});
               end
               
               % Estymacja U{n}
               U{n} = (Yn * U_kr) / B; 
               
               % Skalowanie n-tego faktora
               if n ~= N
                   coefficient = inv(diag(vecnorm(U{n}, p)));
                   U{n} = U{n} * coefficient;
               end           
           end
       end
    end
    