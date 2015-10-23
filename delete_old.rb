Article.all.each do |a|
  if a.created_at>Date.today-1
    a.delete
  end
end
Article.all.each do |a|
  print a.id.to_s + " "
end; nil