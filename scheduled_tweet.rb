# -*- coding: utf-8 -*-
=begin
mikutter-scheduled-tweet
CSVで指定した時刻に指定したメッセージをタイムラインに流します。
=end
require 'csv'
require 'date'

Plugin.create :scheduled_tweet do
  def main
    tweet_scheduling.each {|schedule|
      Reserver.new(tweet_time(schedule)) {
        post(Post.primary_service, schedule)
      }
    }
  end

  #ツイートする予定リストのCSVファイルをロード
  def load_schedule_csv(filepath)
    begin
      schedule_csv = CSV.open(filepath)
    rescue => not_found
      `touch ${filepath}`
    else
      yield scheduled_csv
    end
  end

  #ツイートの予定を組む
  def tweet_scheduling
    begin
      load_schedule_csv(UserConfig[:scheduled_tweet_filepath]) {|schedule_csv|
        header = schedule_csv.take(1).first
        schedule_csv.map {|row|
          Hash[header, row]
        }.delete_if{|schedule|
          tweet_time(schedule) < Time.now
        }
      }
     rescue  => ivalid_format
      #システムメッセージを飛ばしたいんですがどうしたらいいんですか
      puts 'invalid format!'
      []
    end 
  end
  # ツイートする時間を取得
  def tweet_time(schedule)
    Datetime.parse (schedule['Start Date'] + ' ' + schedule['Start Time']) end

  # よるほーとつぶやく
  def post(service, schedule)
    service.update(:message => schedule['description']) end

  main
end
