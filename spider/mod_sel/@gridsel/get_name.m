function s=get_name(a)  
  
s=[get_name(a.algorithm)];  %% print name of algorithm  
eval_name                   %% print values of hyperparameters  

if ~isempty(a.best)
     s=[s '(' get_name(a.best) ')']; 
else
     s=[s '(' get_name(a.child) ')']; 
end
