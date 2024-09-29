#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompting user for their username
echo "Enter your username:"
read USERNAME

# Retrieving all available user data from DB
USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username = '$USERNAME'")

# Checking if user data is present
if [[ -z $USER_INFO ]]
then
  # Greeting and inserting user in the DB
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  # Reading all user data and showing the output
  echo $USER_INFO | while IFS="|" read GAMES_PLAYED BEST_GAMES
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAMES guesses."
  done
fi

echo "Guess the secret number between 1 and 1000:"
# Generating a random number using bash 'RANDOM' variable
NUMBER=$(($RANDOM%1000))

# Initializing user response variable
USER_GUESS=1001

# Keeping count of the user tries
GUESS_COUNT=0

while [[ $USER_GUESS != $NUMBER ]]
do
  # Reading the user input and updating guess count
  read USER_GUESS
  GUESS_COUNT=$((GUESS_COUNT+1))
  
  # Cheking the user input, if integer, lower than or greater than the actual number
  if [[ ! $USER_GUESS =~ ^[0-9][0-9]*$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $USER_GUESS -gt $NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $USER_GUESS -lt $NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  fi

done

# If game ended, updating game count
UPDATE_GAME_COUNT=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME'")

# Congratulating user
echo "You guessed it in $GUESS_COUNT tries. The secret number was $NUMBER. Nice job!"

# Updating best game if needed
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
if [[ $BEST_GAME = 0 || $BEST_GAME -gt $GUESS_COUNT ]]
then
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $GUESS_COUNT WHERE username = '$USERNAME'")
fi