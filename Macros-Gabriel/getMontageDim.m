%Reads the .txt file and extract the X, Y and overlap data
function [X,Y,overlap] = getMontageDim(textfile)
    X=1;
    Y=1;
    overlap=0;
    info= fopen(textfile);
    while ~feof(info)
        tline = fgetl(info);
        if contains(tline,'Montage Positions ')
            X = char(tline);
            X = X(findstr(X,' ( ')+3:findstr(X,' by ')-1);
            X = str2num(X);
            Y = char(tline);
            Y = Y(findstr(Y,' by ')+4:findstr(Y,' ))')-1);
            Y = str2num(Y);
            while ~feof(info)
                tline = fgetl(info);
                if contains(tline,'Overlap')
                    overlap = char(tline);
                    overlap = overlap(findstr(overlap,'Overlap')+8:findstr(overlap,'Width')-1);
                    overlap = str2num(overlap);
                end
            end
        end
    end
    fclose(info);
end