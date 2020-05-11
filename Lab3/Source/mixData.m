function [ mixedData, mixingSource ] = mixData( Data, M )
    mixingSource = rand([M 3]);
    mixedData = mixingSource*Data;
end

