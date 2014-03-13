# -*- coding: utf-8 -*-
require 'twitter'
require './key.rb'

#定番のやつ。とりあえずこれを書け
@rest_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = Const::CONSUMER_KEY
  config.consumer_secret     = Const::CONSUMER_SECRET
  config.access_token        = Const::ACCESS_TOKEN
  config.access_token_secret = Const::ACCESS_TOKEN_SECRET
end

#userstreamsを繋いでるんじゃないかな
@stream_client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = Const::CONSUMER_KEY
  config.consumer_secret     = Const::CONSUMER_SECRET
  config.access_token        = Const::ACCESS_TOKEN
  config.access_token_secret = Const::ACCESS_TOKEN_SECRET
end

#update_name関数みたいなやつ
def update_name(status)

#statusに(@murakamiginko)があれば、そのテキストから(@murakamiginko)と@を削除する。
  if status.text.include?("(@murakamiginko)") then
    text = status.text.sub("(@murakamiginko)","")
    text = text.sub("@","")

#名前が20文字を越えている場合、returnする
  if text && 20 < text.length then
   text = "20文字以内にしてください。"
  end

#名前にtextの中身を入れ、textとmurakamiginkoが等しい場合は"戻りました"、違う場合は"改名しました"をtweetに入れる。あとはその内容をツイートする。
    @rest_client.update_profile(:name => "#{text}")
    opt = {"in_reply_to_status_id"=>status.id.to_s}
    tweet = "murakamiginko" == text ? "@#{status.user.screen_name} 戻りました" : "@#{status.user.screen_name} #{text}に改名しました"
    @rest_client.update tweet,opt
  end

end

#ここでuserstreamsに繋いでる。何かよくわからないやつとRTを弾いてupdate_nameを実行してる
@stream_client.user do |object|
  next unless object.is_a? Twitter::Tweet
  unless object.text.start_with? "RT"
    update_name(object)
  end
end
