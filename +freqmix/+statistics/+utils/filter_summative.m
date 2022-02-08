function mixing = filter_summative(mixing)
% Filtering to remove triplets that don't sum or subtract 


% loop over all signals in mixing cell array
for i = 1:length(mixing)
    
    % taking the table of results
    results = mixing{i};
    
    % check if column exists
    summative_present = any(strcmp('summative',results.Properties.VariableNames));
    
    % if summative column present
    if summative_present
        results = results(results.summative==1,:);
    end
    
    % overwriting with filtered mixing
    mixing{i} = results;

end

end

