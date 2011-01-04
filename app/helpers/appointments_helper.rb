module AppointmentsHelper

  def dayarray(start, stop, apps)
    rows = ((stop-start)*4)
    darray = Array.new(rows+1){Array.new(1,-1)}

    maxlength = 0

    apps.each() do |app|
      darray[app.begincell(start)].insert(-1, app.id)
      if (app.rowspan > 1) && (darray[app.begincell(start)][0] != -1)
        for i in 1..(app.rowspan - 1)
          darray[app.begincell(start)+i][0] = darray[app.begincell(start)][0]
        end
      elsif app.rowspan > 1
        for i in 0..(app.rowspan - 1)
          darray[app.begincell(start)+i][0] = app.begincell(start)
        end
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
        i = j - 2
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
      row = app.begin.hour - start
      column = app.begin.to_date.cwday - 1
      if warray[row][column].nil? 
        warray[row][column] = app.id.to_s
      else
        warray[row][column].insert(-1, ';' + app.id.to_s)
      end
    end

    return warray
  end

end
