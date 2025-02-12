function [pictures_array, labels] = load_att_pictures(folder_path, pictures_limit)
    %LOAD_PICTURES ładuje określoną liczbę zdjęć z folderu att_files
    % którego ścieżkę określa parametr folder_path
    % zwraca 3-wymiarową tablicę zdjęć oraz 2-wymiarową tablicę grup, do
    % których należą poszczególne zdjęcia.
        number_of_folders = 40;
        number_of_images_in_folder = 10;
        
        % właściwe numery grup, do których należą zdjęcia
        labels = zeros(1, pictures_limit);
        
        [dim1, dim2] = size(imread([folder_path '/s1/1.pgm']));
        pictures_array = zeros(dim1, dim2, pictures_limit);
    
        counter = 1;
        for i = 1:number_of_folders
            if(counter > pictures_limit)
                break;
            end
            for j = 1:number_of_images_in_folder
                if(counter > pictures_limit)
                    break;
                end
                picture = imread([folder_path '/s' num2str(i) '/' num2str(j) '.pgm']);
                pictures_array(:,:, counter) = picture;
                labels(counter) = i; % folder jest podstawą grupowania zdjęć
                counter = counter + 1;
            end
        end
    end
    
    