function [R] = createR1(p,q)
R = zeros(p,q);
for i=1:p
    for j=1:q
        temp = rand();
        if(temp >= 0.5)
            R(i,j) = 1;
        else
            R(i,j) = -1;
        end
    end
end    
end

