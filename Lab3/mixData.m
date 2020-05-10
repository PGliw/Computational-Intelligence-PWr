function [ mixedData ] = mixData( Data, M )
    A = rand(M, 3);
    mixedData = A*Data;
end

