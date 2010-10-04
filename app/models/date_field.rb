# DateField
# - a question that provides a calendar/date picker

class DateField < Question
  
  def validation_class
    if self.style == 'mmyy'
      'validate-selection ' + super
    else
      'validate-date ' + super
    end
  end
  
  def response(app=nil)
    r = super
    r = Time.parse(r) unless r.blank?    
    r || ''
  end
  
  def display_response(app=nil)
    return format_date_response(app)
  end
  
  def format_date_response(app=nil)
    r = response(app)
    r = r.strftime("%m/%d/%Y") unless r.blank?
    r
  end
  
  # which view to render this element?
  def ptemplate
    if self.style == 'mmyy'
      'date_field_mmyy'
    else
      'date_field'
    end
  end
  
end

