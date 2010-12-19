class AppointmentsController < ApplicationController
  def index
    @title = t("appointments.menutitle")
    @date = Time.now.to_date
    @start = 9
    @stop = 17
  end

  def refresh
    datesplit = params["view"]["date"].split(" ")
    @date = Date.new(datesplit[0].to_i,datesplit[1].to_i,datesplit[2].to_i)
    @start = params["view"]["start"].to_i
    @stop = params["view"]["stop"].to_i
  end
end
