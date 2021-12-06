function generateFilters(textfiles,savefolder,lambda,isFluorescence)
    if ~exist(strcat(savefolder,"Computed-filters\"), 'dir')
        mkdir(savefolder,"Computed-filters\");
    end
    
    Stacksfilenames = dir(strcat(savefolder,'AllImages\','*.tif'));
    
    c=size(Stacksfilenames,1);
    Filtersfilenames = strings(size(Stacksfilenames,1),1);
    BackgroundFiltersfilenames = strings(size(Stacksfilenames,1),1);
    for i=1:c
        [pathstr, name, ext] = fileparts(Stacksfilenames(i).name);
        Filtersfilenames(i)=strcat(savefolder,'Computed-filters\',name,'-flatfield.tif');
        BackgroundFiltersfilenames(i)=strcat(savefolder,'Computed-filters\',name,'-darkfield.tif');
    end
    Stacksfilenames =  reshape(strcat(savefolder,'AllImages\',{Stacksfilenames.name}), [c 1]);
   
    Iminfo=imfinfo(Stacksfilenames{1});
    flatfield = zeros(Iminfo(1).Height,Iminfo(1).Width,c);
    darkfield = zeros(Iminfo(1).Height,Iminfo(1).Width,c);
    
    for ic = 1:c
        Iminfo=imfinfo(Stacksfilenames{c});
        IF = uint16(zeros(Iminfo(1).Height,Iminfo(1).Width,size(Iminfo,1)));
        for i = 1:size(Iminfo,1)
            IF(:,:,i) = imread(char(Stacksfilenames(ic)),i); % original image
        end
        [flatfield(:,:,ic), darkfield(:,:,ic)] = BaSiC(IF,'darkfield','true','lambda',lambda,'lambda_dark',5.0);% can use 2?
        maxflatfield=reshape(max(max(flatfield,[],1),[],2),[c,1]);
        flatfield(:,:,ic)=flatfield(:,:,ic)/maxflatfield(ic);
        if isFluorescence
            basefluor{ic} =  BaSiC_basefluor(IF,flatfield(:,:,ic),darkfield(:,:,ic));
        end
        %Saving is complicated(imwrite scales to 255 and we want to keep it to 1
        %imwrite(flatfield(:,:,ic),char(Filtersfilenames(ic)),'tiff');
        t = Tiff(char(Filtersfilenames(ic)), 'w');
        tagstruct.ImageLength = size(flatfield(:,:,ic), 1);
        tagstruct.ImageWidth = size(flatfield(:,:,ic), 2);
        tagstruct.Compression = Tiff.Compression.None;
        tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        t.setTag(tagstruct);
        t.write(single(flatfield(:,:,ic)));
        t.close();
        
        %imwrite(darkfield(:,:,ic),char(BackgroundFiltersfilenames(ic)));
        t = Tiff(char(BackgroundFiltersfilenames(ic)), 'w');
        tagstruct.ImageLength = size(darkfield(:,:,ic), 1);
        tagstruct.ImageWidth = size(darkfield(:,:,ic), 2);
        tagstruct.Compression = Tiff.Compression.None;
        tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        t.setTag(tagstruct);
        t.write(single(darkfield(:,:,ic)));
        t.close();
        
        [pathstr, chName, ext] = fileparts(Stacksfilenames{ic});
        figure('Name',chName); subplot(121); imagesc(flatfield(:,:,ic));colorbar; title('Estimated flatfield');
        subplot(122); imagesc(darkfield(:,:,ic));colorbar; title('Estimated darkfield');
    end
    if isFluorescence
        assignin('base','basefluor',basefluor)
    end
end