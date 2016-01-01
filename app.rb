require 'sinatra'
require 'haml'
require_relative 'lib/chess_game.rb'

game = ChessGame.new

get '/' do
  haml :index
end

post '/' do
  data = params[:squareClicked]
  if game.input_mode == :selecting
    game.handle_selection(data.to_s)
  elsif game.input_mode == :moving
    game.handle_moving(data.to_s)
  end
end

post '/messages' do
  message_string = ''
  game.messages.each do |message|
    message_string << message << "\n"
  end
  return message_string
end
