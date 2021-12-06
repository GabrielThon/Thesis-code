function [nPos] = getXYPositions(textfile, imagefile)
    nPos=1;
    info= fopen(textfile);
    while ~feof(info)
        tline = fgetl(info);
        if (contains(tline,'XY Positions -') && contains(imagefile,'_f00'))
            nPos= char(tline);
            nPos= nPos(findstr(nPos,' - (')+4:findstr(nPos,')')-1);
            nPos= str2num(nPos);
        end
    end
    fclose(info);
end