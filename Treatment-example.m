clear;
clc;
close all;

%%
% Treats all the images in the designed folder
% For each image, the user needs to segment, then quit, then press any
% button to continue
% parameters
folder = 'D:\Test\';
iDAPI = 4;
nameChannels = {'Olig3','Pax7','TFAPA'};
iChannels = [2,3,5];
FACScutOffs = [1000,100,3500];
radius = 2;
convPixel = 700/480;
bin = 5;
numSlice = 1; %numSlice = 1 if projected, otherwise number of the slide on an non-projected stack




Allimagenames = dir(strcat(folder,'*.tif'));

mkdir(folder,'Results\');
savefolder = [folder 'Results\'];

for imgNumber =1:size(Allimagenames,1)
    close all;
    imagename = Allimagenames(imgNumber).name;
    
    % Recover number of channels from the filename
    filename = strcat(folder,imagename);
    info=imfinfo(filename);
    nChannels=str2num(extractBetween(convertCharsToStrings(info(1).ImageDescription),"channels=",newline));
    
    % Load the DAPI image and find the border of the colony
    I=double(imread(filename,nChannels*(numSlice-1)+iDAPI));
    segment_cell(I);
    uiwait(gcf);
    pause();
    
    % Find local maxima
    % In most cases, Gaussian filtering before maxima identification
    % prevents identification of non-nuclear local maxima
    % 20X-> use blur
        %Iblur=imgaussfilt(I,2);
        %localmaxima=FastPeakFind(Iblur,0);
        
    % 10X-> do not use blur
    localmaxima=FastPeakFind(I,0);

    
    % Filtering of local maxima, keeping those within
    % the colony and not too close to the image border
    binarisedI = bw_output;
    filteredlocalmaxima=[];
    [a,b]=size(I);
    for i=1:2:length(localmaxima)
        if (and(and(binarisedI(localmaxima(i+1),localmaxima(i))==1,(localmaxima(i)-radius)*(b-localmaxima(i)-radius)>0),(localmaxima(i+1)-radius)*(a-localmaxima(i+1)-radius)>0))
            filteredlocalmaxima = [filteredlocalmaxima;localmaxima(i),localmaxima(i+1)];
        end
    end
    
    % Computation of the distance to the border of the colony
    % If the closest border is at the border of the image,
    % returns a NaN value
    boundary  = bwboundaries(binarisedI);
    boundary = boundary{1};
    dist=NaN(length(filteredlocalmaxima),1);
    for i=1:length(filteredlocalmaxima)
        [xy,distance,t] = distance2curve(boundary,[filteredlocalmaxima(i,2),filteredlocalmaxima(i,1)],'linear');
        if (xy(1) ~=1 && xy(1) ~= a && xy(2) ~=1 && xy(2) ~= b)
            dist(i) = distance*convPixel;
        end
    end
    
    % Removing points whose closest border is at the border of the image
    filteredlocalmaxima=filteredlocalmaxima(~isnan(dist),:);
    dist=dist(~isnan(dist));
    
    %     % Intermediate plotting
    %     figure();
    %     imagesc(I); hold on
    %     plot(filteredlocalmaxima(:,1),filteredlocalmaxima(:,2),'r+') ;
    
    se = strel('disk',radius,0);
    imt = se.Neighborhood;
    [nonzerox,nonzeroy]=find(imt);
    nonzerox=nonzerox-(radius+1);
    nonzeroy=nonzeroy-(radius+1);
    
    %     % To adjust the radius, uncomment this section and add a breakpoint
    %     % You will visualize up to 100 structuring elements on the initial
    %     % image on which the intenity will be computed
%         pixelimt= I;
%         for k=1:min(size(filteredlocalmaxima,1),100)
%             y=filteredlocalmaxima(k,1);
%             x=filteredlocalmaxima(k,2);
%             for i=(x-radius):(x+radius)
%                 for j=(y-radius):(y+radius)
%                     if (imt(x+radius+1-i,y+radius+1-j)==1)
%                         pixelimt(i,j)=max(max(I));
%                     end
%                 end
%             end
%         end
%         figure();
%         imagesc(pixelimt);
    
    % Computation of intensities in sphere or radius 'radius'
    
    Im = zeros(a,b,size(iChannels,2));
    for iChannel=1:size(iChannels,2)
        Im(:,:,iChannel)=double(imread(filename,nChannels*(numSlice-1)+iChannels(iChannel)));
    end
    

    
    Int=zeros(length(filteredlocalmaxima),size(iChannels,2));
    for i=1:length(filteredlocalmaxima)
        for j=1:size(nonzerox,1)
            for iChannel=1:size(iChannels,2)
                Int(i,iChannel)=Int(i,iChannel)+Im(filteredlocalmaxima(i,2)+nonzerox(j),filteredlocalmaxima(i,1)+nonzeroy(j),iChannel);
            end
        end
    end
    Int(:,:)=Int(:,:)./size(nonzerox,1);
    
    % % To adjust FACSCutOffs values, uncomment this section and add a breakpoint
%     for iChannel=1:size(iChannels,2)
%       FACS_like_1D(Im(:,:,iChannel),Int(:,iChannel),filteredlocalmaxima);
%       pause();
%     end
    
    % Binning
    distmin=1;
    distmax=floor(max(dist)/bin)+1;
    
    % Reordering in a 3D Matrix (distance, intensity, channel)
    % Only one value per column is not NaN at distance d
    IntBinnedMat=NaN(distmax,length(filteredlocalmaxima),size(iChannels,2));
    for d=distmin:distmax
        indices = (floor(dist/bin)+1==d);
        IntBinnedMat(d,indices,:) = Int(indices,:);
    end
    
    % Compute percentages of positive cells according to distance
    isatDistanced=double(~isnan(IntBinnedMat(:,:,1)));
    numberCellsataDistanced = sum(isatDistanced,2);
    
    isPositiveCell=NaN(length(filteredlocalmaxima),size(iChannels,2));
    for iChannel = 1:size(iChannels,2)
        isPositiveCell(:,iChannel)=double(Int(:,iChannel)>FACScutOffs(iChannel));
        PercentagePositiveCells=mtimes(isatDistanced,isPositiveCell)./numberCellsataDistanced*100;
    end
    
    PercentagePositiveCellsToT=sum(PercentagePositiveCells.*numberCellsataDistanced)/sum(numberCellsataDistanced);
    
    % Statistics on the 3D Matrix
    IntMediane=NaN(distmax,size(iChannels,2));
    IntQuantile1=NaN(distmax,size(iChannels,2));
    IntQuantile3=NaN(distmax,size(iChannels,2));
    xx = linspace(bin*distmin,bin*distmax,distmax-distmin+1);
    for d = distmin:distmax
        for iChannel = 1:size(iChannels,2)
            IntMediane(d,iChannel) = quantile(IntBinnedMat(d,:,iChannel),0.5);
            IntQuantile1(d,iChannel) = quantile(IntBinnedMat(d,:,iChannel),0.25);
            IntQuantile3(d,iChannel) = quantile(IntBinnedMat(d,:,iChannel),0.75);
        end
    end
    
    % % Plotting of Percentages for each colony
    % figure('Name','Percentage of positive cells according to distance');
    % hold on
    % for iChannel=1:size(iChannels,2)
    %      plot(xx,PercentagePositiveCells(:,iChannel),'linewidth', 2);
    % end
    % hold off;
    % legend(nameChannels)
    % set(gca,'FontSize',20)
    % xlabel ('Distance from the border of the colony (µm)');
    
    
    % Save results in a matlab file for further use
    [pathstr, name_exp, ext] = fileparts(imagename);
    matlabfilename = [name_exp '.mat'];
    save([savefolder matlabfilename],'xx','bin','radius','convPixel','binarisedI','dist');
    
    for iChannel=1:size(iChannels,2)
        assignin('base', ['cutOff' nameChannels{iChannel}], FACScutOffs(iChannel));
        assignin('base', ['Int' nameChannels{iChannel}], Int(:,iChannel));
        assignin('base', ['Percentage' nameChannels{iChannel} 'PositiveCells'] , PercentagePositiveCells(:,iChannel));
        assignin('base', ['Percentage' nameChannels{iChannel} 'PositiveCellsToT'] , PercentagePositiveCellsToT(:,iChannel));
        save([savefolder matlabfilename]',['cutOff' nameChannels{iChannel}],['Int' nameChannels{iChannel}],['Percentage' nameChannels{iChannel} 'PositiveCells'],['Percentage' nameChannels{iChannel} 'PositiveCellsToT'],'-append');
    end
end