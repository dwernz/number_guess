#!/bin/bash

PSQL=("psql --username=freecodecamp --dbname=number_guessing_game -t --no-align -c")

echo "Enter your username:"
read USERNAME

SECRET_NUMBER=$((1 + $RANDOM % 1000))
NUM_TRIES=1

USERNAME_AVAILABLE=$($PSQL "SELECT username FROM users WHERE username='$USERNAME';")

if [[ -z $USERNAME_AVAILABLE ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME');")
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME_AVAILABLE';")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME_AVAILABLE';")

  if [[ -z $GAMES_PLAYED ]]
  then
    GAMES_PLAYED=0
  fi

  if [[ -z $BEST_GAME ]]
  then
    BEST_GAME='N/A'
  fi

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"

while read GUESS
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      if [[ $GUESS -lt $SECRET_NUMBER ]]
      then
        echo "It's higher than that, guess again:"
      else
        if [[ $GUESS -eq $SECRET_NUMBER ]]
        then
          GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME';")
          if [[ -z GAMES_PLAYED ]]
          then
            GAMES_PLAYED=1
          else
            GAMES_PLAYED=$(( $GAMES_PLAYED + 1))
          fi

          UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE username='$USERNAME';")

          BEST_GAME=$($PSQL "SELECT best_Game FROM users WHERE username='$USERNAME';")
          if [[ -z $BEST_GAME ]]
          then 
            BEST_GAME=$NUM_TRIES
            UPDATE_GAME_RESULT=$($PSQL "UPDATE users SET best_game = $BEST_GAME WHERE username='$USERNAME';")
          else
            if [[ $BEST_GAME -gt $NUM_TRIES ]]
            then
              BEST_GAME=$NUM_TRIES
              UPDATE_GAME_RESULT=$($PSQL "UPDATE users SET best_game = $BEST_GAME WHERE username='$USERNAME';")
            fi
          fi
          
          echo "You guessed it in $NUM_TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
          break
        fi
      fi
    fi
  fi
  NUM_TRIES=$(( $NUM_TRIES + 1 ))
done

