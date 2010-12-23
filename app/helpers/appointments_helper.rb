module AppointmentsHelper

  def dayarray(start, stop, apps)
    darray = Array.new(((stop-start)*4)+1){Array.new}
    maxlength = 0
    prevend = -1
    apps.each() do |app|
      darray[app.begincell(start)].insert(-1, app.id)
      length = darray[app.begincell(start)].length
      if prev == app.begincell(start)
        length += 1
      end
      if app.begincell(start) != app.endcell(start)
        prev = app.endcell(start)
      end
      maxlength = (length > maxlength) ? length : maxlength
    end
  end

end
