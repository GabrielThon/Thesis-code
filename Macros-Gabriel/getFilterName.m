% Transposes the channels names to filters
function [filters] = getFilterName(channels)
    filters=strings(size(channels,1),1);
    for i=1:size(channels)
        filters(i)=strcat(channels(i),'-flatfield');
    end
end