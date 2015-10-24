Article.all.each do |a|
  a.delete if a.created_at > Date.today - 1
end
Article.all.each do |a|
  print a.id.to_s + ' '
end; nil
