# TextField
# - a question that prompts for one or more lines of text

class TextField < Question
  
  # which view to render this element?
  def template
    if self.style == 'essay'
      'text_area_field'
    else
      'text_field'
    end
  end
  
  # css class names for javascript-based validation
  def validation_class
    validation = ''
    validation += ' required' if self.required?
    # validate-number, etc.
    validate_style = ['number', 'currency-dollar', 'email', 'url', 'phone'].find {|v| v == self.style }
    if validate_style
      validation += ' validate-' + validate_style
    end
    validation
  end
  
end