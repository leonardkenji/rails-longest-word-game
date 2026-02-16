require 'open-uri'
require 'json'

class GamesController < ApplicationController

  def game

  end

  def new
    @array_words = ("A".."Z").to_a.sample(20)
    @start_time = Time.now
  end

  def score
    @your_word = params[:your_word]
    @array_words = params[:grid].split
    @start_time = Time.parse(params[:start_time])
    @end_time = Time.now
    @result = run_game(@your_word, @array_words, @start_time, @end_time)
  end

  def included?(guess, array_words)
    guess.chars.all? { |letter| guess.count(letter) <= @array_words.count(letter) }
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : (attempt.size * (1.0 - (time_taken / 60.0)))
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result (with `:score`, `:message` and `:time` keys)
    @result = { time: end_time - start_time }

    score_and_message = score_and_message(attempt, @array_words, @result[:time])
    @result[:score] = score_and_message.first
    @result[:message] = score_and_message.last
    @result
  end

  def score_and_message(attempt, array_words, time)
    if included?(@your_word.upcase, @array_words)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def english_word?(word)
    response = URI.parse("https://dictionary.lewagon.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end

end
