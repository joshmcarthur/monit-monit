module XMLHelpers
  
  def value(selector, transformer = :to_s, xml = nil)
    (xml ? xml : @xml).xpath(selector).first.content.send(transformer) rescue nil
  end
  
end
