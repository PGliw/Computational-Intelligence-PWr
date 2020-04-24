function [pictures_tensor] = load_att_pictures(folder_path, pictures_limit)
    %LOAD_PICTURES ładuje określoną liczbę zdjęć z folderu att_files
    % którego ścieżkę określa parametr folder_path
    % zwraca 3-wymiarową tablicę zdjęć
        number_of_folders = 40;
        number_of_images_in_folder = 10;
        
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
                counter = counter + 1;
            end
        end
        pictures_tensor = pictures_array;
    end
    
    