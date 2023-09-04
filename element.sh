#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align"

# Function to retrieve element information
REQUEST_ELEMENT_INFO() {
  local USER_INPUT="$1"
  local SQL_QUERY

  # Check if the user input is a number, symbol or name
  if [[ "$USER_INPUT" =~ ^[0-9]+$ ]]; then
    SQL_QUERY="SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number = $USER_INPUT"
  else
    SQL_QUERY="SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE symbol = '$USER_INPUT' OR name = '$USER_INPUT'"
  fi

  local ELEMENT_INFO
  ELEMENT_INFO=$($PSQL -c "$SQL_QUERY" 2>/dev/null)

  if [ $? -ne 0 ]; then
    echo "Error executing SQL query."
    return 1
  fi

  # Check if any rows were returned
  if [ -z "$ELEMENT_INFO" ]; then
    echo "I could not find that element in the database."
  else
    while IFS='|' read -r ATOMIC_NUMBER SYMBOL NAME ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE; do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done <<< "$ELEMENT_INFO"
  fi
}

# Check if an argument was provided
if [ $# -eq 0 ]; then
  echo "Please provide an element as an argument."
else
  # Call the function with the user's input (the first argument)
  REQUEST_ELEMENT_INFO "$1"
fi
