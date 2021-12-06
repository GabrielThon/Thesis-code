%Reads the .txt file and extract the number of Z stacks if a Z Scan was performed
function [z] = getZStack(textfile)
    z = 1;
    info= fopen(textfile);
    while ~feof(info)
        tline = fgetl(info);
        if contains(tline,'um in ')
            z= char(tline);
            z= z(findstr(z,'um in')+6:findstr(z,'planes')-1);
            z= str2num(z);
        end
    end
    fclose(info);
end