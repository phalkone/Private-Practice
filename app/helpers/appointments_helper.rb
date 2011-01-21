module AppointmentsHelper
  def barray(apps)
    barray = Array.new(2, 0)
    apps.each() do |app|
      (app.unbooked?) ? barray[1] += app.sub_appointments.length : barray[0] += 1
    end
    return barray
  end

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

  def weekarray(start, stop, apps, weekend)
    warray = Array.new(stop-start){Array.new((@weekend == "1")? 7 : 5)}

    apps.each() do |app|
      i = 0
      app.sub_appointments.each() do |subapp|
        row = subapp.begin.hour - start
        column = subapp.begin.to_date.cwday - 1
        if (row >= 0) && (row < (stop-start)) 
          if warray[row][column] == nil 
            warray[row][column] = app.id.to_s + "/" + i.to_s
          else
            warray[row][column].insert(-1, ';' + app.id.to_s + "/" + i.to_s)
          end
        end
      i += 1
      end
    end

    return warray
  end

end
