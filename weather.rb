#!/usr/bin/env ruby

require 'open-uri'
require 'json'
require 'net/smtp'

$hourly_data = []
$message = ''
class Weather
  def initialize()
    open('http://api.wunderground.com/api/e10c6fda8cea67a4/hourly/q/MD/Parkville.json') do |f|
      json_string = f.read
      d = JSON.parse(json_string)
      $hourly_data = d['hourly_forecast']
    end
  end
  def make_message()
    @rows = $hourly_data
    @str = ''
    @x = 0
    for item in @rows
      if @x < 11
        time = item['FCTTIME']['civil']
        condition = item['condition']
        temp = item['temp']['english']
        wind = item['wspd']['english']
        @str = @str + time + ' ' + condition + ' - ' + temp + '\0x00B0 - ' + wind + 'mph\n'
        @x += 1
      end
    end
    $message = @str
  end
  def send_text()
    message = <<END_OF_MESSAGE
    From: Weather Script <weather@ericalpin.me>
    To: 4109611479@vtext.com <4109611479@vtext.com>
    Subject: Weather

    #$message
END_OF_MESSAGE

    Net::SMTP.start('localhost') do |smtp|
      smtp.send_message message, 'weather@ericalpin.me', 
                                 '4109611479@vtext.com'
    end
    print "success!"
  end
end

weather = Weather.new
weather.make_message
weather.send_text

