# Copyright (c) 2006 Jeremy Voorhis and Geoffrey Grosenbach

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

require 'date'

# CalendarHelper allows you to draw a databound calendar with fine-grained CSS formatting
module CalendarHelper

  VERSION = '0.2.4'

  def calendar(options = {}, &block)
    raise(ArgumentError, "No year given")  unless options.has_key?(:year)
    raise(ArgumentError, "No month given") unless options.has_key?(:month)

    block ||= Proc.new {|d| nil}

    defaults = {
      :table_class         => 'calendar',
      :month_name_class    => 'monthName',
      :other_month_class   => 'otherMonth',
      :day_name_class      => 'dayName',
      :day_class           => 'day',
      :day                 => 1,
      :abbrev              => (0..1),
      :first_day_of_week   => 1,
      :accessible          => false,
      :show_today          => true,
      :previous_month_text => nil,
      :next_month_text     => nil,
      :month_header        => true,
      :calendar_title      => I18n.t("date.month_names")[options[:month]] + " " +options[:year].to_s
    }
    options = defaults.merge options

    first = Date.civil(options[:year], options[:month], 1)
    last = Date.civil(options[:year], options[:month], -1)

    first_weekday = first_day_of_week(options[:first_day_of_week])
    last_weekday = last_day_of_week(options[:first_day_of_week])
    
    day_names = I18n.t("date.day_names").dup
    first_weekday.times do
      day_names.push(day_names.shift)
    end

    cal = %(<table class="#{options[:table_class]}" border="0" cellspacing="0" cellpadding="0">).html_safe
    cal << %(<thead>).html_safe
    
    if (options[:month_header])
      cal << %(<tr>).html_safe
      if options[:previous_month_text] or options[:next_month_text]
        cal << %(<th colspan="1">#{options[:previous_month_text]}</th>).html_safe
        colspan=5
      else
        colspan=7
      end
      cal << %(<th colspan="#{colspan}" class="#{options[:month_name_class]}">#{options[:calendar_title]}</th>).html_safe
      cal << %(<th colspan="1">#{options[:next_month_text]}</th>).html_safe if options[:next_month_text]
      cal << %(</tr>).html_safe
    end
    
    cal << %(<tr class="#{options[:day_name_class]}">).html_safe
    
    day_names.each do |d|
      unless d[options[:abbrev]].eql? d
        cal << ("<th scope='col'><abbr title='#{d}'>#{d[options[:abbrev]]}</abbr></th>").html_safe
      else
        cal << ("<th scope='col'>#{d[options[:abbrev]]}</th>").html_safe
      end
    end
    cal << "</tr></thead><tbody><tr>".html_safe
    beginning_of_week(first, first_weekday).upto(first - 1) do |d|
      cal << %(<td class="#{options[:other_month_class]}).html_safe
      cal << " weekendDay" if weekend?(d)
      if options[:accessible]
        cal << %(">#{d.day}<span class="hidden"> #{I18n.t("date.month_names")[d.month]}</span></td>).html_safe
      else
        cal << %(">#{d.day}</td>).html_safe
      end
    end unless first.wday == first_weekday
    today = Date.current
    first.upto(last) do |cur|
      cell_text, cell_attrs = block.call(cur) if (cur >= today)
      cell_text  ||= cur.mday
      cell_attrs ||= {}
      cell_attrs[:class] ||= (cur < today) ? options[:other_month_class] : options[:day_class]
      cell_attrs[:class] += " weekendDay" if [0, 6].include?(cur.wday)
      cell_attrs[:class] += " today" if (cur == today) and options[:show_today]
      cell_attrs[:class] += " selected" if (cur.mday == options[:day])
      cell_attrs = cell_attrs.map {|k, v| %(#{k}="#{v}") }.join(" ")
      cal << ("<td #{cell_attrs}>#{cell_text}</td>").html_safe
      cal << ("</tr><tr>").html_safe if cur.wday == last_weekday
    end
    (last + 1).upto(beginning_of_week(last + 7, first_weekday) - 1)  do |d|
      cal << %(<td class="#{options[:other_month_class]}).html_safe
      cal << " weekendDay" if weekend?(d)
      if options[:accessible]
        cal << %(">#{d.day}<span class='hidden'> #{I18n.t("date.month_names")[d.mon]}</span></td>).html_safe
      else
        cal << %(">#{d.day}</td>).html_safe    
      end
    end unless last.wday == last_weekday
    cal << ("</tr></tbody></table>").html_safe
  end
  
  private
  
  def first_day_of_week(day)
    day
  end
  
  def last_day_of_week(day)
    if day > 0
      day - 1
    else
      6
    end
  end
  
  def days_between(first, second)
    if first > second
      second + (7 - first)
    else
      second - first
    end
  end
  
  def beginning_of_week(date, start = 1)
    days_to_beg = days_between(start, date.wday)
    date - days_to_beg
  end
  
  def weekend?(date)
    [0, 6].include?(date.wday)
  end
  
end
