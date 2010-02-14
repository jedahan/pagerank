%%% Copyright 2010 Jonathan Dahan <jedahan@gmail.com>
%%% Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

function B = BuildMatrix(basedir,filename)
    % buildMatrix  Creates the normalized probability matrix

    %%% create cellarray of indexed pages
    pages = textread(filename, '%s');

    %%% initialize empty matrix
    B = zeros(length(pages), length(pages));

    %%% for each page,
    for page_num=1:length(pages)
      page = pages(page_num){1,1};
      %%% capture all the hrefs 
      fid = fopen(strrep(page,'http://',''));
      %%% NOTE utf8 pages complain about range error conversion here
      hrefs=regexp(fscanf(fid,'%s'),'ahref=["'']([^"'']+html)["'']','tokens');
      fclose(fid);
      %%% for each href
      for href_num=1:length(hrefs)
        href = hrefs{1,href_num}{1,1};
        %%% replace first character in relative path with full path
        href = regexprep(href,'^[/\w]',[page(1:findstr(page,'/')(end)) '$0'],'once');
        %%% replace any number of ../s with the full path
        if regexpi(href,'^\.\./')
            ups = strfind(href,'../');
            downs = strfind(page,'/');
            href = strcat(page(1:downs(end-length(ups))), href(ups(end)+3:end));
        end

        %%% prepend http if its not found
        regexprep(href, '^[^http\:]','http://$0');

        %%% mark the appropriate entry in B
        B(find(strcmp(pages,href)), find(strcmp(pages,page))) = 1;
      end
    end

  %%% replace any all 0 column with all 1s
  B(:,find(all(~B)))=1;

  %%% normalize by the column sum
  B = bsxfun(@rdivide,B,sum(B));
end

function w = PageRank(B,d)
    % PageRank  Determines the rank of each page damping

    w{1} = ones(length(B),1)./length(B);
    n = 2;
    w{n} = (1-d)*w{1} + d*(B*w{n-1});
    while w{n}~=w{n-1}
        n = n+1;
        w{n} = (1-d)*w{1} + d*(B*w{n-1});
    end
    w = w{end};
end

%%% Process CLI arguments
if length(argv())~=3
    disp "Usage: matlab links.m <basedir> <filename> <damping factor>"
    exit
end
basedir = argv(){1};
filename = argv(){2};
damping = argv(){3};

%%% Save results
results = PageRank( BuildMatrix(basedir, filename), str2num(damping) );
save ( 'results.mat', 'results' );
[ra,in] = sort(results,'descend');
fprintf(fopen('rankedresults.html','w'),'%s\n<br \\>\n',textread(filename,'%s')(in){:});
