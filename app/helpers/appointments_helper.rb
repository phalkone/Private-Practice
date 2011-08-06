module AppointmentsHelper

  def dayarray(start, stop, apps)
    rows = ((stop-start)*4)
    darray = Array.new(rows+1){Array.new(1,-1)}

    maxlength = 0

    apps.each() do |app|
      subid = 0
      app.sub_appointments.each() do |subapp|
      if (subapp.begin.hour >= start) && ((subapp.end.hour < stop) || ((subapp.end.hour == stop) && (subapp.end.min == 0)))
        darray[subapp.begincell(start)].insert(-1, app.id.to_s+"/"+subid.to_s)
        if (subapp.rowspan > 1) && (darray[subapp.begincell(start)][0] != -1)
          for i in 1..(subapp.rowspan - 1)
            darray[subapp.begincell(start)+i][0] = darray[subapp.begincell(start)][0]
          end
        elsif subapp.rowspan > 1
          for i in 0..(subapp.rowspan - 1)
            darray[subapp.begincell(start)+i][0] = subapp.begincell(start)
          end
        end
      end
      subid += 1
      end
    end



    i = 0
    while i < rows do
      length = 1
      if (darray[i][0] == -1) && (darray[i].length > 1)
        length = darray[i].length - 1
        darray[i][0] = length
      elsif (darray[i][0] == i)
        j = i
        while (darray[j][0] == i) && (j < rows) do 
          l = (j > i) ? darray[j].length : darray[j].length - 1
          length = (l > length) ? l : length
          j += 1
        end
        j = i
        while (darray[j][0] == i) && (j < rows) do
          if (darray[j].length == 1) then
            darray[j][0] = -2
          else
            darray[j][0] = length
          end
          j += 1
        end
        i = j - 1
      end

      i += 1
      maxlength = (length > maxlength) ? length : maxlength
    end

    darray.last[0] = (maxlength*60)
    return darray
  end

end
