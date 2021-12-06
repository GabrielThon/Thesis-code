clear all;
clc;
close all;

%% paramètres à changer
% All the treated folders must have the same binning
% For intensities, make sure experiments are from the same immunostaining

%parameters
folder = 'D:\Test2\';
nameChannels = {'Olig3','Pax7','TFAPA'};
colors =[0.8500, 0.3250, 0.0980
    0, 0.4470, 0.7410
    0, 0.5, 0];
noise = [500 300 100];
nameConditions ={'NoBMP','BMP1D4to9','BMP2D4to9','BMP5D4to9','BMP10D4to9','BMP10D3to9','BMP10D6to9','BMP10D8to9'};
idCondition={'well00','well11','well12','well13','well14','well09','well19','well15'};



% Retrieve matlab filenames in an organised structure
matfiles = dir([folder '*.mat']);
clear ('s');
for cond=1:size(nameConditions,2)
    s{cond}=matfiles(contains({matfiles.name},idCondition{cond})); 
end

mkdir(folder,'Results\');
savefolder = [folder 'Results\'];

% 
load([s{1}(1).folder '\' s{1}(1).name],'bin');

for cond=1:size(s,2)
    for iimg=1:size(s{cond},1)
        vartoImport='dist';
        clear(vartoImport,'temp');
        temp = load([s{cond}(iimg).folder '\' s{cond}(iimg).name],vartoImport);
        if ~(isempty(fieldnames(temp)));
            Dist{cond}{iimg}=transpose(temp.(vartoImport));
        else
            Dist{cond}{iimg}=[];
        end
        for iChannel=1:size(nameChannels,2)
            vartoImport=['Percentage' nameChannels{iChannel} 'PositiveCells'];
            clear(vartoImport,'temp');
            temp = load([s{cond}(iimg).folder '\' s{cond}(iimg).name],vartoImport);
            if ~(isempty(fieldnames(temp)));
                Perc{iChannel,cond}{iimg}=temp.(vartoImport);
            else
                Perc{iChannel,cond}{iimg}=[];
            end
            vartoImport=['Int' nameChannels{iChannel}];
            clear(vartoImport,'temp');
            temp = load([s{cond}(iimg).folder '\' s{cond}(iimg).name],vartoImport);
            if ~(isempty(fieldnames(temp)));
                Int{iChannel,cond}{iimg}=transpose(temp.(vartoImport));
            else
                Int{iChannel,cond}{iimg}=[];
            end
        end
    end
end

%% Intensity
cd(savefolder);
% Statistics on intensities from different colonies 
% Careful(they must be FROM THE SAME EXPERIMENT)
for cond=1:size(s,2)
    for iChannel=1:size(nameChannels,2)
        isNonEmptyInt = ~cellfun('isempty',Int{iChannel,cond});
        tempInt=[Int{iChannel,cond}(isNonEmptyInt)];
        tempInt=[tempInt{:}];
        tempdist=[Dist{cond}(isNonEmptyInt)];
        tempdist=[tempdist{:}];
        
        distmin=1;
        distmax=floor(max(tempdist/bin))+1;
        Mean{iChannel,cond}=NaN(distmax,1);
        Quartile{iChannel,cond,1}=NaN(distmax-distmin+1,1);
        Quartile{iChannel,cond,2}=NaN(distmax-distmin+1,1);
        for idist=distmin:distmax
            indices = (floor(tempdist/bin)+1==idist);
            numbCells{idist,cond}=sum(indices);
            if sum(indices)>20
                Mean{iChannel,cond}(idist) = nanmean(tempInt(indices))-noise(iChannel);
                Quartile{iChannel,cond,1}(idist) = quantile((tempInt(indices)),0.25)-noise(iChannel);
                Quartile{iChannel,cond,2}(idist) = quantile((tempInt(indices)),0.75)-noise(iChannel);
            end
        end
        Surface{iChannel,cond} = [transpose(Quartile{iChannel,cond,1}) fliplr(transpose(Quartile{iChannel,cond,2}))];
    end
    xx{cond}=linspace(0,(distmax-distmin)*bin,(distmax-distmin)+1);
    xxSurface{cond} = [xx{cond} fliplr(xx{cond})];
    temp=~isnan(Surface{1,cond});
    xxSurface{cond} = xxSurface{cond}(temp);
    for iChannel=1:size(nameChannels,2)
        Surface{iChannel,cond} = Surface{iChannel,cond}(temp);
    end
end
%Normalisation
maxperChannel=max([Mean{:,1}]);

for cond = 2:size(s,2)
    for iChannel=1:size(nameChannels,2)
            if max([Mean{iChannel,cond}])>maxperChannel(iChannel)
                maxperChannel(iChannel)=max([Mean{iChannel,cond}]);
            end
    end 
end

%Plot
for cond = 1:size(s,2)
    figure('Name',nameConditions{cond});
    hold on;
    for iChannel=1:size(nameChannels,2)
        plot(xx{cond}, Mean{iChannel,cond}./maxperChannel(iChannel),'Color',colors(iChannel,:),'linewidth', 2);
        h = fill(xxSurface{cond}, Surface{iChannel,cond}./maxperChannel(iChannel),colors(iChannel,:),'FaceAlpha',0.25,'EdgeColor','none');
    end 
    xlim([0 350]);
    ylim([0 1]);
    xticks([0 100 200 300]);
    yticks([0 0.5 1]);
    %xlabel ('Distance from the border of the colony (µm)');
    %ylabel('% positive cells');
    
    set(gca, ...
    'Units', 'centimeters');
    set(gca, ...
        'Position', [0.5 0.5 2.75 1.8]);
    set(gcf, ...
        'Units', 'centimeter');
    set(gcf, ...
        'Position', [8 10 3.5 2.5]);
    set(gca,'FontSize',8);
    
    hold off;
    
    print([nameConditions{cond} '-intensities'],'-dpdf')
end
%end
%% Percentages
cd(savefolder);
for cond = 1:size(s,2)
    for iChannel=1:size(nameChannels,2)
        for j=1:size(Perc{iChannel,cond},2)
            sz(j)=size(Perc{iChannel,cond}{j},1);;
        end
        sz = floor(quantile(sz,0.9));
        
        matPerc{iChannel}=NaN(sz,size(Perc{iChannel,1},2));
        for j=1:size(Perc{iChannel,cond},2)
            for i=1:min(sz,size(Perc{iChannel,cond}{j},1))
                matPerc{iChannel}(i,j)=Perc{iChannel,cond}{j}(i);
            end
        end
        meanPerc{iChannel}=nanmean(matPerc{iChannel},2);
        xx{iChannel} = linspace(5,sz*5,sz);
    end
    
    figure('Name',nameConditions{cond});
    hold on
    for iChannel=1:size(nameChannels,2)
        plot(xx{iChannel},meanPerc{iChannel},'Color',colors(iChannel,:),'linewidth', 2);
    end
    xlim([0 350]);
    ylim([0 100]);
    xticks([0 100 200 300]);
    yticks([0 50 100]);
    %xlabel ('Distance from the border of the colony (µm)');
    %ylabel('% positive cells');
    set(gca, ...
    'Units', 'centimeters');
    set(gca, ...
        'Position', [0.5 0.5 2.75 1.8]);
    set(gcf, ...
        'Units', 'centimeter');
    set(gcf, ...
        'Position', [8 10 3.5 2.5]);

    set(gca,'FontSize',8);
    %legend('Pax7','Olig3','TFAPA');
    hold off

    print(nameConditions{cond},'-dpdf')
end

