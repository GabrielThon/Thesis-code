function generateChannelsStack(textfiles,savefolder)
    if ~exist(strcat(savefolder,"AllImages\"), 'dir')
        mkdir(savefolder,"AllImages\");
    end
    
    AllImagesfilename = dir(strcat(savefolder,'AllImages\','*.tif'));
    for i=1:size(AllImagesfilename,1)
        curfilename = strcat(AllImagesfilename(i).folder,'\',AllImagesfilename(i).name);
        if exist(curfilename);
            delete(curfilename);
        end
    end
    %mkdir(savefolder,"UnCorrectedImages\");
    for itxt=1:size(textfiles,1);
        [pathstr, name_exp, ext] = fileparts(textfiles(itxt).name);
        x=textfiles(itxt).x;
        y=textfiles(itxt).y;
        z=textfiles(itxt).z;
        c=textfiles(itxt).chNb;

        %Expfilename=strcat(savefolder,'UnCorrectedImages\',name_exp);
        AllImagesfilename=strcat(savefolder,'AllImages\',textfiles(itxt).chNames(:),'.tif');
        nimg = size(textfiles(itxt).imageName,1);
        for iimg = 1:nimg
            imgName=strcat(textfiles(itxt).folder,'\',textfiles(itxt).imageName(iimg).name);
            Iminfo=imfinfo(imgName);
            counter=1;

            for iy = 1:y
                for ix = 1:x
                    Im=zeros(Iminfo(1).Height,Iminfo(1).Width,z,c);
                    for iz = 1:z
                        for ic = 1:c
                            Im(:,:,iz,ic)=imread(imgName,counter);
                            counter=counter+1;
                        end
                    end
                    %                 if z==1
                    %                     Improjz=uint16(Im(:,:,1,:));
                    %                 else
                    Improjz=uint16(max(Im,[],3));
                    Improjz=reshape(Improjz,Iminfo(1).Height,Iminfo(1).Width,c);
                    %                 end
                    for ic = 1:c
                        %imwrite(Improjz(:,:,ic),char(strcat(Expfilename,'_f000',int2str(iimg),'-',textfiles(itxt).chNames(ic),'-Pos_00',int2str(ix),'_00',int2str(iy),'.tif')));
                        imwrite(Improjz(:,:,ic),char(AllImagesfilename(ic)),'WriteMode','append');
                    end
                end
            end
        end
    end
    disp('ChannelsStack generated');
end