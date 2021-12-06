function correctImages(textfiles,savefolder,varargin)
    nVarargs = length(varargin);
    % Correction sans fluorescence
    if nVarargs ==0
        if ~exist(strcat(savefolder,"CorrectedImages\"), 'dir')
            mkdir(savefolder,"CorrectedImages\");
        end
        
        for itxt=1:size(textfiles,1);
            [pathstr, name_exp, ext] = fileparts(textfiles(itxt).name);
            x=textfiles(itxt).x;
            y=textfiles(itxt).y;
            z=textfiles(itxt).z;
            c=textfiles(itxt).chNb;
            nimg = size(textfiles(itxt).imageName,1);
            CorrectedImagesfilenames = strings(nimg,1);
            
            for iimg = 1:nimg
                imgName=strcat(textfiles(itxt).folder,'\',textfiles(itxt).imageName(iimg).name);
                [pathstr, name_img, ext] = fileparts(imgName);
                CorrectedImagesfilenames(iimg)=strcat(savefolder,"CorrectedImages\",name_img,"-corrected",ext);
                if exist(CorrectedImagesfilenames{iimg})
                    delete(CorrectedImagesfilenames{iimg});
                end
                counter = 1;
                for iy = 1:y
                    for ix = 1:x
                        for iz = 1:z
                            for ic = 1:c
                                flatfield = double(imread(char(strcat(savefolder,'Computed-filters\',textfiles(itxt).chNames(ic),'-flatfield.tif'))));
                                maxflatfield=max(max(flatfield,[],1),[],2);
                                flatfield = flatfield./maxflatfield;
                                ImnonCorrected=imread(imgName,counter);
                                ImCorrected = uint16(double(ImnonCorrected)./flatfield);
                                imwrite(ImCorrected,CorrectedImagesfilenames{iimg},'WriteMode','append');
                                counter=counter+1;
                            end
                        end
                    end
                end
            end
        end
        % Correction avec fluorescence
    elseif nVarargs == 1
        basefluor = varargin{1};
        if ~exist(strcat(savefolder,"CorrectedImages\"), 'dir')
            mkdir(savefolder,"CorrectedImages\");
        end
        counterimg = 1;
        for itxt=1:size(textfiles,1);
            [pathstr, name_exp, ext] = fileparts(textfiles(itxt).name);
            x=textfiles(itxt).x;
            y=textfiles(itxt).y;
            z=textfiles(itxt).z;
            c=textfiles(itxt).chNb;
            nimg = size(textfiles(itxt).imageName,1);
            CorrectedImagesfilenames = strings(nimg,1);
            for iimg = 1:nimg
                imgName=strcat(textfiles(itxt).folder,'\',textfiles(itxt).imageName(iimg).name);
                [pathstr, name_img, ext] = fileparts(imgName);
                CorrectedImagesfilenames(iimg)=strcat(savefolder,"CorrectedImages\",name_img,"-corrected",ext);
                if exist(CorrectedImagesfilenames{iimg})
                    delete(CorrectedImagesfilenames{iimg});
                end
                counter = 1;
                for iy = 1:y
                    for ix = 1:x
                        for iz = 1:z
                            for ic = 1:c
                                flatfield = double(imread(char(strcat(savefolder,'Computed-filters\',textfiles(itxt).chNames(ic),'-flatfield.tif'))));
                                darkfield = double(imread(char(strcat(savefolder,'Computed-filters\',textfiles(itxt).chNames(ic),'-darkfield.tif'))));
                                maxflatfield=max(max(flatfield,[],1),[],2);
                                flatfield = flatfield./maxflatfield;
                                ImnonCorrected=imread(imgName,counter);
                                ImCorrected = uint16((double(ImnonCorrected)-darkfield)./flatfield - basefluor{ic}(counterimg));
                                imwrite(ImCorrected,CorrectedImagesfilenames{iimg},'WriteMode','append');
                                counter=counter+1;
                            end
                        end
                    end
                end
                counterimg = counterimg+1;
            end
        end
    end
    disp('Images corrected');
end