% Transposes the channels names to colors
function [colors] = getChannelName(channels)
    colors=strings(size(channels,1),1);
    for i=1:size(channels)
        if (channels(i)=="Tom_BF" || channels(i)=="BF")
            colors(i)="Grays";
        end
        if (channels(i)=="Tom_YFP" || channels(i)=="YFP" || channels(i)=="GFP" || channels(i)=="Tom_GFP")
            colors(i)="Green";
        end
        if (channels(i)=="Tom_RFP" || channels(i)=="RFP")
            colors(i)="Red";
        end
        if (channels(i)=="Tom_CFP" || channels(i)=="CFP" || channels(i)=="Tom_DAPI")
            colors(i)="Blue";
        end
        if (channels(i)=="Tom_FR" || channels(i)=="far red" || channels(i)=="Tom_FarRed")
            colors(i)="Magenta";
        end
    end
end