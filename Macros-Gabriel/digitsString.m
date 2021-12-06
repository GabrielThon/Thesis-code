function [output] = digitsString(x,n)
    output="";
    if x==0
        numZeros=n-1;
    else
        numZeros=n-floor(log10(x))-1;
    end
    for i=1:numZeros
        output=strcat(output,"0");
    end
    output=strcat(output,num2str(x));
end