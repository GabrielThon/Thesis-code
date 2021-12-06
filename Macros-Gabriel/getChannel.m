% Reads the .txt file and extract the different channels used during the experiment
function [allChannels] = getChannel(textfile)
    info= fopen(textfile);
    while ~feof(info)
        tline = fgetl(info);
        if contains(tline,'Repeat - Channel (')
            allChannels = char(tline);
            allChannels = split(allChannels(findstr(allChannels,'(')+1:findstr(allChannels,')')-1),',');
        end
    end
    fclose(info);
end