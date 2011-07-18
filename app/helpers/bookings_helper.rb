module BookingsHelper
  
  def week_view(options = {}, &block)
    raise(ArgumentError, "Appointments not given")  unless options.has_key?(:appointments)
    raise(ArgumentError, "Beginning of the week not given")  unless options.has_key?(:begin_week)
    raise(ArgumentError, "Weekend not given")  unless options.has_key?(:weekend)

    block ||= Proc.new {|a| nil}

    defaults = {        
      :table_class  => 'week'
    }
    
    options = defaults.merge options
    
    start = 9
    stop = 17
    options[:appointments].each() do |app|
      start = app.begin.hour if app.begin.hour < start
      end_time = (app.end.min == 0) ? app.end.hour : app.end.hour + 1 
      stop = end_time if end_time > stop
    end

    # Table header
    cal = %(<table class="#{options[:table_class]}">).html_safe
    cal << %(<thead><tr><th></th>).html_safe
    next_day = options[:begin_week]
    for i in 0..(options[:weekend]-1)
      cal << %(<th> #{I18n.l(next_day, :format => :only_day_name)}<br />#{I18n.l(next_day, :format => :short_date)}</th>).html_safe
      next_day = next_day.tomorrow
    end
    cal << %(</tr></thead><tbody>).html_safe
    
    #Week array
    warray = Array.new(stop-start){Array.new(options[:weekend])}

    options[:appointments].each do |app|
      i = 0
      app.sub_appointments.each() do |subapp|
        row = subapp.begin.hour - start
        column = subapp.begin.to_date.cwday - 1
        cell = %( <div class="unbooked center">#{link_to I18n.l(subapp.begin, :format => :time), new_booking_path(:booking => {:main_id => app.id, :sub_id => i}), :title => t("appointments.book_now").upcase, :class => "book", :remote => true}</div>)
        if warray[row][column] == nil 
          warray[row][column] = cell
        else
          warray[row][column].insert(-1, cell)
        end
        i += 1
      end
    end
    
    for i in 0..((stop-start)-1)
      hour = start + i
      cal << %(<tr><td class="hour"><span class="big"> #{(hour.to_s.length < 2) ? "0" + hour.to_s : hour}</span><span class="superscript">00</span></td>).html_safe
      warray[i].each do |c|
        cal << %(<td>#{c}</td>).html_safe
      end
      cal << %(</tr>).html_safe
    end

 
    cal << %(</tbody></table>).html_safe
  end
  
end
