xml.race do 
  xml.name @race[:name]
  xml.date @race[:date].strftime("%F")
end